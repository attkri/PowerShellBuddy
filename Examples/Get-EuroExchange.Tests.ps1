<<<<<<< HEAD
﻿BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-EuroExchange Test" {
    Context "Parameter" {
        It "Parameter-Signatur korrekt" {
            Get-Command -Name Get-EuroExchange | Should -HaveParameter Currency     -Type String  -Mandatory
            Get-Command -Name Get-EuroExchange | Should -HaveParameter Euros        -Type Decimal -DefaultValue 1
            Get-Command -Name Get-EuroExchange | Should -HaveParameter ListCurrency -Type System.Management.Automation.SwitchParameter
        }
        It "Parameter-Metadaten => 'Currency'" {
            $target = (Get-Command Get-EuroExchange).Parameters['Currency']
            $target.ParameterSets.Keys | Should -Be 'Calculate'
            $target.Aliases | Should -Be 'Währung'

            $target1 = $target.Attributes.Where({ $_ -is [System.Management.Automation.ValidateSetAttribute] })
            $target1.ValidValues | Should -Be 'AUD', 'BGN', 'BRL', 'CAD', 'CHF', 'CNY', 'CZK', 'DKK', 'GBP', 'HKD', 'HRK', 'HUF', 'IDR', 'ILS', 'INR', 'ISK', 'JPY', 'KRW', 'MXN', 'MYR', 'NOK', 'NZD', 'PHP', 'PLN', 'RON', 'SEK', 'SGD', 'THB', 'TRY', 'USD', 'ZAR'

            $target2 = $target.Attributes.Where({ $_ -is [System.Management.Automation.ParameterAttribute] })
            $target2.Mandatory | should -BeTrue
            $target2.ValueFromPipeline | should -BeTrue
            $target2.ValueFromPipelineByPropertyName | should -BeTrue
        }
        It "Parameter-Metadaten => 'Euros'" {
            $target = (Get-Command Get-EuroExchange).Parameters['Euros']
            $target.ParameterSets.Keys | Should -Be 'Calculate'
            $target.Aliases | Should -Be 'Euronen'

            $target1 = $target.Attributes.Where({ $_ -is [System.Management.Automation.ValidateRangeAttribute] })
            $target1.MinRange | Should -Be 0.0001
            $target1.MaxRange | Should -Be 1000000

            $target2 = $target.Attributes.Where({ $_ -is [System.Management.Automation.ParameterAttribute] })
            $target2.Mandatory | should -BeFalse
            $target2.ValueFromPipeline | should -BeFalse
            $target2.ValueFromPipelineByPropertyName | should -BeTrue
        }
        It "Parameter-Metadaten => 'ListCurrency'" {
            $target = (Get-Command Get-EuroExchange).Parameters['ListCurrency']
            $target.ParameterSets.Keys | Should -Be 'Overview'
            $target.Aliases | Should -BeNullOrEmpty
            $target.SwitchParameter | Should -BeTrue

            $target1 = $target.Attributes.Where({ $_ -is [System.Management.Automation.ParameterAttribute] })
            $target1.Mandatory | should -BeTrue
            $target1.ValueFromPipeline | should -BeFalse
            $target1.ValueFromPipelineByPropertyName | should -BeFalse
        }
        It "Throw => Get-EuroExchange -Currency USD -ListCurrency" {
            { Get-EuroExchange -Currency USD -ListCurrency } | Should -Throw -ErrorId 'AmbiguousParameterSet,Get-EuroExchange'
        }
        It "Throw => Get-EuroExchange -Euros 100 -ListCurrency" {
            { Get-EuroExchange -Euros 100 -ListCurrency } | Should -Throw -ErrorId 'AmbiguousParameterSet,Get-EuroExchange'
        }
        It "Throw => Get-EuroExchange -Currency XXX" {
            { Get-EuroExchange -Currency XXX } | Should -Throw -ErrorId "ParameterArgumentValidationError,Get-EuroExchange"
        }
        It "Throw => Get-EuroExchange -Currency USD -Euros -100" {
            { Get-EuroExchange -Currency USD -Euros -100 } | Should -Throw -ErrorId "ParameterArgumentValidationError,Get-EuroExchange"
        }
        It "Throw => Get-EuroExchange -Currency USD -Euros 1000001" {
            { Get-EuroExchange -Currency USD -Euros 1000001 } | Should -Throw -ErrorId "ParameterArgumentValidationError,Get-EuroExchange"
        }
        It "Throw => Get-EuroExchange -Currency USD -Euros 0" {
            { Get-EuroExchange -Currency USD -Euros 0 } | Should -Throw -ErrorId "ParameterArgumentValidationError,Get-EuroExchange"
        }
        It "Throw => Get-EuroExchange -Currency USD -Euros hundert" {
            { Get-EuroExchange -Currency USD -Euros hundert } | Should -Throw -ErrorId "ParameterArgumentTransformationError,Get-EuroExchange"
        }
        It "Throw => Get-EuroExchange -Currency USD, ZAR" {
            { Get-EuroExchange -Currency USD, ZAR } | Should -Throw -ErrorId "ParameterArgumentTransformationError,Get-EuroExchange"
        }
        It "Throw => Get-EuroExchange -Currency USD -Euros 50, 100" {
            { Get-EuroExchange -Currency USD -Euros 50, 100 } | Should -Throw -ErrorId "ParameterArgumentTransformationError,Get-EuroExchange"
        }
    }
    Context "Rückgabe-Objekte" {
        BeforeAll {
            $content = Invoke-WebRequest -Uri "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml" | Select-Object -ExpandProperty Content
            $script:Cubes = ([xml]$content).Envelope.Cube.Cube.Cube
        }
        It "Get-EuroExchange -Currency USD: Rückgabe-Objekt -is [PSCustomObject]" {
            Get-EuroExchange -Currency USD | Should -BeOfType PSCustomObject
        }
        It "Get-EuroExchange -Currency USD: target -isNot [Array]" {
            Get-EuroExchange -Currency USD | Should -Not -BeOfType Array
        }
        It "Get-EuroExchange -Currency USD: Rückgabe-Objekt -is [PSCustomObject]" {
            Get-EuroExchange -Currency USD | Should -BeOfType PSCustomObject
        }
        It "Get-EuroExchange -Currency USD: Rückgabe-Objekt -is [PSCustomObject]" {
            Get-EuroExchange -Currency USD | Should -BeOfType PSCustomObject
        }
        It "Get-EuroExchange -Currency USD: target.Currency -ceq USD" {
            $target = Get-EuroExchange -Currency USD
            $target.Currency | Should -BeExactly "USD"
            $target.Currency | Should -BeOfType String
        }
        It "Get-EuroExchange -Currency USD: target.Rate -eq ECB.Value" {
            [decimal]$expected = $cubes | Where-Object -Property Currency -EQ -Value USD | Select-Object -ExpandProperty rate
            $target = Get-EuroExchange -Currency USD
            $target.Rate | Should -BeExactly $expected
            $target.Rate | Should -BeOfType Decimal
        }
        It "Get-EuroExchange -Currency USD: target.Euros -eq 1" {
            $target = Get-EuroExchange -Currency USD
            $target.Euros | Should -BeExactly 1
            $target.Euros | Should -BeOfType Decimal
        }
        It "Get-EuroExchange -Currency USD: target.SumCurrency -eq (1 * ECB.Value)" {
            [decimal]$expected = $Cubes | Where-Object -Property Currency -EQ -Value USD | Select-Object -ExpandProperty Rate
            $target = Get-EuroExchange -Currency USD
            $target.SumCurrency | Should -BeExactly $expected
            $target.SumCurrency | Should -BeOfType Decimal
        }
        It "Get-EuroExchange -Currency USD -Euros 100: target.SumCurrency -eq (100 * ECB.Value)" {
            [decimal]$expected = $Cubes | Where-Object -Property Currency -EQ -Value USD | Select-Object -ExpandProperty Rate
            $expected *= 100
            $target = Get-EuroExchange -Currency USD -Euros 100
            $target.SumCurrency | Should -BeExactly $expected
            $target.SumCurrency | Should -BeOfType Decimal
        }
        It "Get-EuroExchange -ListCurrency => target -is PSCustomObject" {
            Get-EuroExchange -ListCurrency | Should -BeOfType PSCustomObject
        }
        It "Get-EuroExchange -ListCurrency => target -eq Ecb" {
            $expected = $Cubes.currency | Sort-Object
            Get-EuroExchange -ListCurrency | Select-Object -ExpandProperty Currency | Should -be $expected
        }
        It "'USD', 'AUD', 'ZAR' | Get-EuroExchange => target -eq Ecb" {
            $expected = $Cubes | Where-Object -Property currency -in 'USD', 'ZAR', 'AUD' | Select-Object -ExpandProperty rate | ForEach-Object { [decimal]$_ }
            $target = 'USD', 'AUD', 'ZAR' | Get-EuroExchange | Select-Object -ExpandProperty Rate
            $target | Should -BeExactly $expected
        }
        It "'USD', 'AUD', 'ZAR' | Get-EuroExchange -Euros 100 => target -eq Ecb" {
            $expected = $Cubes | Where-Object -Property currency -in 'USD', 'ZAR', 'AUD' | Select-Object -ExpandProperty rate | ForEach-Object { [decimal]$_ * 100 }
            $target = 'USD', 'AUD', 'ZAR' | Get-EuroExchange -Euros 100 | Select-Object -ExpandProperty SumCurrency
            $target | Should -BeExactly $expected
        }
        It "Get-EuroExchange -ListCurrency | Get-EuroExchange -Euros 1000 => target -eq Ecb" {
            $expected = $Cubes | Sort-Object -Property currency | Select-Object -ExpandProperty rate | ForEach-Object { [decimal]$_ * 1000 }
            $target = Get-EuroExchange -ListCurrency | Get-EuroExchange -Euros 1000 | Select-Object -ExpandProperty SumCurrency
            $target | Should -BeExactly $expected
        }
        It "'USD,10', 'ZAR,100', 'AUD,1000' | ConvertFrom-Csv -Header Currency, Euros | Get-EuroExchange => target -eq Ecb" {
            $expected0 = $Cubes | Where-Object currency -eq 'USD' | Select-Object -ExpandProperty rate | ForEach-Object { [decimal]$_ * 10 }
            $expected1 = $Cubes | Where-Object currency -eq 'ZAR' | Select-Object -ExpandProperty rate | ForEach-Object { [decimal]$_ * 100 }
            $expected2 = $Cubes | Where-Object currency -eq 'AUD' | Select-Object -ExpandProperty rate | ForEach-Object { [decimal]$_ * 1000 }

            $target = 'USD,10', 'ZAR,100', 'AUD,1000' | ConvertFrom-Csv -Header Currency, Euros | Get-EuroExchange
            $target[0].SumCurrency | Should -BeExactly $expected0
            $target[1].SumCurrency | Should -BeExactly $expected1
            $target[2].SumCurrency | Should -BeExactly $expected2
        }
        It "'USD,10', 'ZAR,100', 'AUD,1000' | ConvertFrom-Csv -Header Währung, Euronen | Get-EuroExchange => target -eq Ecb" {
            $expected0 = $Cubes | Where-Object currency -eq 'USD' | Select-Object -ExpandProperty rate | ForEach-Object { [decimal]$_ * 10 }
            $expected1 = $Cubes | Where-Object currency -eq 'ZAR' | Select-Object -ExpandProperty rate | ForEach-Object { [decimal]$_ * 100 }
            $expected2 = $Cubes | Where-Object currency -eq 'AUD' | Select-Object -ExpandProperty rate | ForEach-Object { [decimal]$_ * 1000 }

            $target = 'USD,10', 'ZAR,100', 'AUD,1000' | ConvertFrom-Csv -Header Währung, Euronen | Get-EuroExchange
            $target[0].SumCurrency | Should -BeExactly $expected0
            $target[1].SumCurrency | Should -BeExactly $expected1
            $target[2].SumCurrency | Should -BeExactly $expected2
        }
    }
}

