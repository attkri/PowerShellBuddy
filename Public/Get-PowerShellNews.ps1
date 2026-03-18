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
        $supportsVirtualTerminal = $host.UI.SupportsVirtualTerminal
        $formatDefault = [string]::Empty
        if ($supportsVirtualTerminal) {
            $formatDefault = "$([char]0x1b)[0m"
        }

        Write-Verbose 'Fetching Microsoft PowerShell blog news from the official feed.'

        try {
            $content = Invoke-WebRequest -Uri 'https://devblogs.microsoft.com/powershell/feed/' -ErrorAction Stop |
                Select-Object -ExpandProperty Content
            $rssContent = [xml]$content
        }
        catch {
            throw 'Unable to retrieve Microsoft PowerShell blog news. Check your internet connection and try again.'
        }

        $rssContent.rss.channel.Item |
            Select-Object -Property @{Name = 'ReleaseDate'; Expression = { [DateTime]$_.pubDate } }, title, link |
            Where-Object -Property ReleaseDate -GE -Value $AfterDate |
            ForEach-Object -Process {
            $newsText = if ($supportsVirtualTerminal) {
                "`e]8;;$($_.link)`e\$($_.Title)`e]8;;`e\" + $formatDefault
            }
            else {
                "$($_.Title) - $($_.link)"
            }

            [PSCustomObject]@{
                Release = [datetime]$_.ReleaseDate
                News    = $newsText
            }
        }
    }
}
