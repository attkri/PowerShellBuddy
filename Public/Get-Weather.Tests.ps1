BeforeAll -Scriptblock {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe -Name "Get-Weather" -Fixture {

    It -Name 'Default 1' {
        # Gibt Wetterdaten für einen gültigen Standort zurück, wenn kein Standort angegeben wird
        $result = Get-Weather
        $result | Should -Not -BeNullOrEmpty
    }

    It -Name 'Default 2' {
        # Gibt Wetterdaten für 3 Tage zurück, wenn kein Standort angegeben wird
        $result = Get-Weather | Select-String -Pattern 'Früh' -AllMatches | Select-Object -ExpandProperty Matches | Measure-Object
        $result.Count | Should -Be 3
    }

    It -Name "Default 3" {
        # Gibt Wetterdaten in der OS Sprache zurück
        $result = Get-Weather -Location Köln -OnlyCurrentWeather
        $result | Should -MatchExactly 'Wetterbericht für: Köln'
    }

    It -Name '-Location 1' {
        # Gibt Wetterdaten für einen gültigen Standort zurück
        $result = Get-Weather -Location Köln
        $result | Should -Not -BeNullOrEmpty
    }

    It -Name '-Location 2' {
        # Gibt einen Fehler zurück, wenn ein ungültiger Standort angegeben wird
        { Get-Weather -Location Unbekannter_Ort } | Should -Throw -ExpectedMessage "We were unable to find your location or could not retrieve weather data. Please check your internet connection or the location provided."
    }

    It -Name '-OnlyCurrentWeather 1' {
        # Gibt Wetterdaten für einen gültigen Standort zurück, wenn nur aktuelle Wetterdaten angefordert werden
        $result = Get-Weather -Location Köln -OnlyCurrentWeather
        $result | Should -Not -BeNullOrEmpty
    }

    $testCases = @(
        @{Location = 'Würzburg'; ExpectedResult = '^Wetterbericht für: Würzburg' }
        @{Location = 'London'  ; ExpectedResult = '^Wetterbericht für: London'   }
        @{Location = 'Αθήνα'   ; ExpectedResult = '^Wetterbericht für: Αθήνα'    }
    )

    It -Name "TestCase 1 <Location>" -ForEach $testCases -Test {
        param([string]$Location, [string]$ExpectedResult)
        $result = Get-Weather -Location $Location -OnlyCurrentWeather
        $result | Should -MatchExactly $ExpectedResult
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