<#

# ! Code-Abdeckungsanalyse einzeln ausführen um einen rekursive Schleife zu vermeiden

$config = [PesterConfiguration]::Default

$config.Run.Path =  ".\Tests\Get-EuroExchange.Tests.ps1"
$config.Run.PassThru    = $true

$config.CodeCoverage.Enabled               = $true
$config.CodeCoverage.OutputFormat          = 'CoverageGutters'
$config.CodeCoverage.Path                  = ".\Public\Get-EuroExchange.ps1"
$config.CodeCoverage.OutputPath            = ".\Public\Get-EuroExchange.CodeCoverage.xml"
$config.CodeCoverage.CoveragePercentTarget = 90

$config.TestResult.Enabled    = $true
$config.TestResult.OutputPath = ".\Tests\Get-EuroExchange.TestResults.xml"

$config.Output.Verbosity = 'Detailed'

$config.Debug.WriteDebugMessages     = $true
$config.Debug.WriteDebugMessagesFrom = 'CodeCoverage'

Invoke-Pester -Configuration $config
#>
=======
﻿BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-EuroExchange Test" {
    Context "Parameter" {
        It "Parameter-Signatur korrekt" {
            Get-Command -Name Get-EuroExchange | Should -HaveParameter Currency     -Type String  -Mandatory
            Get-Command -Name Get-EuroExchange | Should -HaveParameter Euros        -Type Decimal -DefaultValue 1
            Get-Command -Name Get-EuroExchange | Should -HaveParameter ListCurrency -Type System.Management.Automation.SwitchParameter
        }
        It "Parameter-Metadaten => 'Currency'" {
            $target = (Get-Command Get-EuroExchange).Parameters['Currency']
            $target.ParameterSets.Keys | Should -Be 'Calculate'
            $target.Aliases | Should -Be 'Währung'

            $target1 = $target.Attributes.Where({ $_ -is [System.Management.Automation.ValidateSetAttribute] })
            $target1.ValidValues | Should -Be 'AUD', 'BGN', 'BRL', 'CAD', 'CHF', 'CNY', 'CZK', 'DKK', 'GBP', 'HKD', 'HRK', 'HUF', 'IDR', 'ILS', 'INR', 'ISK', 'JPY', 'KRW', 'MXN', 'MYR', 'NOK', 'NZD', 'PHP', 'PLN', 'RON', 'SEK', 'SGD', 'THB', 'TRY', 'USD', 'ZAR'

            $target2 = $target.Attributes.Where({ $_ -is [System.Management.Automation.ParameterAttribute] })
            $target2.Mandatory | should -BeTrue
            $target2.ValueFromPipeline | should -BeTrue
            $target2.ValueFromPipelineByPropertyName | should -BeTrue
        }
        It "Parameter-Metadaten => 'Euros'" {
            $target = (Get-Command Get-EuroExchange).Parameters['Euros']
            $target.ParameterSets.Keys | Should -Be 'Calculate'
            $target.Aliases | Should -Be 'Euronen'

            $target1 = $target.Attributes.Where({ $_ -is [System.Management.Automation.ValidateRangeAttribute] })
            $target1.MinRange | Should -Be 0.0001
            $target1.MaxRange | Should -Be 1000000

            $target2 = $target.Attributes.Where({ $_ -is [System.Management.Automation.ParameterAttribute] })
            $target2.Mandatory | should -BeFalse
            $target2.ValueFromPipeline | should -BeFalse
            $target2.ValueFromPipelineByPropertyName | should -BeTrue
        }
        It "Parameter-Metadaten => 'ListCurrency'" {
            $target = (Get-Command Get-EuroExchange).Parameters['ListCurrency']
            $target.ParameterSets.Keys | Should -Be 'Overview'
            $target.Aliases | Should -BeNullOrEmpty
            $target.SwitchParameter | Should -BeTrue

            $target1 = $target.Attributes.Where({ $_ -is [System.Management.Automation.ParameterAttribute] })
            $target1.Mandatory | should -BeTrue
            $target1.ValueFromPipeline | should -BeFalse
            $target1.ValueFromPipelineByPropertyName | should -BeFalse
        }
        It "Throw => Get-EuroExchange -Currency USD -ListCurrency" {
            { Get-EuroExchange -Currency USD -ListCurrency } | Should -Throw -ErrorId 'AmbiguousParameterSet,Get-EuroExchange'
        }
        It "Throw => Get-EuroExchange -Euros 100 -ListCurrency" {
            { Get-EuroExchange -Euros 100 -ListCurrency } | Should -Throw -ErrorId 'AmbiguousParameterSet,Get-EuroExchange'
        }
        It "Throw => Get-EuroExchange -Currency XXX" {
            { Get-EuroExchange -Currency XXX } | Should -Throw -ErrorId "ParameterArgumentValidationError,Get-EuroExchange"
        }
        It "Throw => Get-EuroExchange -Currency USD -Euros -100" {
            { Get-EuroExchange -Currency USD -Euros -100 } | Should -Throw -ErrorId "ParameterArgumentValidationError,Get-EuroExchange"
        }
        It "Throw => Get-EuroExchange -Currency USD -Euros 1000001" {
            { Get-EuroExchange -Currency USD -Euros 1000001 } | Should -Throw -ErrorId "ParameterArgumentValidationError,Get-EuroExchange"
        }
        It "Throw => Get-EuroExchange -Currency USD -Euros 0" {
            { Get-EuroExchange -Currency USD -Euros 0 } | Should -Throw -ErrorId "ParameterArgumentValidationError,Get-EuroExchange"
        }
        It "Throw => Get-EuroExchange -Currency USD -Euros hundert" {
            { Get-EuroExchange -Currency USD -Euros hundert } | Should -Throw -ErrorId "ParameterArgumentTransformationError,Get-EuroExchange"
        }
        It "Throw => Get-EuroExchange -Currency USD, ZAR" {
            { Get-EuroExchange -Currency USD, ZAR } | Should -Throw -ErrorId "ParameterArgumentTransformationError,Get-EuroExchange"
        }
        It "Throw => Get-EuroExchange -Currency USD -Euros 50, 100" {
            { Get-EuroExchange -Currency USD -Euros 50, 100 } | Should -Throw -ErrorId "ParameterArgumentTransformationError,Get-EuroExchange"
        }
    }
    Context "Rückgabe-Objekte" {
        BeforeAll {
            $content = Invoke-WebRequest -Uri "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml" | Select-Object -ExpandProperty Content
            $script:Cubes = ([xml]$content).Envelope.Cube.Cube.Cube
        }
        It "Get-EuroExchange -Currency USD: Rückgabe-Objekt -is [PSCustomObject]" {
            Get-EuroExchange -Currency USD | Should -BeOfType PSCustomObject
        }
        It "Get-EuroExchange -Currency USD: target -isNot [Array]" {
            Get-EuroExchange -Currency USD | Should -Not -BeOfType Array
        }
        It "Get-EuroExchange -Currency USD: Rückgabe-Objekt -is [PSCustomObject]" {
            Get-EuroExchange -Currency USD | Should -BeOfType PSCustomObject
        }
        It "Get-EuroExchange -Currency USD: Rückgabe-Objekt -is [PSCustomObject]" {
            Get-EuroExchange -Currency USD | Should -BeOfType PSCustomObject
        }
        It "Get-EuroExchange -Currency USD: target.Currency -ceq USD" {
            $target = Get-EuroExchange -Currency USD
            $target.Currency | Should -BeExactly "USD"
            $target.Currency | Should -BeOfType String
        }
        It "Get-EuroExchange -Currency USD: target.Rate -eq ECB.Value" {
            [decimal]$expected = $cubes | Where-Object -Property Currency -EQ -Value USD | Select-Object -ExpandProperty rate
            $target = Get-EuroExchange -Currency USD
            $target.Rate | Should -BeExactly $expected
            $target.Rate | Should -BeOfType Decimal
        }
        It "Get-EuroExchange -Currency USD: target.Euros -eq 1" {
            $target = Get-EuroExchange -Currency USD
            $target.Euros | Should -BeExactly 1
            $target.Euros | Should -BeOfType Decimal
        }
        It "Get-EuroExchange -Currency USD: target.SumCurrency -eq (1 * ECB.Value)" {
            [decimal]$expected = $Cubes | Where-Object -Property Currency -EQ -Value USD | Select-Object -ExpandProperty Rate
            $target = Get-EuroExchange -Currency USD
            $target.SumCurrency | Should -BeExactly $expected
            $target.SumCurrency | Should -BeOfType Decimal
        }
        It "Get-EuroExchange -Currency USD -Euros 100: target.SumCurrency -eq (100 * ECB.Value)" {
            [decimal]$expected = $Cubes | Where-Object -Property Currency -EQ -Value USD | Select-Object -ExpandProperty Rate
            $expected *= 100
            $target = Get-EuroExchange -Currency USD -Euros 100
            $target.SumCurrency | Should -BeExactly $expected
            $target.SumCurrency | Should -BeOfType Decimal
        }
        It "Get-EuroExchange -ListCurrency => target -is PSCustomObject" {
            Get-EuroExchange -ListCurrency | Should -BeOfType PSCustomObject
        }
        It "Get-EuroExchange -ListCurrency => target -eq Ecb" {
            $expected = $Cubes.currency | Sort-Object
            Get-EuroExchange -ListCurrency | Select-Object -ExpandProperty Currency | Should -be $expected
        }
        It "'USD', 'AUD', 'ZAR' | Get-EuroExchange => target -eq Ecb" {
            $expected = $Cubes | Where-Object -Property currency -in 'USD', 'ZAR', 'AUD' | Select-Object -ExpandProperty rate | ForEach-Object { [decimal]$_ }
            $target = 'USD', 'AUD', 'ZAR' | Get-EuroExchange | Select-Object -ExpandProperty Rate
            $target | Should -BeExactly $expected
        }
        It "'USD', 'AUD', 'ZAR' | Get-EuroExchange -Euros 100 => target -eq Ecb" {
            $expected = $Cubes | Where-Object -Property currency -in 'USD', 'ZAR', 'AUD' | Select-Object -ExpandProperty rate | ForEach-Object { [decimal]$_ * 100 }
            $target = 'USD', 'AUD', 'ZAR' | Get-EuroExchange -Euros 100 | Select-Object -ExpandProperty SumCurrency
            $target | Should -BeExactly $expected
        }
        It "Get-EuroExchange -ListCurrency | Get-EuroExchange -Euros 1000 => target -eq Ecb" {
            $expected = $Cubes | Sort-Object -Property currency | Select-Object -ExpandProperty rate | ForEach-Object { [decimal]$_ * 1000 }
            $target = Get-EuroExchange -ListCurrency | Get-EuroExchange -Euros 1000 | Select-Object -ExpandProperty SumCurrency
            $target | Should -BeExactly $expected
        }
        It "'USD,10', 'ZAR,100', 'AUD,1000' | ConvertFrom-Csv -Header Currency, Euros | Get-EuroExchange => target -eq Ecb" {
            $expected0 = $Cubes | Where-Object currency -eq 'USD' | Select-Object -ExpandProperty rate | ForEach-Object { [decimal]$_ * 10 }
            $expected1 = $Cubes | Where-Object currency -eq 'ZAR' | Select-Object -ExpandProperty rate | ForEach-Object { [decimal]$_ * 100 }
            $expected2 = $Cubes | Where-Object currency -eq 'AUD' | Select-Object -ExpandProperty rate | ForEach-Object { [decimal]$_ * 1000 }

            $target = 'USD,10', 'ZAR,100', 'AUD,1000' | ConvertFrom-Csv -Header Currency, Euros | Get-EuroExchange
            $target[0].SumCurrency | Should -BeExactly $expected0
            $target[1].SumCurrency | Should -BeExactly $expected1
            $target[2].SumCurrency | Should -BeExactly $expected2
        }
        It "'USD,10', 'ZAR,100', 'AUD,1000' | ConvertFrom-Csv -Header Währung, Euronen | Get-EuroExchange => target -eq Ecb" {
            $expected0 = $Cubes | Where-Object currency -eq 'USD' | Select-Object -ExpandProperty rate | ForEach-Object { [decimal]$_ * 10 }
            $expected1 = $Cubes | Where-Object currency -eq 'ZAR' | Select-Object -ExpandProperty rate | ForEach-Object { [decimal]$_ * 100 }
            $expected2 = $Cubes | Where-Object currency -eq 'AUD' | Select-Object -ExpandProperty rate | ForEach-Object { [decimal]$_ * 1000 }

            $target = 'USD,10', 'ZAR,100', 'AUD,1000' | ConvertFrom-Csv -Header Währung, Euronen | Get-EuroExchange
            $target[0].SumCurrency | Should -BeExactly $expected0
            $target[1].SumCurrency | Should -BeExactly $expected1
            $target[2].SumCurrency | Should -BeExactly $expected2
        }
    }
}

<#

# ! Code-Abdeckungsanalyse einzeln ausführen um einen rekursive Schleife zu vermeiden

$config = [PesterConfiguration]::Default

$config.Run.Path =  ".\Tests\Get-EuroExchange.Tests.ps1"
$config.Run.PassThru    = $true

$config.CodeCoverage.Enabled               = $true
$config.CodeCoverage.OutputFormat          = 'CoverageGutters'
$config.CodeCoverage.Path                  = ".\Public\Get-EuroExchange.ps1"
$config.CodeCoverage.OutputPath            = ".\Public\Get-EuroExchange.CodeCoverage.xml"
$config.CodeCoverage.CoveragePercentTarget = 90

$config.TestResult.Enabled    = $true
$config.TestResult.OutputPath = ".\Tests\Get-EuroExchange.TestResults.xml"

$config.Output.Verbosity = 'Detailed'

$config.Debug.WriteDebugMessages     = $true
$config.Debug.WriteDebugMessagesFrom = 'CodeCoverage'

Invoke-Pester -Configuration $config
#>
>>>>>>> 47bdafb926307894e343ff9720d2bc56b970228c
