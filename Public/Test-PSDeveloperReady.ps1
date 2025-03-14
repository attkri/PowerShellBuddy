<<<<<<< HEAD
﻿function Test-PSDeveloperReady {

    [CmdletBinding()]
    [OutputType([String])]
    param ( )

    $ESC = [char]0x1b

    #region 1. (Windows) PowerShell Version

    switch -Wildcard ($PSVersionTable.PSVersion) {
        '5.1.*' {
            "1. $ESC[32mWindows PowerShell Version OK$ESC[!p - Die Windows PowerShell Version $ESC[35m$($PSVersionTable.PSVersion)$ESC[!p ist aktuell aber nicht mehr Stand der Technik steigen Sie besser auf PowerShell 7 um."
        }
        '7.*' {
            "1. $ESC[32mPowerShell Version OK$ESC[!p - Die PowerShell Version $ESC[35m$($PSVersionTable.PSVersion)$ESC[!p entspricht dem aktuellem Standard."
        }
        Default {
            "1. $ESC[31mPowerSell Version NICHT OK$ESC[!p - Die PowerShell Version $ESC[35m$($PSVersionTable.PSVersion)$ESC[!p entspricht nicht mehr dem aktuellem Standard. Aktualisieren Sie auf PowerShell 7 oder höher."
        }
    }

    #endregion

    #region 2. Execution Policy RemoteSinged

    if ((Get-ExecutionPolicy) -eq [Microsoft.PowerShell.ExecutionPolicy]::RemoteSigned) {
        "2. $ESC[32mAusführungsrichtlinien OK$ESC[!p - Die aktuellen Ausführungsrichtlinien $ESC[35m$(Get-ExecutionPolicy)$ESC[!p sind eine gesunde Mischung zwischen Sicherheit und Produktivität auf einem PowerShell-Entwicklungs-PC."
    }
    else {
        "2. $ESC[31mAusführungsrichtlinien NICHT OK$ESC[!p - Die aktuellen Ausführungsrichtlinien $ESC[35m$(Get-ExecutionPolicy)$ESC[!p sollten auf RemoteSigned gestellt werden, um eine gesunde Mischung zwischen Sicherheit und Produktivität auf einem PowerShell-Entwicklungs-PC einzustellen. (Anmerkung: Visual Studio Code stellt aktuell den Scope Process auf ByPass.)"
    }

    #endregion

    #region 3. PowerShell Hilfe-Dateien

    if ($PSEdition -eq 'Desktop') {
        $CountNewHelpFiles = Get-ChildItem -Path "$env:windir\System32\WindowsPowerShell\v1.0\en-US" -File -Force -ErrorAction 'Ignore' | Measure-Object | Select-Object -ExpandProperty 'Count'
        if ($CountNewHelpFiles -gt 140) {
            "3. $ESC[32mWindows PowerShell Hilfe OK$ESC[!p - Die Windows PowerShell-Hilfe-Dateien ($ESC[35m$CountNewHelpFiles St.$ESC[!p) scheinen offline zur Verfügung stehen."
        }
        else {
            "3. $ESC[31mWindows PowerShell Hilfe NICHT OK$ESC[!p - Die Windows PowerShell-Hilfe-Dateien sollten offline zur Verfügung stehen. Aktualisieren Sie (Admin-Rechte nötig) diese über: $ESC[35mUpdate-Help -Module * -UICulture en-US -Force$ESC[!p"
        }
    }

    if ($PSEdition -eq 'Core') {
        $CountNewHelpFiles = Get-ChildItem -Path "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyDocuments))\PowerShell\Help\en-US" -File -Force -ErrorAction 'Ignore' | Measure-Object | Select-Object -ExpandProperty 'Count'
        if ($CountNewHelpFiles -gt 0) {
            "3. $ESC[32mPowerShell Hilfe OK$ESC[!p - Die PowerShell-Hilfe-Dateien ($ESC[35m$CountNewHelpFiles St.$ESC[!p) scheinen offline zur Verfügung stehen."
        }
        else {
            "3. $ESC[31mPowerShell Hilfe NICHT OK$ESC[!p - PowerShell-Hilfe-Dateien sollten offline zur Verfügung stehen. Aktualisieren Sie diese über: Update-Help -Module * -UICulture en-US -Scope CurrentUser -Force"
        }
    }

    #endregion

    #region 4. VSCode als aktuelle Version installiert

    $VSCodePath = "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile))\AppData\Local\Programs\Microsoft VS Code"
    if (-not (Test-Path -Path $VSCodePath)) {
        $VSCodePath = 'C:\Program Files\Microsoft VS Code'
    }
    if (-not (Test-Path -Path $VSCodePath)) {
        $VSCodePath = Get-ChildItem -Path "$env:SystemDrive\" -Recurse -File -ErrorAction 'Ignore' | Where-Object -Property 'Name' -EQ -Value 'code.exe' | Select-Object -First 1 -ExpandProperty 'DirectoryName'
    }

    $VSCodeProductVersion = Get-Item -Path "$VSCodePath\code.exe" -ErrorAction 'Ignore' | Select-Object -ExpandProperty 'VersionInfo' | Select-Object -ExpandProperty 'ProductVersion'
    if ($VSCodeProductVersion -gt [Version]::new(1, 71, 0, 0)) {
        "4. $ESC[32mVSCode Version OK$ESC[!p - Ihr Visual Studio Code ($ESC[35m$VSCodePath$ESC[!p) ist auf einem aktuellen Stand ($VSCodeProductVersion)."
    }
    else {
        "4. $ESC[31mVSCode Version NICHT OK$ESC[!p - Visual Studio Code ist auf Ihrem System nicht vorhanden oder die Version $ESC[35m$VSCodeProductVersion$ESC[!p ist veraltet."
    }

    #endregion

    #region 5. Visual Studio Code Erweiterungen installiert

    $VSCodePSExtensionFounded = $false

    if (Test-Path "$VSCodePath\data\extensions\ms-vscode.powershell-*") {
        $VSCodePSExtensionFounded = $true
        "5. $ESC[32mVSCode-PS-Erweiterung OK$ESC[!p - Es wurde Visual Studio Code auf dem aktuellen PC gefunden dessen Programm-Ordner enthält die PowerShell-Erweiterung ($ESC[35m$VSCodePath\data\extensions\ms-vscode.powershell-*$ESC[!p) für Visual Studio Code. Es wird davon ausgegangen das Visual Studio Code als TO-GO-Variante korrekt installiert und konfiguriert wurde."
    }

    if (Test-Path -Path "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile))\.vscode\extensions\ms-vscode.powershell-*") {
        $VSCodePSExtensionFounded = $true
        "5. $ESC[32mVSCode-PS-Erweiterung OK$ESC[!p - Der PC enthält im aktuellen Benutzer-Profil ($ESC[35m$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile))$ESC[!p) die PowerShell-Erweiterung für Visual Studio Code. Es wird davon ausgegangen das Visual Studio Code auf diesem System korrekt installiert und konfiguriert wurde."
    }

    if (-not $VSCodePSExtensionFounded) {
        "5. $ESC[31mVSCode-PS-Erweiterung NICHT OK$ESC[!p - Zur Visual Studio Code-Installation wurde die PowerShell-Erweiterung nicht gefunden. Dies kann über $ESC[35mhttps://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell$ESC[!p installiert werden."
    }

    #endregion

    #region Wichtige Infos aufzeigen

    $CurrentWindowsPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    $IsElevatedAdminRights = $CurrentWindowsPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')
    [PSCustomObject]@{ Name = 'Admin Rechte aktiv' ; Value = $IsElevatedAdminRights }

    [PSCustomObject]@{ Name = 'PowerShell Edition' ; Value = $PSEdition }

    [PSCustomObject]@{ Name = 'PowerShell Version' ; Value = $PSVersionTable.PSVersion }

    [PSCustomObject]@{ Name = 'PowerShell Execution Policy' ; Value = Get-ExecutionPolicy }

    foreach ($path in ($env:PSModulePath -split ';')) {
        [PSCustomObject]@{ Name = 'PowerShell Module Path' ; Value = $path }
    }

    #endregion
}
=======
﻿function Test-PSDeveloperReady {

    [CmdletBinding()]
    [OutputType([String])]
    param ( )

    $ESC = [char]0x1b

    #region 1. (Windows) PowerShell Version

    switch -Wildcard ($PSVersionTable.PSVersion) {
        '5.1.*' {
            "1. $ESC[32mWindows PowerShell Version OK$ESC[!p - Die Windows PowerShell Version $ESC[35m$($PSVersionTable.PSVersion)$ESC[!p ist aktuell aber nicht mehr Stand der Technik steigen Sie besser auf PowerShell 7 um."
        }
        '7.*' {
            "1. $ESC[32mPowerShell Version OK$ESC[!p - Die PowerShell Version $ESC[35m$($PSVersionTable.PSVersion)$ESC[!p entspricht dem aktuellem Standard."
        }
        Default {
            "1. $ESC[31mPowerSell Version NICHT OK$ESC[!p - Die PowerShell Version $ESC[35m$($PSVersionTable.PSVersion)$ESC[!p entspricht nicht mehr dem aktuellem Standard. Aktualisieren Sie auf PowerShell 7 oder höher."
        }
    }

    #endregion

    #region 2. Execution Policy RemoteSinged

    if ((Get-ExecutionPolicy) -eq [Microsoft.PowerShell.ExecutionPolicy]::RemoteSigned) {
        "2. $ESC[32mAusführungsrichtlinien OK$ESC[!p - Die aktuellen Ausführungsrichtlinien $ESC[35m$(Get-ExecutionPolicy)$ESC[!p sind eine gesunde Mischung zwischen Sicherheit und Produktivität auf einem PowerShell-Entwicklungs-PC."
    }
    else {
        "2. $ESC[31mAusführungsrichtlinien NICHT OK$ESC[!p - Die aktuellen Ausführungsrichtlinien $ESC[35m$(Get-ExecutionPolicy)$ESC[!p sollten auf RemoteSigned gestellt werden, um eine gesunde Mischung zwischen Sicherheit und Produktivität auf einem PowerShell-Entwicklungs-PC einzustellen. (Anmerkung: Visual Studio Code stellt aktuell den Scope Process auf ByPass.)"
    }

    #endregion

    #region 3. PowerShell Hilfe-Dateien

    if ($PSEdition -eq 'Desktop') {
        $CountNewHelpFiles = Get-ChildItem -Path "$env:windir\System32\WindowsPowerShell\v1.0\en-US" -File -Force -ErrorAction 'Ignore' | Measure-Object | Select-Object -ExpandProperty 'Count'
        if ($CountNewHelpFiles -gt 140) {
            "3. $ESC[32mWindows PowerShell Hilfe OK$ESC[!p - Die Windows PowerShell-Hilfe-Dateien ($ESC[35m$CountNewHelpFiles St.$ESC[!p) scheinen offline zur Verfügung stehen."
        }
        else {
            "3. $ESC[31mWindows PowerShell Hilfe NICHT OK$ESC[!p - Die Windows PowerShell-Hilfe-Dateien sollten offline zur Verfügung stehen. Aktualisieren Sie (Admin-Rechte nötig) diese über: $ESC[35mUpdate-Help -Module * -UICulture en-US -Force$ESC[!p"
        }
    }

    if ($PSEdition -eq 'Core') {
        $CountNewHelpFiles = Get-ChildItem -Path "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::MyDocuments))\PowerShell\Help\en-US" -File -Force -ErrorAction 'Ignore' | Measure-Object | Select-Object -ExpandProperty 'Count'
        if ($CountNewHelpFiles -gt 0) {
            "3. $ESC[32mPowerShell Hilfe OK$ESC[!p - Die PowerShell-Hilfe-Dateien ($ESC[35m$CountNewHelpFiles St.$ESC[!p) scheinen offline zur Verfügung stehen."
        }
        else {
            "3. $ESC[31mPowerShell Hilfe NICHT OK$ESC[!p - PowerShell-Hilfe-Dateien sollten offline zur Verfügung stehen. Aktualisieren Sie diese über: Update-Help -Module * -UICulture en-US -Scope CurrentUser -Force"
        }
    }

    #endregion

    #region 4. VSCode als aktuelle Version installiert

    $VSCodePath = "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile))\AppData\Local\Programs\Microsoft VS Code"
    if (-not (Test-Path -Path $VSCodePath)) {
        $VSCodePath = 'C:\Program Files\Microsoft VS Code'
    }
    if (-not (Test-Path -Path $VSCodePath)) {
        $VSCodePath = Get-ChildItem -Path "$env:SystemDrive\" -Recurse -File -ErrorAction 'Ignore' | Where-Object -Property 'Name' -EQ -Value 'code.exe' | Select-Object -First 1 -ExpandProperty 'DirectoryName'
    }

    $VSCodeProductVersion = Get-Item -Path "$VSCodePath\code.exe" -ErrorAction 'Ignore' | Select-Object -ExpandProperty 'VersionInfo' | Select-Object -ExpandProperty 'ProductVersion'
    if ($VSCodeProductVersion -gt [Version]::new(1, 71, 0, 0)) {
        "4. $ESC[32mVSCode Version OK$ESC[!p - Ihr Visual Studio Code ($ESC[35m$VSCodePath$ESC[!p) ist auf einem aktuellen Stand ($VSCodeProductVersion)."
    }
    else {
        "4. $ESC[31mVSCode Version NICHT OK$ESC[!p - Visual Studio Code ist auf Ihrem System nicht vorhanden oder die Version $ESC[35m$VSCodeProductVersion$ESC[!p ist veraltet."
    }

    #endregion

    #region 5. Visual Studio Code Erweiterungen installiert

    $VSCodePSExtensionFounded = $false

    if (Test-Path "$VSCodePath\data\extensions\ms-vscode.powershell-*") {
        $VSCodePSExtensionFounded = $true
        "5. $ESC[32mVSCode-PS-Erweiterung OK$ESC[!p - Es wurde Visual Studio Code auf dem aktuellen PC gefunden dessen Programm-Ordner enthält die PowerShell-Erweiterung ($ESC[35m$VSCodePath\data\extensions\ms-vscode.powershell-*$ESC[!p) für Visual Studio Code. Es wird davon ausgegangen das Visual Studio Code als TO-GO-Variante korrekt installiert und konfiguriert wurde."
    }

    if (Test-Path -Path "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile))\.vscode\extensions\ms-vscode.powershell-*") {
        $VSCodePSExtensionFounded = $true
        "5. $ESC[32mVSCode-PS-Erweiterung OK$ESC[!p - Der PC enthält im aktuellen Benutzer-Profil ($ESC[35m$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile))$ESC[!p) die PowerShell-Erweiterung für Visual Studio Code. Es wird davon ausgegangen das Visual Studio Code auf diesem System korrekt installiert und konfiguriert wurde."
    }

    if (-not $VSCodePSExtensionFounded) {
        "5. $ESC[31mVSCode-PS-Erweiterung NICHT OK$ESC[!p - Zur Visual Studio Code-Installation wurde die PowerShell-Erweiterung nicht gefunden. Dies kann über $ESC[35mhttps://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell$ESC[!p installiert werden."
    }

    #endregion

    #region Wichtige Infos aufzeigen

    $CurrentWindowsPrincipal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    $IsElevatedAdminRights = $CurrentWindowsPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')
    [PSCustomObject]@{ Name = 'Admin Rechte aktiv' ; Value = $IsElevatedAdminRights }

    [PSCustomObject]@{ Name = 'PowerShell Edition' ; Value = $PSEdition }

    [PSCustomObject]@{ Name = 'PowerShell Version' ; Value = $PSVersionTable.PSVersion }

    [PSCustomObject]@{ Name = 'PowerShell Execution Policy' ; Value = Get-ExecutionPolicy }

    foreach ($path in ($env:PSModulePath -split ';')) {
        [PSCustomObject]@{ Name = 'PowerShell Module Path' ; Value = $path }
    }

    #endregion
}
>>>>>>> 47bdafb926307894e343ff9720d2bc56b970228c
