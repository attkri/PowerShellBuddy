Add-Type -TypeDefinition "public enum LogMessageStatus { Unknown, Information, Warning, Error }"

Function Out-Log {
    [CmdletBinding()]
    Param (
        [string]$LogFilePath = ('.\Unnamed_{0}.log' -f (Get-Date -Format 'yyyyMMdd')),

        [Parameter(Mandatory = $true)]
        [string]$Message,

        [ArgumentCompleter({
                [LogMessageStatus].GetEnumValues()
            })]
        [Parameter(Mandatory = $true)]
        [LogMessageStatus]$Status,

        [switch]$PassThrow
    )
    begin {
        $Script:My = [HashTable]::Synchronized(@{})
        $Script:My.BasePattern = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        $Script:My.BasePattern += ' > {0,-11} > {1}'
        if (-not (Test-Path -Path $LogFilePath -PathType Leaf)) {
            $Script:My.BasePattern -f 'Start', 'Log-File Created.' | Set-Content -Path $LogFilePath -PassThru:$PassThrow
        }
    }
    Process {
        $Script:My.BasePattern -f $Status, $Message | Add-Content -Path $LogFilePath -PassThru:$PassThrow
    }
}
<#
    Get-Command -Name Write-Log -Syntax
    Write-Log -Status Information -Message 'Das ist ein Informations-Log-Eintrag.'
    Write-Log -Status Warning     -Message 'Das ist ein Warnung-Log-Eintrag.'
    Write-Log -Status Error       -Message 'Das ist ein Fehler-Log-Eintrag.'
#>