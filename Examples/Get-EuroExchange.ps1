function Get-EuroExchange {

    [CmdletBinding(DefaultParameterSetName = 'Calculate')]
    param (
        [Parameter(ParameterSetName = "Calculate", Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('AUD', 'BGN', 'BRL', 'CAD', 'CHF', 'CNY', 'CZK', 'DKK', 'GBP', 'HKD', 'HRK', 'HUF', 'IDR', 'ILS', 'INR', 'ISK', 'JPY', 'KRW', 'MXN', 'MYR', 'NOK', 'NZD', 'PHP', 'PLN', 'RON', 'SEK', 'SGD', 'THB', 'TRY', 'USD', 'ZAR')]
        [Alias("Währung")]
        [string]$Currency,

        [Parameter(ParameterSetName = "Calculate", ValueFromPipelineByPropertyName = $true)]
        [ValidateRange(0.0001, 1000000)]
        [Alias("Euronen")]
        [decimal]$Euros = 1,

        [Parameter(ParameterSetName = "Overview", Mandatory = $true)]
        [switch]$ListCurrency
    )
    begin {
        [datetime]$StartTime = Get-Date

        #region Update local cache and read it

        # ! Build Cache-File:
        [string]$EuroExchangeCacheFile = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath 'EcbEuroExchangeCache.xml'

        # ! Exist Cache-File read timestamp:
        [TimeSpan]$ECBCacheDifferenceSpan = New-TimeSpan -Hours 999
        if ((Test-Path -Path $EuroExchangeCacheFile)) {
            'ECB-EuroExchange-Cache-File found!' | Write-Verbose
            [xml]$EuroExchangeContent = Get-Content -Path $EuroExchangeCacheFile
            [datetime]$EuroExchangeTime = $EuroExchangeContent.Envelope.Cube.Cube | Select-Object -ExpandProperty 'time'
            [TimeSpan]$ECBCacheDifferenceSpan = (Get-Date) - $EuroExchangeTime
        }

        # ! Is Cache-Difference-TimeSpan greater 39h then update from ECB:
        if($ECBCacheDifferenceSpan.TotalHours -ge 39) {
            'The ECB-EuroExchange-Cache-File is updated because the file was not found or is older then 39 hours.' | Write-Verbose
            Invoke-WebRequest -Uri "http://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml" | Select-Object -ExpandProperty 'Content' | Set-Content -Path $EuroExchangeCacheFile -Force
        }

        # ! Read Cache-File for the next steps:
        [xml]$EuroExchangeContent = Get-Content -Path $EuroExchangeCacheFile
        $EuroExchangeCubes = $EuroExchangeContent.Envelope.Cube.Cube.Cube
        "ECB-EuroExchange-Cache-File from $($EuroExchangeContent.Envelope.Cube.Cube | Select-Object -ExpandProperty 'time') read it." | Write-Verbose

        #endregion

        switch ($PSCmdlet.ParameterSetName) {
            'Overview' {
                "Get-EuroExchange works in Overview-Mode (-ListCurrency = $ListCurrency)." | Write-Verbose
                $EuroExchangeCubes | ForEach-Object -Process { [PSCustomObject]@{ Currency = $_.currency } } | Sort-Object -Property 'Currency'
            }
            'Calculate' {
                'Get-EuroExchange works in Calculate-Mode.' | Write-Verbose
            }
        }
    }
    process {
        if($PSCmdlet.ParameterSetName -eq 'Calculate') {
            [decimal]$CurrencyRate = $EuroExchangeCubes | Where-Object -Property 'currency' -EQ -Value $Currency | Select-Object -ExpandProperty 'rate'
            [PSCustomObject]@{
                Currency    = $Currency.ToUpper()
                Rate        = $CurrencyRate
                Euros       = $Euros
                SumCurrency = $CurrencyRate * $Euros
            }
        }
    }
    end {
        [TimeSpan]$Duration = (Get-Date) - $StartTime
        "Done in $($Duration.TotalMilliseconds) ms!" | Write-Verbose
    }
}

<# ! Manueller UTest bzgl. Feature-Umfang
? Aktueller Wechsel Kurs für USD
Get-EuroExchange -Currency usd

? Aktueller Wechsel Kurs für USD über einen ALias-Parameter
Get-EuroExchange -Währung USD

? Kurs-Produkt für USD und €100
Get-EuroExchange -Currency USD -Euros 100

? Eine Übersicht möglicher Wechselkurs-Symbole mit zusätzlichen Informationen
Get-EuroExchange -ListCurrency -Verbose

? Wird das Default-Set angesprungen
Get-EuroExchange

"USD", "RUB", "AUD" | Get-EuroExchange
"USD", "RUB", "AUD" | Get-EuroExchange -Euros 100
"USD,10", "RUB,100", "AUD,1000" | ConvertFrom-Csv -Header Currency, Euros | Get-EuroExchange
"USD,10", "RUB,100", "AUD,1000" | ConvertFrom-Csv -Header Currency, Euros | Get-EuroExchange | Where-Object SumCurrency -GE 1000
"USD,10", "RUB,100", "AUD,1000" | ConvertFrom-Csv -Header Currency, Euros | Get-EuroExchange | Out-GridView
"USD,10", "RUB,100", "AUD,1000" | ConvertFrom-Csv -Header Währung, Euronen | Get-EuroExchange
Get-EuroExchange -ListCurrency | Get-EuroExchange -Euros 1000
Get-Command -Name Get-EuroExchange -Syntax
Get-ParameterInfo -CmdletName Get-EuroExchange
Get-Help -Name Get-EuroExchange -ShowWindow
Show-Command -Name Get-EuroExchange -NoCommonParameter -ErrorPopup | Out-GridView
#>

<# ! Manueller UTest bzgl. Validierung
Get-EuroExchange # Currency mus abgefragt werden
Get-EuroExchange -Currency USD -ListCurrency # Diese Parameter-Kombination ist nicht erlaubt
Get-EuroExchange -Euros 100 -ListCurrency # Diese Parameter-Kombination ist nicht erlaubt
Get-EuroExchange -Currency XXX # Gibt es nicht
Get-EuroExchange -Currency USD -Euros -100 # Negative Euros sind nicht erlaubt
Get-EuroExchange -Currency USD -Euros 1000001 # Größer als der max. Bereich.
Get-EuroExchange -Currency USD -Euros 0 # 0 Euros sind nicht erlaubt
Get-EuroExchange -Currency USD -Euros hundert # Nur Zahlen sind erlaubt
Get-EuroExchange -Euros 100 # Ohne Währungssymbol nicht erlaubt
Get-EuroExchange -Currency USD, RUB # Zuviel Währungen
Get-EuroExchange -Currency USD -Euros 50, 100 # Zuviel Euros
#>
