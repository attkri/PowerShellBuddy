<<<<<<< HEAD
﻿#Requires -Version 5.1
#Requires -PSEdition Core, Desktop
#Requires -Modules @{ ModuleName="PKI"; ModuleVersion="1.0.0.0" }

using module PKI
using namespace System.Security.Cryptography.X509Certificates

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

class SicherheitInfoCheck {

    [int]    $Id
    [string] $Status
    [string] $Kategorie
    [string] $Test
    [Object] $IST
    [Object] $SOLL

    SicherheitInfoCheck([int]$Id, [string]$Status, [string]$Kategorie, [string]$Test, [Object]$IST, [Object]$SOLL) {
        $this.Id = $Id
        $this.Status = $Status
        $this.Kategorie = $Kategorie
        $this.Test = $Test
        $this.IST = $IST
        $this.SOLL = $SOLL
    }
}

function IstZertifikatExportierbar {
    param([X509Certificate2]$Cert)
    try {
        $Cert.Export(([X509ContentType]::Pfx)) | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Test-SecurityState {

    <#
    .SYNOPSIS
    Analysiert das aktuelle System auch Sicherheitsschwachstellen in Verbindung mit PowerShell.

    .OUTPUTS
    Analyseergebnis wird per [SicherheitInfoCheck]-Objekt zurückgegeben. Erklärende Informationen erhältst Du per -Verbose-Meldung

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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock','')]
    [CmdletBinding()]
    param(
        # Überspringt die zeitaufwändige Modul-Versions-Test zu der eine Internet-Verbindung bestehen muss.
        [switch]$SkipModuleVersionTest,

        # Überspringt die zeitaufwändige Alternate-Data-Stream-Test.
        [switch]$SkipAlternateDataStreamTest
    )

    $My = [HashTable]::Synchronized(@{})
    $My.ESC = [char]0x1b
    $My.Status = $null
    $My.Result = $null
    $My.TargetResult = $null
    $My.Id = 1
    $My.Neutral = "Neutral"
    $My.Passed = "$($My.ESC)[92mBestanden$($My.ESC)[0m"
    $My.Failed = "$($My.ESC)[91mDurchgefallen$($My.ESC)[0m"
    $My.Skip = "$($My.ESC)[95mÜbersprungen$($My.ESC)[0m"
    $my.IsAdminRights = (New-Object -TypeName Security.Principal.WindowsPrincipal -ArgumentLIST ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::AdminISTrator)

    #region Allgemein

    [SicherheitInfoCheck]::new($My.Id++, $My.Neutral, 'Allgemein', 'PSEdition', $PSVersionTable.PSEdition, '')
    "Zu $($My.Id - 1)) Weitere Details siehe about_PowerShell_Editions" | Write-Verbose

    if ($PSVersionTable.PSVersion -le [Version]"2.0.0.0") { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SicherheitInfoCheck]::new($My.Id++ , $My.Status, 'Allgemein', 'PSVersion', $PSVersionTable.PSVersion, '-gt 2.0')
    "Zu $($My.Id - 1)) Schutzmechaniken können in Windows PowerShell 2.0 umgangen werden, daher diese Versionen unter Windows-Feature-/Optionen deaktivieren." | Write-Verbose

    [SicherheitInfoCheck]::new($My.Id++, $My.Neutral, 'Allgemein', 'Platform', $PSVersionTable.Platform, '')

    [SicherheitInfoCheck]::new($My.Id++, $My.Neutral, 'Allgemein', 'CurrentPSHost', (Get-Host | Select-Object -ExpandProperty Name), '')
    "Zu $($My.Id - 1)) weitere PowerShell-Hosts können sein: ConsoleHost, Visual Studio Code Host, Windows PowerShell ISE Host, etc." | Write-Verbose

    if ($ExecutionContext.SessionState.LanguageMode -ieq "FullLanguage") { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Allgemein', 'PSSessionLanguageMode', ($ExecutionContext.SessionState.LanguageMode), 'ConstrainedLanguage')
    "Zu $($My.Id - 1)) Weitere Details siehe about_Language_Modes" | Write-Verbose

    if ((Get-ExecutionPolicy) -ine "AllSigned") { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Allgemein', 'ExecutionPolicy', (Get-ExecutionPolicy), 'AllSigned')
    "Zu $($My.Id - 1)) *Policy sollte auf AllSigned stehen. Für PSEntwickler empfiehlt sich RemoteSigned" | Write-Verbose

    if ($my.IsAdminRights) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Allgemein', 'Erhöhte Admin-Rechte', $my.IsAdminRights, $false)

    #endregion

    #region PROFILE

    $my.Result = Test-Path -Path $PROFILE.AllUsersAllHosts -PathType Leaf
    if ($My.Result) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Profile-Datei vorhanden', 'AllUsersAllHosts', $My.Result, $false)

    $my.Result = Test-Path -Path $PROFILE.AllUsersCurrentHost -PathType Leaf
    if ($My.Result) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Profile-Datei vorhanden', 'AllUsersCurrentHost', $My.Result, $false)
    "Zu $($My.Id - 1)) Auch PFade in anderen PowerShell-Hosts (s.o.) testen." | Write-Verbose

    $my.Result = Test-Path -Path $PROFILE.CurrentUserAllHosts -PathType Leaf
    if ($My.Result) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Profile-Datei vorhanden', 'CurrentUserAllHosts', $My.Result, $false)

    $my.Result = Test-Path -Path $PROFILE.CurrentUserCurrentHost -PathType Leaf
    if ($My.Result) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Profile-Datei vorhanden', 'CurrentUserCurrentHost', $My.Result, $false)
    "Zu $($My.Id - 1)) Auch PFade in anderen PowerShell-Hosts (s.o.) testen." | Write-Verbose

    #endregion

    #region Microsoft Defender Antivirus

    $my.Result = Get-MpPreference | Select-Object -ExpandProperty ExclusionPath
    if ($null -ne $My.Result) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status , 'Defender', 'ExclusionPath', $My.Result, 'No Exclusion Paths')

    #endregion

    #region Module Version Check

    $My.Status = $my.Skip ; $My.Result = "Test übersprungen" ; $My.TargetResult = "Test übersprungen"
    if (-not $SkipModuleVersionTest) {
        $My.Status = $My.Passed ; $My.Result = "unnötig in PowerShell 7" ; $My.TargetResult = "unnötig in PowerShell 7"
        if (-not $PSVersionTable.PSVersion -ge 6) {
            $My.Result = (Get-PackageProvider -Name NuGet).Version
            $My.TargetResult = (Find-PackageProvider -Name NuGet).Version
            if ($My.Result -le $My.TargetResult) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
        }
    }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'PackageProvider', 'NuGet', $My.Result, $My.TargetResult)
    "Zu $($My.Id - 1)) Nur in Windows PowerShell 5.1 wichtig." | Write-Verbose

    #endregion

    #region Module Version Check

    $My.Status = $my.Skip ; $My.Result = "Test übersprungen" ; $My.TargetResult = "Test übersprungen"
    if (-not $SkipModuleVersionTest) {
        $My.Result = (Get-Module -Name PackageManagement -LISTAvailable -Verbose:$false).Version | Sort-Object -Descending | Select-Object -First 1
        $My.TargetResult = [Version](Find-Module -Name PackageManagement).Version
        if ($My.Result -lt $My.TargetResult) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Module', 'PackageManagement', $My.Result, $My.TargetResult)

    $My.Status = $my.Skip ; $My.Result = "Test übersprungen" ; $My.TargetResult = "Test übersprungen"
    if (-not $SkipModuleVersionTest) {
        $My.Result = (Get-Module -Name PowerShellGet -LISTAvailable -Verbose:$false).Version | Sort-Object -Descending | Select-Object -First 1
        $My.TargetResult = [Version](Find-Module -Name PowerShellGet).Version
        if ($My.Result -lt $My.TargetResult) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Module', 'PowerShellGet', $My.Result, $My.TargetResult)

    $My.Status = $my.Skip ; $My.Result = "Test übersprungen" ; $My.TargetResult = "Test übersprungen"
    if (-not $SkipModuleVersionTest) {
        $My.Result = (Get-Module -Name PSScriptAnalyzer -LISTAvailable -Verbose:$false).Version | Sort-Object -Descending | Select-Object -First 1
        $My.TargetResult = [Version](Find-Module -Name PSScriptAnalyzer).Version
        if ($My.Result -lt $My.TargetResult) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Module', 'PSScriptAnalyzer', $My.Result, $My.TargetResult)

    $My.Status = $my.Skip ; $My.Result = "Test übersprungen" ; $My.TargetResult = "Test übersprungen"
    if (-not $SkipModuleVersionTest) {
        $My.Result = (Get-Module -Name Pester -LISTAvailable -Verbose:$false).Version | Sort-Object -Descending | Select-Object -First 1
        $My.TargetResult = [Version](Find-Module -Name Pester).Version
        if ($My.Result -lt $My.TargetResult) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Module', 'Pester', $My.Result, $My.TargetResult)

    #endregion

    #region ScriptBlockLogging

    $My.Result = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'EnableScriptBlockLogging' -ErrorAction SilentlyContinue
    if ($My.Result -eq 1) { $My.Status = $My.Passed } else { $My.Status = $My.Failed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'ScriptBlockLogging', 'Windows PowerShell 64bit', $My.Result, 1)
    "Zu $($My.Id - 1)) ScriptBlockLogging sollte inkl. Verschlüsselung aktiviert werden. Für weitere Details siehe about_Logging_Windows." | Write-Verbose
    
    $My.Result = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'EnableScriptBlockLogging' -ErrorAction SilentlyContinue
    if ($My.Result -eq 1) { $My.Status = $My.Passed } else { $My.Status = $My.Failed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'ScriptBlockLogging', 'Windows PowerShell 32bit', $My.Result, 1)
    "Zu $($My.Id - 1)) ScriptBlockLogging sollte inkl. Verschlüsselung aktiviert werden. Für weitere Details siehe about_Logging_Windows." | Write-Verbose

    $My.Result = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\PowerShellCore\ScriptBlockLogging' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'EnableScriptBlockLogging' -ErrorAction SilentlyContinue
    if ($My.Result -eq 1) { $My.Status = $My.Passed } else { $My.Status = $My.Failed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'ScriptBlockLogging', 'PowerShell 6+ 64bit', $My.Result, 1)
    "Zu $($My.Id - 1)) ScriptBlockLogging sollte inkl. Verschlüsselung aktiviert werden. Für weitere Details siehe about_Logging_Windows." | Write-Verbose
    
    #endregion

    #region Just Enough Administration

    if($my.IsAdminRights) {
        $My.Result = Get-PSSessionConfiguration -Verbose:$false | Where-Object -Property Name -NotMatch -Value 'PowerShell' | Select-Object -ExpandProperty Name; $sc -join ', '
    } else {
        "Zu $($My.Id - 1)) ACHTUNG! Keine Admin-Rechte zum testen vorhanden. Führe diesen Test erneut mit Admin-Rechten aus." | Write-Warning
        $My.Result = "n/v"
    }
    [SicherheitInfoCheck]::new($My.Id++, $My.Neutral, 'JEA', 'SessionConfigurations', $my.Result, '')
    "Zu $($My.Id - 1)) Das Einrichten von JEA für Nicht-Administratoren/Konten mit administrativen Aufgaben anstreben." | Write-Verbose

    #endregion

    #region Alternate Data Stream

    $My.Status = $My.Skip; $My.Result = "Test übersprungen"
    if (-not $SkipAlternateDataStreamTest) {
        $My.CountFiles = Get-ChildItem -Path 'C:\' -File -Force -ErrorAction Ignore -Recurse | Measure-Object | Select-Object -ExpandProperty Count
        $My.CurrentCounter = 1
        $My.Status = $My.Neutral
        $My.Result = Get-ChildItem -Path c:\ -File -Force -Recurse -ErrorAction Ignore | ForEach-Object -Process {
            Write-Progress -Activity 'Scanne Dateien nach Alternate Data Stream''s' -Status $My.CurrentCounter -PercentComplete ([System.Math]::Floor(($My.CurrentCounter++) / $My.CountFiles * 100))
            try { Get-Item -Path $_.FullName -Stream * -ErrorAction Ignore | Where-Object -Property Stream -ne ':$DATA' } catch {  }
        } | Group-Object -Property Stream | Sort-Object -Descending Count | Select-Object -Property Count, Name, @{Name = 'Sum'; Expression = { ($_.Group | Measure-Object -Property Length -Sum | Select-Object -ExpandProperty SumLengthKB) / 1KB } }, Group
        Write-Progress -Activity 'Scanne Dateien nach Alternate Data Stream''s' -Completed
    }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Alternate Data Stream', 'Gruppiert IST', $My.Result, 'Zero ADS Strategy')
    "Zu $($My.Id - 1)) Auffällige / Große ADS-Dateien manuell prüfen. Siehe das gruppierte Ergebnis der IST-Eigenschaft." | Write-Verbose

    #endregion

    #region PKI

    $My.Result = Get-ChildItem -Path 'Cert:\' -Recurse -Force | Where-Object -Property 'HasPrivateKey' | ForEach-Object -Process {
        if ((IstZertifikatExportierbar $_)) {
            return "SUBJECT: $($_.Subject) THUMBPRINT: $($_.Thumbprint)"
        }
    }
    if ($null -ne $My.Result) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'PKI', 'ExportablePrivateCertificate', $My.Result, 'Zero Strategie')
    "Zu $($My.Id - 1)) Zertifikate mit privatem Schlüssel sollten mit diesem nicht exportierbar sein." | Write-Verbose

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

=======
﻿#Requires -Version 5.1
#Requires -PSEdition Core, Desktop
#Requires -Modules @{ ModuleName="PKI"; ModuleVersion="1.0.0.0" }

using module PKI
using namespace System.Security.Cryptography.X509Certificates

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

class SicherheitInfoCheck {

    [int]    $Id
    [string] $Status
    [string] $Kategorie
    [string] $Test
    [Object] $IST
    [Object] $SOLL

    SicherheitInfoCheck([int]$Id, [string]$Status, [string]$Kategorie, [string]$Test, [Object]$IST, [Object]$SOLL) {
        $this.Id = $Id
        $this.Status = $Status
        $this.Kategorie = $Kategorie
        $this.Test = $Test
        $this.IST = $IST
        $this.SOLL = $SOLL
    }
}

function IstZertifikatExportierbar {
    param([X509Certificate2]$Cert)
    try {
        $Cert.Export(([X509ContentType]::Pfx)) | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Test-SecurityState {

    <#
    .SYNOPSIS
    Analysiert das aktuelle System auch Sicherheitsschwachstellen in Verbindung mit PowerShell.

    .OUTPUTS
    Analyseergebnis wird per [SicherheitInfoCheck]-Objekt zurückgegeben. Erklärende Informationen erhältst Du per -Verbose-Meldung

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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock','')]
    [CmdletBinding()]
    param(
        # Überspringt die zeitaufwändige Modul-Versions-Test zu der eine Internet-Verbindung bestehen muss.
        [switch]$SkipModuleVersionTest,

        # Überspringt die zeitaufwändige Alternate-Data-Stream-Test.
        [switch]$SkipAlternateDataStreamTest
    )

    $My = [HashTable]::Synchronized(@{})
    $My.ESC = [char]0x1b
    $My.Status = $null
    $My.Result = $null
    $My.TargetResult = $null
    $My.Id = 1
    $My.Neutral = "Neutral"
    $My.Passed = "$($My.ESC)[92mBestanden$($My.ESC)[0m"
    $My.Failed = "$($My.ESC)[91mDurchgefallen$($My.ESC)[0m"
    $My.Skip = "$($My.ESC)[95mÜbersprungen$($My.ESC)[0m"
    $my.IsAdminRights = (New-Object -TypeName Security.Principal.WindowsPrincipal -ArgumentLIST ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::AdminISTrator)

    #region Allgemein

    [SicherheitInfoCheck]::new($My.Id++, $My.Neutral, 'Allgemein', 'PSEdition', $PSVersionTable.PSEdition, '')
    "Zu $($My.Id - 1)) Weitere Details siehe about_PowerShell_Editions" | Write-Verbose

    if ($PSVersionTable.PSVersion -le [Version]"2.0.0.0") { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SicherheitInfoCheck]::new($My.Id++ , $My.Status, 'Allgemein', 'PSVersion', $PSVersionTable.PSVersion, '-gt 2.0')
    "Zu $($My.Id - 1)) Schutzmechaniken können in Windows PowerShell 2.0 umgangen werden, daher diese Versionen unter Windows-Feature-/Optionen deaktivieren." | Write-Verbose

    [SicherheitInfoCheck]::new($My.Id++, $My.Neutral, 'Allgemein', 'Platform', $PSVersionTable.Platform, '')

    [SicherheitInfoCheck]::new($My.Id++, $My.Neutral, 'Allgemein', 'CurrentPSHost', (Get-Host | Select-Object -ExpandProperty Name), '')
    "Zu $($My.Id - 1)) weitere PowerShell-Hosts können sein: ConsoleHost, Visual Studio Code Host, Windows PowerShell ISE Host, etc." | Write-Verbose

    if ($ExecutionContext.SessionState.LanguageMode -ieq "FullLanguage") { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Allgemein', 'PSSessionLanguageMode', ($ExecutionContext.SessionState.LanguageMode), 'ConstrainedLanguage')
    "Zu $($My.Id - 1)) Weitere Details siehe about_Language_Modes" | Write-Verbose

    if ((Get-ExecutionPolicy) -ine "AllSigned") { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Allgemein', 'ExecutionPolicy', (Get-ExecutionPolicy), 'AllSigned')
    "Zu $($My.Id - 1)) *Policy sollte auf AllSigned stehen. Für PSEntwickler empfiehlt sich RemoteSigned" | Write-Verbose

    if ($my.IsAdminRights) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Allgemein', 'Erhöhte Admin-Rechte', $my.IsAdminRights, $false)

    #endregion

    #region PROFILE

    $my.Result = Test-Path -Path $PROFILE.AllUsersAllHosts -PathType Leaf
    if ($My.Result) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Profile-Datei vorhanden', 'AllUsersAllHosts', $My.Result, $false)

    $my.Result = Test-Path -Path $PROFILE.AllUsersCurrentHost -PathType Leaf
    if ($My.Result) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Profile-Datei vorhanden', 'AllUsersCurrentHost', $My.Result, $false)
    "Zu $($My.Id - 1)) Auch PFade in anderen PowerShell-Hosts (s.o.) testen." | Write-Verbose

    $my.Result = Test-Path -Path $PROFILE.CurrentUserAllHosts -PathType Leaf
    if ($My.Result) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Profile-Datei vorhanden', 'CurrentUserAllHosts', $My.Result, $false)

    $my.Result = Test-Path -Path $PROFILE.CurrentUserCurrentHost -PathType Leaf
    if ($My.Result) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Profile-Datei vorhanden', 'CurrentUserCurrentHost', $My.Result, $false)
    "Zu $($My.Id - 1)) Auch PFade in anderen PowerShell-Hosts (s.o.) testen." | Write-Verbose

    #endregion

    #region Microsoft Defender Antivirus

    $my.Result = Get-MpPreference | Select-Object -ExpandProperty ExclusionPath
    if ($null -ne $My.Result) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status , 'Defender', 'ExclusionPath', $My.Result, 'No Exclusion Paths')

    #endregion

    #region Module Version Check

    $My.Status = $my.Skip ; $My.Result = "Test übersprungen" ; $My.TargetResult = "Test übersprungen"
    if (-not $SkipModuleVersionTest) {
        $My.Status = $My.Passed ; $My.Result = "unnötig in PowerShell 7" ; $My.TargetResult = "unnötig in PowerShell 7"
        if (-not $PSVersionTable.PSVersion -ge 6) {
            $My.Result = (Get-PackageProvider -Name NuGet).Version
            $My.TargetResult = (Find-PackageProvider -Name NuGet).Version
            if ($My.Result -le $My.TargetResult) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
        }
    }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'PackageProvider', 'NuGet', $My.Result, $My.TargetResult)
    "Zu $($My.Id - 1)) Nur in Windows PowerShell 5.1 wichtig." | Write-Verbose

    #endregion

    #region Module Version Check

    $My.Status = $my.Skip ; $My.Result = "Test übersprungen" ; $My.TargetResult = "Test übersprungen"
    if (-not $SkipModuleVersionTest) {
        $My.Result = (Get-Module -Name PackageManagement -LISTAvailable -Verbose:$false).Version | Sort-Object -Descending | Select-Object -First 1
        $My.TargetResult = [Version](Find-Module -Name PackageManagement).Version
        if ($My.Result -lt $My.TargetResult) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Module', 'PackageManagement', $My.Result, $My.TargetResult)

    $My.Status = $my.Skip ; $My.Result = "Test übersprungen" ; $My.TargetResult = "Test übersprungen"
    if (-not $SkipModuleVersionTest) {
        $My.Result = (Get-Module -Name PowerShellGet -LISTAvailable -Verbose:$false).Version | Sort-Object -Descending | Select-Object -First 1
        $My.TargetResult = [Version](Find-Module -Name PowerShellGet).Version
        if ($My.Result -lt $My.TargetResult) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Module', 'PowerShellGet', $My.Result, $My.TargetResult)

    $My.Status = $my.Skip ; $My.Result = "Test übersprungen" ; $My.TargetResult = "Test übersprungen"
    if (-not $SkipModuleVersionTest) {
        $My.Result = (Get-Module -Name PSScriptAnalyzer -LISTAvailable -Verbose:$false).Version | Sort-Object -Descending | Select-Object -First 1
        $My.TargetResult = [Version](Find-Module -Name PSScriptAnalyzer).Version
        if ($My.Result -lt $My.TargetResult) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Module', 'PSScriptAnalyzer', $My.Result, $My.TargetResult)

    $My.Status = $my.Skip ; $My.Result = "Test übersprungen" ; $My.TargetResult = "Test übersprungen"
    if (-not $SkipModuleVersionTest) {
        $My.Result = (Get-Module -Name Pester -LISTAvailable -Verbose:$false).Version | Sort-Object -Descending | Select-Object -First 1
        $My.TargetResult = [Version](Find-Module -Name Pester).Version
        if ($My.Result -lt $My.TargetResult) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Module', 'Pester', $My.Result, $My.TargetResult)

    #endregion

    #region ScriptBlockLogging

    $My.Result = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'EnableScriptBlockLogging' -ErrorAction SilentlyContinue
    if ($My.Result -eq 1) { $My.Status = $My.Passed } else { $My.Status = $My.Failed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'ScriptBlockLogging', 'Windows PowerShell 64bit', $My.Result, 1)
    "Zu $($My.Id - 1)) ScriptBlockLogging sollte inkl. Verschlüsselung aktiviert werden. Für weitere Details siehe about_Logging_Windows." | Write-Verbose
    
    $My.Result = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'EnableScriptBlockLogging' -ErrorAction SilentlyContinue
    if ($My.Result -eq 1) { $My.Status = $My.Passed } else { $My.Status = $My.Failed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'ScriptBlockLogging', 'Windows PowerShell 32bit', $My.Result, 1)
    "Zu $($My.Id - 1)) ScriptBlockLogging sollte inkl. Verschlüsselung aktiviert werden. Für weitere Details siehe about_Logging_Windows." | Write-Verbose

    $My.Result = Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\PowerShellCore\ScriptBlockLogging' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'EnableScriptBlockLogging' -ErrorAction SilentlyContinue
    if ($My.Result -eq 1) { $My.Status = $My.Passed } else { $My.Status = $My.Failed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'ScriptBlockLogging', 'PowerShell 6+ 64bit', $My.Result, 1)
    "Zu $($My.Id - 1)) ScriptBlockLogging sollte inkl. Verschlüsselung aktiviert werden. Für weitere Details siehe about_Logging_Windows." | Write-Verbose
    
    #endregion

    #region Just Enough Administration

    if($my.IsAdminRights) {
        $My.Result = Get-PSSessionConfiguration -Verbose:$false | Where-Object -Property Name -NotMatch -Value 'PowerShell' | Select-Object -ExpandProperty Name; $sc -join ', '
    } else {
        "Zu $($My.Id - 1)) ACHTUNG! Keine Admin-Rechte zum testen vorhanden. Führe diesen Test erneut mit Admin-Rechten aus." | Write-Warning
        $My.Result = "n/v"
    }
    [SicherheitInfoCheck]::new($My.Id++, $My.Neutral, 'JEA', 'SessionConfigurations', $my.Result, '')
    "Zu $($My.Id - 1)) Das Einrichten von JEA für Nicht-Administratoren/Konten mit administrativen Aufgaben anstreben." | Write-Verbose

    #endregion

    #region Alternate Data Stream

    $My.Status = $My.Skip; $My.Result = "Test übersprungen"
    if (-not $SkipAlternateDataStreamTest) {
        $My.CountFiles = Get-ChildItem -Path 'C:\' -File -Force -ErrorAction Ignore -Recurse | Measure-Object | Select-Object -ExpandProperty Count
        $My.CurrentCounter = 1
        $My.Status = $My.Neutral
        $My.Result = Get-ChildItem -Path c:\ -File -Force -Recurse -ErrorAction Ignore | ForEach-Object -Process {
            Write-Progress -Activity 'Scanne Dateien nach Alternate Data Stream''s' -Status $My.CurrentCounter -PercentComplete ([System.Math]::Floor(($My.CurrentCounter++) / $My.CountFiles * 100))
            try { Get-Item -Path $_.FullName -Stream * -ErrorAction Ignore | Where-Object -Property Stream -ne ':$DATA' } catch {  }
        } | Group-Object -Property Stream | Sort-Object -Descending Count | Select-Object -Property Count, Name, @{Name = 'Sum'; Expression = { ($_.Group | Measure-Object -Property Length -Sum | Select-Object -ExpandProperty SumLengthKB) / 1KB } }, Group
        Write-Progress -Activity 'Scanne Dateien nach Alternate Data Stream''s' -Completed
    }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'Alternate Data Stream', 'Gruppiert IST', $My.Result, 'Zero ADS Strategy')
    "Zu $($My.Id - 1)) Auffällige / Große ADS-Dateien manuell prüfen. Siehe das gruppierte Ergebnis der IST-Eigenschaft." | Write-Verbose

    #endregion

    #region PKI

    $My.Result = Get-ChildItem -Path 'Cert:\' -Recurse -Force | Where-Object -Property 'HasPrivateKey' | ForEach-Object -Process {
        if ((IstZertifikatExportierbar $_)) {
            return "SUBJECT: $($_.Subject) THUMBPRINT: $($_.Thumbprint)"
        }
    }
    if ($null -ne $My.Result) { $My.Status = $My.Failed } else { $My.Status = $My.Passed }
    [SicherheitInfoCheck]::new($My.Id++, $My.Status, 'PKI', 'ExportablePrivateCertificate', $My.Result, 'Zero Strategie')
    "Zu $($My.Id - 1)) Zertifikate mit privatem Schlüssel sollten mit diesem nicht exportierbar sein." | Write-Verbose

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

>>>>>>> 47bdafb926307894e343ff9720d2bc56b970228c
