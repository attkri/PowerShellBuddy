<#
.SYNOPSIS
Shows official news on the subject of Powershell from Microsoft.

.EXAMPLE
Get-PowerShellNews
Shows official news on the subject of Powershell from Microsoft.

.OUTPUTS
[System.String]
#>
function Get-PowerShellNews {
    [CmdletBinding()]
    param(
        [datetime]$AfterDate = [datetime]::MinValue
    )
    begin {
        $My = [HashTable]::Synchronized(@{})
        $My.ESC = [char]0x1b
        $My.FormatHeader = "$($My.ESC)[95m"
        $My.FormatDefault = "$($My.ESC)[0m"
        if (-not $host.UI.SupportsVirtualTerminal) {
            $My.FormatHeader = [String]::Empty
            $My.FormatDefault = [String]::Empty
        }
        "$($My.FormatHeader)
        $($My.FormatDefault)" | Out-Host
        "$($My.FormatHeader)Microsoft PowerShell Blog News (https://devblogs.microsoft.com/powershell):$($My.FormatDefault)" | Write-Host
        try {
            $My.Content = [xml](Invoke-WebRequest -Uri 'https://devblogs.microsoft.com/powershell/feed/' -ErrorAction Stop | Select-Object -ExpandProperty Content)
        }
        catch {
            "Vermutlich ist das Internet aktuelle nicht zu erreichen. Daher können keine News abgerufen werden." | Write-Warning
            exit
        }
        $My.Content.rss.channel.Item | Select-Object -Property @{Name = 'ReleaseDate'; Expression = { [DateTime]$_.pubDate } }, title, link | Where-Object -Property ReleaseDate -GE -Value $AfterDate | ForEach-Object -Process {
            return [PSCustomObject]@{
                Release = [datetime]$_.ReleaseDate
                News    = "`e]8;;$($_.link)`e\$($_.Title)`e]8;;`e\" + $My.FormatDefault
            }
        }
    }
}