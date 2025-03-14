<<<<<<< HEAD
﻿# TODO Next Level: https://bradwilson.io/blog/prompt/powershell
<#
.SYNOPSIS
    Ersetzt das Prompt gegen ein neues Prompt.
.DESCRIPTION
    Ersetzt das aktuelle PowerShell-Prompt temporär gegen ein neues Prompt mit folgenden Informationen: Admin-Rechte-Status, Anmeldename, Datum, Arbeitsverzeichnis.
.PARAMETER Off
    Setzt das alte Prompt wieder ein.
.EXAMPLE
    Use-NewPrompt
    Einschalten.
.EXAMPLE
    Use-NewPrompt -Off
    Ausschalten.
#>
function Use-NewPrompt {
    [CmdletBinding()]
    param (
        [switch]$Off
    )

    if(!(Test-Path variable:\promptBackup)) {
        Get-Content -Path 'Function:\prompt' | New-Variable -Name 'promptBackup' -Scope 'Global' -Option 'ReadOnly' -Force
    }

    if(!$Off) {
        {
            $esc = [char]0x1b
            $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
            $CurrentUserIsElevated = ([Security.Principal.WindowsPrincipal]$CurrentIdentity).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')
            $CurrentUsername = $CurrentIdentity.Name.Split('\')[1]
            $CurrentDate = Get-Date -Format 'ddd., dd.MM. HH:mm'
            $LastCommandDuration = 0
            $LastCommand = Get-History -Count 1
            if ($null -ne $LastCommand) {
                $LastCommandDuration = New-TimeSpan -Start $LastCommand.StartExecutionTime -End $LastCommand.EndExecutionTime | Select-Object -ExpandProperty TotalSeconds
            }
            @"
$(if ($CurrentUserIsElevated) { " `e[31m`e[41;97m Elevated `e[0m`e[31m`e[0m" } else { '' })`e[34m`e[44;97m $CurrentUsername `e[0m`e[34m`e[0m`e[32m`e[42;97m $CurrentDate `e[0m`e[32m`e[0m ⌂ $($executionContext.SessionState.Path.CurrentLocation)
$(if ((Test-Path variable:/PSDebugContext)) { "`e[35m`e[45;97m  DEBUG   `e[0m`e[35m`e[0m" } else { '' })${esc}[32m ◷ $('{0:0.0}' -f $LastCommandDuration)s${esc}[0m$(' >' * ($nestedPromptLevel + 1))
"@
        } | Set-Content -Path Function:\prompt
    }

    if($Off -and (Test-Path variable:\promptBackup)) {
        $Global:promptBackup | Set-Content -Path 'Function:\prompt' -Force
        Remove-Variable -Name 'promptBackup' -Scope 'Global' -Force -ErrorAction 'Ignore'
    }
}
=======
﻿# TODO Next Level: https://bradwilson.io/blog/prompt/powershell
<#
.SYNOPSIS
    Ersetzt das Prompt gegen ein neues Prompt.
.DESCRIPTION
    Ersetzt das aktuelle PowerShell-Prompt temporär gegen ein neues Prompt mit folgenden Informationen: Admin-Rechte-Status, Anmeldename, Datum, Arbeitsverzeichnis.
.PARAMETER Off
    Setzt das alte Prompt wieder ein.
.EXAMPLE
    Use-NewPrompt
    Einschalten.
.EXAMPLE
    Use-NewPrompt -Off
    Ausschalten.
#>
function Use-NewPrompt {
    [CmdletBinding()]
    param (
        [switch]$Off
    )

    if(!(Test-Path variable:\promptBackup)) {
        Get-Content -Path 'Function:\prompt' | New-Variable -Name 'promptBackup' -Scope 'Global' -Option 'ReadOnly' -Force
    }

    if(!$Off) {
        {
            $esc = [char]0x1b
            $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
            $CurrentUserIsElevated = ([Security.Principal.WindowsPrincipal]$CurrentIdentity).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')
            $CurrentUsername = $CurrentIdentity.Name.Split('\')[1]
            $CurrentDate = Get-Date -Format 'ddd., dd.MM. HH:mm'
            $LastCommandDuration = 0
            $LastCommand = Get-History -Count 1
            if ($null -ne $LastCommand) {
                $LastCommandDuration = New-TimeSpan -Start $LastCommand.StartExecutionTime -End $LastCommand.EndExecutionTime | Select-Object -ExpandProperty TotalSeconds
            }
            @"
$(if ($CurrentUserIsElevated) { " `e[31m`e[41;97m Elevated `e[0m`e[31m`e[0m" } else { '' })`e[34m`e[44;97m $CurrentUsername `e[0m`e[34m`e[0m`e[32m`e[42;97m $CurrentDate `e[0m`e[32m`e[0m ⌂ $($executionContext.SessionState.Path.CurrentLocation)
$(if ((Test-Path variable:/PSDebugContext)) { "`e[35m`e[45;97m  DEBUG   `e[0m`e[35m`e[0m" } else { '' })${esc}[32m ◷ $('{0:0.0}' -f $LastCommandDuration)s${esc}[0m$(' >' * ($nestedPromptLevel + 1))
"@
        } | Set-Content -Path Function:\prompt
    }

    if($Off -and (Test-Path variable:\promptBackup)) {
        $Global:promptBackup | Set-Content -Path 'Function:\prompt' -Force
        Remove-Variable -Name 'promptBackup' -Scope 'Global' -Force -ErrorAction 'Ignore'
    }
}
>>>>>>> 47bdafb926307894e343ff9720d2bc56b970228c
