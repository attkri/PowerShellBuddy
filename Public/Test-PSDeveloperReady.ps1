function Test-PSDeveloperReady {

    [CmdletBinding()]
    [OutputType([object])]
    param ()

    $ESC = [char]0x1b

    switch -Wildcard ($PSVersionTable.PSVersion.ToString()) {
        '5.1.*' {
            "1. $ESC[32mWindows PowerShell version OK$ESC[!p - Windows PowerShell $ESC[35m$($PSVersionTable.PSVersion)$ESC[!p is supported, but PowerShell 7 is the recommended baseline for current development work."
        }
        '7.*' {
            "1. $ESC[32mPowerShell version OK$ESC[!p - PowerShell $ESC[35m$($PSVersionTable.PSVersion)$ESC[!p matches the current recommended baseline."
        }
        Default {
            "1. $ESC[31mPowerShell version NOT OK$ESC[!p - PowerShell $ESC[35m$($PSVersionTable.PSVersion)$ESC[!p is outdated for current development work. Upgrade to PowerShell 7 or later."
        }
    }

    if ((Get-ExecutionPolicy) -eq [Microsoft.PowerShell.ExecutionPolicy]::RemoteSigned) {
        "2. $ESC[32mExecution policy OK$ESC[!p - The current execution policy $ESC[35m$(Get-ExecutionPolicy)$ESC[!p provides a solid balance between safety and productivity on a PowerShell development machine."
    }
    else {
        "2. $ESC[31mExecution policy NOT OK$ESC[!p - The current execution policy $ESC[35m$(Get-ExecutionPolicy)$ESC[!p should usually be set to RemoteSigned for a balanced development setup. Note: Visual Studio Code may temporarily use Bypass for the process scope."
    }

    if ($PSEdition -eq 'Desktop') {
        $CountNewHelpFiles = Get-ChildItem -Path "$env:windir\System32\WindowsPowerShell\v1.0\en-US" -File -Force -ErrorAction Ignore | Measure-Object | Select-Object -ExpandProperty Count
        if ($CountNewHelpFiles -gt 140) {
            "3. $ESC[32mWindows PowerShell help OK$ESC[!p - Windows PowerShell help files ($ESC[35m$CountNewHelpFiles files$ESC[!p) appear to be available offline."
        }
        else {
            "3. $ESC[31mWindows PowerShell help NOT OK$ESC[!p - Windows PowerShell help files should be available offline. Update them with: $ESC[35mUpdate-Help -Module * -UICulture en-US -Force$ESC[!p"
        }
    }

    if ($PSEdition -eq 'Core') {
        $CountNewHelpFiles = Get-ChildItem -Path "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyDocuments))\PowerShell\Help\en-US" -File -Force -ErrorAction Ignore | Measure-Object | Select-Object -ExpandProperty Count
        if ($CountNewHelpFiles -gt 0) {
            "3. $ESC[32mPowerShell help OK$ESC[!p - PowerShell help files ($ESC[35m$CountNewHelpFiles files$ESC[!p) appear to be available offline."
        }
        else {
            "3. $ESC[31mPowerShell help NOT OK$ESC[!p - PowerShell help files should be available offline. Update them with: $ESC[35mUpdate-Help -Module * -UICulture en-US -Scope CurrentUser -Force$ESC[!p"
        }
    }

    $VSCodeCandidates = @(
        "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile))\AppData\Local\Programs\Microsoft VS Code\code.exe",
        'C:\Program Files\Microsoft VS Code\code.exe'
    )

    $codeCommand = Get-Command -Name 'code' -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source
    if ($codeCommand) {
        $VSCodeCandidates += $codeCommand
    }

    $VSCodeExecutable = $VSCodeCandidates | Where-Object {
        $_ -and (Test-Path -Path $_ -PathType Leaf)
    } | Select-Object -First 1

    $VSCodePath = $null
    $VSCodeProductVersion = $null
    if ($VSCodeExecutable) {
        $VSCodePath = Split-Path -Path $VSCodeExecutable -Parent
        $VSCodeProductVersion = Get-Item -Path $VSCodeExecutable -ErrorAction Ignore |
            Select-Object -ExpandProperty VersionInfo |
            Select-Object -ExpandProperty ProductVersion
    }

    if ($VSCodeProductVersion -and ([version]$VSCodeProductVersion -gt [Version]::new(1, 71, 0, 0))) {
        "4. $ESC[32mVS Code version OK$ESC[!p - Visual Studio Code ($ESC[35m$VSCodePath$ESC[!p) is installed and up to date enough for everyday PowerShell development."
    }
    else {
        "4. $ESC[31mVS Code version NOT OK$ESC[!p - Visual Studio Code is not installed or the detected version $ESC[35m$VSCodeProductVersion$ESC[!p is outdated."
    }

    $VSCodePSExtensionFound = $false

    if ($VSCodePath -and (Test-Path "$VSCodePath\data\extensions\ms-vscode.powershell-*")) {
        $VSCodePSExtensionFound = $true
        "5. $ESC[32mVS Code PowerShell extension OK$ESC[!p - A portable Visual Studio Code installation with the PowerShell extension was found under $ESC[35m$VSCodePath\data\extensions\ms-vscode.powershell-*$ESC[!p."
    }

    if (Test-Path -Path "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile))\.vscode\extensions\ms-vscode.powershell-*") {
        $VSCodePSExtensionFound = $true
        "5. $ESC[32mVS Code PowerShell extension OK$ESC[!p - The current user profile contains the PowerShell extension for Visual Studio Code."
    }

    if (-not $VSCodePSExtensionFound) {
        "5. $ESC[31mVS Code PowerShell extension NOT OK$ESC[!p - The PowerShell extension for Visual Studio Code was not found. Install it from $ESC[35mhttps://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell$ESC[!p."
    }

    $IsElevatedAdminRights = $false
    if ($IsWindows) {
        $CurrentWindowsPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
        $IsElevatedAdminRights = $CurrentWindowsPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')
    }
    elseif ([Environment]::UserName -eq 'root') {
        $IsElevatedAdminRights = $true
    }

    [PSCustomObject]@{ Name = 'Admin rights active'; Value = $IsElevatedAdminRights }
    [PSCustomObject]@{ Name = 'PowerShell edition'; Value = $PSEdition }
    [PSCustomObject]@{ Name = 'PowerShell version'; Value = $PSVersionTable.PSVersion }
    [PSCustomObject]@{ Name = 'PowerShell execution policy'; Value = Get-ExecutionPolicy }

    foreach ($path in ($env:PSModulePath -split [System.IO.Path]::PathSeparator)) {
        [PSCustomObject]@{ Name = 'PowerShell module path'; Value = $path }
    }
}
