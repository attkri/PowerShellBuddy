#Requires -Version 5.1
#Requires -PSEdition Core, Desktop

using namespace System.Security.Cryptography.X509Certificates

class SecurityInfoCheck {

    [int]    $Id
    [string] $Status
    [string] $Category
    [string] $Test
    [Object] $Actual
    [Object] $Expected

    SecurityInfoCheck([int]$Id, [string]$Status, [string]$Category, [string]$Test, [Object]$Actual, [Object]$Expected) {
        $this.Id = $Id
        $this.Status = $Status
        $this.Category = $Category
        $this.Test = $Test
        $this.Actual = $Actual
        $this.Expected = $Expected
    }
}

function Test-CertificateExportability {
    param([X509Certificate2]$Cert)
    try {
        $Cert.Export(([X509ContentType]::Pfx)) | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

<#
.SYNOPSIS
Analyzes the current system for PowerShell-related security signals.

.OUTPUTS
Returns a `[SecurityInfoCheck]` object. Additional context is available through verbose output.

.EXAMPLE
Test-SecurityState

.EXAMPLE
Test-SecurityState -Verbose

.EXAMPLE
Test-SecurityState -SkipModuleVersionTest -Verbose

.EXAMPLE
Test-SecurityState -SkipAlternateDataStreamTest -Verbose

.EXAMPLE
Test-SecurityState -SkipModuleVersionTest -SkipAlternateDataStreamTest -Verbose
#>
function Test-SecurityState {


    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock','')]
    [CmdletBinding()]
    param(
        # Skips the time-consuming module version checks that require an internet connection.
        [switch]$SkipModuleVersionTest,

        # Skips the time-consuming alternate data stream scan.
        [switch]$SkipAlternateDataStreamTest
    )

    if (-not $IsWindows) {
        Write-Error 'Test-SecurityState is currently supported on Windows only.'
        return
    }

    $My = [HashTable]::Synchronized(@{})
    $My.ESC = [char]0x1b
    $My.Status = $null
    $My.Result = $null
    $My.TargetResult = $null
    $My.Id = 1
    $My.Neutral = 'Neutral'
    $My.Passed = "$($My.ESC)[92mPassed$($My.ESC)[0m"
    $My.Failed = "$($My.ESC)[91mFailed$($My.ESC)[0m"
    $My.Skip = "$($My.ESC)[95mSkipped$($My.ESC)[0m"
    $my.IsAdminRights = (New-Object -TypeName Security.Principal.WindowsPrincipal -ArgumentLIST ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::AdminISTrator)

    #region General

    [SecurityInfoCheck]::new($My.Id++, $My.Neutral, 'General', 'PSEdition', $PSVersionTable.PSEdition, '')
    "Check $($My.Id - 1): See about_PowerShell_Editions for more details." | Write-Verbose

    if ($PSVersionTable.PSVersion -le [Version]"2.0.0.0") { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SecurityInfoCheck]::new($My.Id++ , $My.Status, 'General', 'PSVersion', $PSVersionTable.PSVersion, '-gt 2.0')
    "Check $($My.Id - 1): Windows PowerShell 2.0 can bypass modern protections. Disable it through Windows features if it is still available." | Write-Verbose

    [SecurityInfoCheck]::new($My.Id++, $My.Neutral, 'General', 'Platform', $PSVersionTable.Platform, '')

    [SecurityInfoCheck]::new($My.Id++, $My.Neutral, 'General', 'CurrentPSHost', (Get-Host | Select-Object -ExpandProperty Name), '')
    "Check $($My.Id - 1): Other common PowerShell hosts include ConsoleHost, Visual Studio Code Host, and Windows PowerShell ISE Host." | Write-Verbose

    if ($ExecutionContext.SessionState.LanguageMode -ieq "FullLanguage") { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SecurityInfoCheck]::new($My.Id++, $My.Status, 'General', 'PSSessionLanguageMode', ($ExecutionContext.SessionState.LanguageMode), 'ConstrainedLanguage')
    "Check $($My.Id - 1): See about_Language_Modes for more details." | Write-Verbose

    if ((Get-ExecutionPolicy) -ine "AllSigned") { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SecurityInfoCheck]::new($My.Id++, $My.Status, 'General', 'ExecutionPolicy', (Get-ExecutionPolicy), 'AllSigned')
    "Check $($My.Id - 1): A strict baseline would use AllSigned. For development work, RemoteSigned is often the more practical choice." | Write-Verbose

    if ($my.IsAdminRights) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SecurityInfoCheck]::new($My.Id++, $My.Status, 'General', 'Elevated admin rights', $my.IsAdminRights, $false)

    #endregion

    #region PROFILE

    $my.Result = Test-Path -Path $PROFILE.AllUsersAllHosts -PathType Leaf
    if ($My.Result) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SecurityInfoCheck]::new($My.Id++, $My.Status, 'Profile file present', 'AllUsersAllHosts', $My.Result, $false)

    $my.Result = Test-Path -Path $PROFILE.AllUsersCurrentHost -PathType Leaf
    if ($My.Result) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SecurityInfoCheck]::new($My.Id++, $My.Status, 'Profile file present', 'AllUsersCurrentHost', $My.Result, $false)
    "Check $($My.Id - 1): Also review profile paths used by other PowerShell hosts." | Write-Verbose

    $my.Result = Test-Path -Path $PROFILE.CurrentUserAllHosts -PathType Leaf
    if ($My.Result) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SecurityInfoCheck]::new($My.Id++, $My.Status, 'Profile file present', 'CurrentUserAllHosts', $My.Result, $false)

    $my.Result = Test-Path -Path $PROFILE.CurrentUserCurrentHost -PathType Leaf
    if ($My.Result) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SecurityInfoCheck]::new($My.Id++, $My.Status, 'Profile file present', 'CurrentUserCurrentHost', $My.Result, $false)
    "Check $($My.Id - 1): Also review profile paths used by other PowerShell hosts." | Write-Verbose

    #endregion

    #region Microsoft Defender Antivirus

    $my.Result = Get-MpPreference | Select-Object -ExpandProperty ExclusionPath
    if ($null -ne $My.Result) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SecurityInfoCheck]::new($My.Id++, $My.Status , 'Defender', 'ExclusionPath', $My.Result, 'No Exclusion Paths')

    #endregion

    #region Module Version Check

    $My.Status = $my.Skip ; $My.Result = 'Check skipped' ; $My.TargetResult = 'Check skipped'
    if (-not $SkipModuleVersionTest) {
        $My.Status = $My.Passed ; $My.Result = 'Not required in PowerShell 7' ; $My.TargetResult = 'Not required in PowerShell 7'
        if ($PSVersionTable.PSVersion -lt [Version]'6.0') {
            $My.Result = (Get-PackageProvider -Name NuGet).Version
            $My.TargetResult = (Find-PackageProvider -Name NuGet).Version
            if ($My.Result -le $My.TargetResult) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
        }
    }
    [SecurityInfoCheck]::new($My.Id++, $My.Status, 'PackageProvider', 'NuGet', $My.Result, $My.TargetResult)
    "Check $($My.Id - 1): This check is only relevant for Windows PowerShell 5.1." | Write-Verbose

    #endregion

    #region Module Version Check

    $My.Status = $my.Skip ; $My.Result = 'Check skipped' ; $My.TargetResult = 'Check skipped'
    if (-not $SkipModuleVersionTest) {
        $My.Result = (Get-Module -Name PackageManagement -LISTAvailable -Verbose:$false).Version | Sort-Object -Descending | Select-Object -First 1
        $My.TargetResult = [Version](Find-Module -Name PackageManagement).Version
        if ($My.Result -lt $My.TargetResult) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    }
    [SecurityInfoCheck]::new($My.Id++, $My.Status, 'Module', 'PackageManagement', $My.Result, $My.TargetResult)

    $My.Status = $my.Skip ; $My.Result = 'Check skipped' ; $My.TargetResult = 'Check skipped'
    if (-not $SkipModuleVersionTest) {
        $My.Result = (Get-Module -Name PowerShellGet -LISTAvailable -Verbose:$false).Version | Sort-Object -Descending | Select-Object -First 1
        $My.TargetResult = [Version](Find-Module -Name PowerShellGet).Version
        if ($My.Result -lt $My.TargetResult) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    }
    [SecurityInfoCheck]::new($My.Id++, $My.Status, 'Module', 'PowerShellGet', $My.Result, $My.TargetResult)

    $My.Status = $my.Skip ; $My.Result = 'Check skipped' ; $My.TargetResult = 'Check skipped'
    if (-not $SkipModuleVersionTest) {
        $My.Result = (Get-Module -Name PSScriptAnalyzer -LISTAvailable -Verbose:$false).Version | Sort-Object -Descending | Select-Object -First 1
        $My.TargetResult = [Version](Find-Module -Name PSScriptAnalyzer).Version
        if ($My.Result -lt $My.TargetResult) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    }
    [SecurityInfoCheck]::new($My.Id++, $My.Status, 'Module', 'PSScriptAnalyzer', $My.Result, $My.TargetResult)

    $My.Status = $my.Skip ; $My.Result = 'Check skipped' ; $My.TargetResult = 'Check skipped'
    if (-not $SkipModuleVersionTest) {
        $My.Result = (Get-Module -Name Pester -LISTAvailable -Verbose:$false).Version | Sort-Object -Descending | Select-Object -First 1
        $My.TargetResult = [Version](Find-Module -Name Pester).Version
        if ($My.Result -lt $My.TargetResult) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    }
    [SecurityInfoCheck]::new($My.Id++, $My.Status, 'Module', 'Pester', $My.Result, $My.TargetResult)

    #endregion

    #region ScriptBlockLogging

    $My.Result = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'EnableScriptBlockLogging' -ErrorAction SilentlyContinue
    if ($My.Result -eq 1) { $My.Status = $My.Passed } else { $My.Status = $My.Failed }
    [SecurityInfoCheck]::new($My.Id++, $My.Status, 'ScriptBlockLogging', 'Windows PowerShell 64bit', $My.Result, 1)
    "Check $($My.Id - 1): Script block logging should be enabled, ideally with protected logging. See about_Logging_Windows for more details." | Write-Verbose
    
    $My.Result = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'EnableScriptBlockLogging' -ErrorAction SilentlyContinue
    if ($My.Result -eq 1) { $My.Status = $My.Passed } else { $My.Status = $My.Failed }
    [SecurityInfoCheck]::new($My.Id++, $My.Status, 'ScriptBlockLogging', 'Windows PowerShell 32bit', $My.Result, 1)
    "Check $($My.Id - 1): Script block logging should be enabled, ideally with protected logging. See about_Logging_Windows for more details." | Write-Verbose

    $My.Result = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\PowerShellCore\ScriptBlockLogging' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'EnableScriptBlockLogging' -ErrorAction SilentlyContinue
    if ($My.Result -eq 1) { $My.Status = $My.Passed } else { $My.Status = $My.Failed }
    [SecurityInfoCheck]::new($My.Id++, $My.Status, 'ScriptBlockLogging', 'PowerShell 6+ 64bit', $My.Result, 1)
    "Check $($My.Id - 1): Script block logging should be enabled, ideally with protected logging. See about_Logging_Windows for more details." | Write-Verbose
    
    #endregion

    #region Just Enough Administration

    if($my.IsAdminRights) {
        $My.Result = Get-PSSessionConfiguration -Verbose:$false | Where-Object -Property Name -NotMatch -Value 'PowerShell' | Select-Object -ExpandProperty Name
    } else {
        "Check $($My.Id - 1): Warning: no elevated admin rights available. Run this check again from an elevated session." | Write-Warning
        $My.Result = "n/v"
    }
    [SecurityInfoCheck]::new($My.Id++, $My.Neutral, 'JEA', 'SessionConfigurations', $my.Result, '')
    "Check $($My.Id - 1): Consider using JEA for non-administrators or accounts with administrative tasks." | Write-Verbose

    #endregion

    #region Alternate Data Stream

    $My.Status = $My.Skip; $My.Result = 'Check skipped'
    if (-not $SkipAlternateDataStreamTest) {
        $My.CurrentCounter = 0
        $My.Status = $My.Neutral
        $My.Result = Get-ChildItem -Path c:\ -File -Force -Recurse -ErrorAction Ignore | ForEach-Object -Process {
            $My.CurrentCounter++
            if (($My.CurrentCounter % 250) -eq 0) {
                Write-Progress -Activity 'Scanning files for alternate data streams' -Status "$($My.CurrentCounter) files scanned"
            }
            try { Get-Item -Path $_.FullName -Stream * -ErrorAction Ignore | Where-Object -Property Stream -ne ':$DATA' } catch {  }
        } | Group-Object -Property Stream | Sort-Object -Descending Count | Select-Object -Property Count, Name, @{Name = 'Sum'; Expression = { ($_.Group | Measure-Object -Property Length -Sum | Select-Object -ExpandProperty Sum) / 1KB } }, Group
        Write-Progress -Activity 'Scanning files for alternate data streams' -Completed
    }
    [SecurityInfoCheck]::new($My.Id++, $My.Status, 'Alternate Data Stream', 'Grouped actual result', $My.Result, 'Zero ADS strategy')
    "Check $($My.Id - 1): Review suspicious or large ADS entries manually. See the grouped actual result for details." | Write-Verbose

    #endregion

    #region PKI

    $My.Result = Get-ChildItem -Path 'Cert:\' -Recurse -Force | Where-Object -Property 'HasPrivateKey' | ForEach-Object -Process {
        if ((Test-CertificateExportability $_)) {
            return "SUBJECT: $($_.Subject) THUMBPRINT: $($_.Thumbprint)"
        }
    }
    if ($null -ne $My.Result) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SecurityInfoCheck]::new($My.Id++, $My.Status, 'PKI', 'ExportablePrivateCertificate', $My.Result, 'Zero strategy')
    "Check $($My.Id - 1): Certificates with private keys should not be exportable together with that key material." | Write-Verbose

    #endregion

    Remove-Variable -Name My -Force -ErrorAction Ignore
}

<# KOMPONENTEN TEST
Update-FormatData -PrependPath '.\Modules\PowerShellBuddy\Public\Test-SecurityState.Format.ps1xml'
Test-SecurityState
Test-SecurityState -Verbose
Test-SecurityState -SkipModuleVersionTest -Verbose
Test-SecurityState -SkipAlternateDataStreamTest -Verbose
Test-SecurityState -SkipModuleVersionTest -SkipAlternateDataStreamTest -Verbose
#>
