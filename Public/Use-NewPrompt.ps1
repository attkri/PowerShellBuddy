# TODO Next Level: https://bradwilson.io/blog/prompt/powershell
<#
.SYNOPSIS
    Replaces the current prompt with an enhanced prompt.
.DESCRIPTION
    Temporarily replaces the current PowerShell prompt with a richer prompt that shows elevation state, user name, date, and working directory.
.PARAMETER Off
    Restores the original prompt.
.EXAMPLE
    Use-NewPrompt
    Enable the custom prompt.
.EXAMPLE
    Use-NewPrompt -Off
    Disable the custom prompt.
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
            $CurrentUsername = [Environment]::UserName
            $CurrentUserIsElevated = $false

            if ($IsWindows) {
                try {
                    $CurrentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
                    $CurrentUserIsElevated = ([Security.Principal.WindowsPrincipal]$CurrentIdentity).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')
                    $CurrentUsername = $CurrentIdentity.Name.Split('\')[-1]
                }
                catch {
                }
            }
            elseif ($CurrentUsername -eq 'root') {
                $CurrentUserIsElevated = $true
            }

            $CurrentDate = (Get-Date).ToString('ddd, yyyy-MM-dd HH:mm', [System.Globalization.CultureInfo]::InvariantCulture)
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
