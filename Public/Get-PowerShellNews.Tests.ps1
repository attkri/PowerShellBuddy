BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    $script:SampleFeed = @'
<rss>
  <channel>
    <item>
      <title>PowerShell 7.5 preview</title>
      <link>https://devblogs.microsoft.com/powershell/powershell-7-5-preview/</link>
      <pubDate>Mon, 20 Jan 2025 12:00:00 GMT</pubDate>
    </item>
    <item>
      <title>PowerShell 7.4 release</title>
      <link>https://devblogs.microsoft.com/powershell/powershell-7-4-release/</link>
      <pubDate>Mon, 20 Nov 2023 12:00:00 GMT</pubDate>
    </item>
  </channel>
</rss>
'@
}

Describe 'Get-PowerShellNews' {

    BeforeEach {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{
                Content = $script:SampleFeed
            }
        }
    }

    It 'returns parsed feed items' {
        $newsItems = Get-PowerShellNews

        $newsItems | Should -HaveCount 2
        $newsItems[0].Release | Should -Be ([datetime]'2025-01-20T12:00:00Z')
        $newsItems[0].News | Should -Match 'PowerShell 7.5 preview'
    }

    It 'filters entries by AfterDate' {
        $afterDate = [datetime]'2024-01-01T00:00:00Z'

        $newsItems = Get-PowerShellNews -AfterDate $afterDate

        $newsItems | Should -HaveCount 1
        $newsItems[0].Release | Should -BeGreaterOrEqual $afterDate
    }

    It 'throws a friendly error when the feed cannot be retrieved' {
        Mock Invoke-WebRequest {
            throw 'No network available.'
        }

        { Get-PowerShellNews } | Should -Throw -ExpectedMessage 'Unable to retrieve Microsoft PowerShell blog news. Check your internet connection and try again.'
    }
}
