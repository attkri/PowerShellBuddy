BeforeAll -Scriptblock {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe -Name 'Get-Weather' -Fixture {

    BeforeEach {
        $script:CapturedUri = $null

        Mock Invoke-RestMethod {
            param([string]$Uri)

            $script:CapturedUri = $Uri
            'Mock weather response'
        }
    }

    It -Name 'uses the default language and returns the service response' {
        $language = (Get-Culture).TwoLetterISOLanguageName

        $result = Get-Weather

        $result | Should -Be 'Mock weather response'
        $script:CapturedUri | Should -Be "https://wttr.in/?lang=$language&F"
    }

    It -Name 'URL-encodes the requested location' {
        $language = (Get-Culture).TwoLetterISOLanguageName

        Get-Weather -Location 'Köln' | Out-Null

        $script:CapturedUri | Should -Match "^https://wttr\.in/(K%C3%B6ln|Köln)\?lang=$language&F$"
    }

    It -Name 'adds the current-weather switch flag to the request' {
        $language = (Get-Culture).TwoLetterISOLanguageName

        Get-Weather -Location 'Athens' -OnlyCurrentWeather | Out-Null

        $script:CapturedUri | Should -Be "https://wttr.in/Athens?lang=$language&F0"
    }

    It -Name 'adds one-line output formatting to the request' {
        $language = (Get-Culture).TwoLetterISOLanguageName

        Get-Weather -Location 'Hamburg' -OnlyCurrentWeather -OneLineOutput | Out-Null

        $script:CapturedUri | Should -Be "https://wttr.in/Hamburg?lang=$language&F0&format=3"
    }

    It -Name 'throws a friendly error when the weather service fails' {
        Mock Invoke-RestMethod {
            throw 'Network failure.'
        }

        { Get-Weather -Location 'Unknown' } | Should -Throw -ExpectedMessage 'Unable to retrieve weather data. Check your internet connection or verify the requested location.'
    }
}

<#
Clear-Host

$config = New-PesterConfiguration

$config.Run.Path = ".\Get-Weather.Tests.ps1"

$config.CodeCoverage.Enabled = $true
$config.CodeCoverage.OutputFormat          = 'CoverageGutters'
$config.CodeCoverage.Path                  = ".\Get-Weather.ps1"
$config.CodeCoverage.OutputPath            = ".\Get-Weather.CodeCoverage.xml"
$config.CodeCoverage.CoveragePercentTarget = 90

$config.Output.Verbosity = 'Detailed'

Invoke-Pester -Configuration $config
#>
