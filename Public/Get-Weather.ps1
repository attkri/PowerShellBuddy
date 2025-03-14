<<<<<<< HEAD
﻿function Get-Weather {
    [CmdletBinding()]
    param (
        [string]$Location, 
        
        [switch]$OnlyCurrentWeather,
        
        [ValidateSet('af', 'am', 'ar', 'az', 'be', 'bg', 'bn', 'bs', 'ca', 'cs', 'cy', 'da', 'de', 'el', 'eo', 'es', 'et', 'eu', 'fa', 'fi', 'fr', 'fy', 'ga', 'gl', 'he', 'hi', 'hi', 'hr', 'hu', 'hy', 'ia', 'id', 'is', 'it', 'ja', 'jv', 'ka', 'kk', 'ko', 'ky', 'lt', 'lv', 'mg', 'mk', 'ml', 'mr', 'nb', 'nl', 'nl', 'nn', 'oc', 'pl', 'pt', 'pt-br', 'pt-br', 'ro', 'ru', 'sk', 'sl', 'sr', 'sr-lat', 'sv', 'sw', 'ta', 'te', 'th', 'tr', 'uk', 'uz', 'vi', 'zh', 'zh-cn', 'zh-tw', 'zu')]
        [string]$Language = (Get-Culture | Select-Object -ExpandProperty 'TwoLetterISOLanguageName'),

        [switch]$OneLineOutput
    )
    
    [string]$Uri = 'https://wttr.in/'                                  # Base URL
    [string]$Uri += '<Location>' -replace '<Location>', $Location # Location
    [string]$Uri += '?lang=<Language>' -replace '<Language>', $Language # Language
    [string]$Uri += '&F'                                                # F => do not show the "Follow" line
    
    if ($OnlyCurrentWeather.IsPresent) {
        $Uri += '0' # only current weather
    }

    if ($OneLineOutput.IsPresent) {
        [string]$Uri += '&format=3'  # For one-line output format: 1: Current weather at location: 🌦 +11⁰C, 2: Current weather at location with more details: 🌦   🌡️+11°C 🌬️↓4km/h, 3: Name of location and current weather at location: Nuremberg: 🌦 +11⁰C, 4: Name of location and current weather at location with more details: Nuremberg: 🌦   🌡️+11°C 🌬️↓4km/h
    }
    
    "Used Uri $Uri" | Write-Verbose

    try {
        Invoke-RestMethod -Uri $Uri -UseBasicParsing -OperationTimeoutSeconds 3 -ErrorAction Stop -Verbose:$false
    }
    catch {
        throw "We were unable to find your location or could not retrieve weather data. Please check your internet connection or the location provided."
    }
}

<#
https://wttr.in/:help
Get-Weather -Location Hamburg -Verbose -OneLineOutput
#>
=======
﻿function Get-Weather {
    [CmdletBinding()]
    param (
        [string]$Location, 
        
        [switch]$OnlyCurrentWeather,
        
        [ValidateSet('af', 'am', 'ar', 'az', 'be', 'bg', 'bn', 'bs', 'ca', 'cs', 'cy', 'da', 'de', 'el', 'eo', 'es', 'et', 'eu', 'fa', 'fi', 'fr', 'fy', 'ga', 'gl', 'he', 'hi', 'hi', 'hr', 'hu', 'hy', 'ia', 'id', 'is', 'it', 'ja', 'jv', 'ka', 'kk', 'ko', 'ky', 'lt', 'lv', 'mg', 'mk', 'ml', 'mr', 'nb', 'nl', 'nl', 'nn', 'oc', 'pl', 'pt', 'pt-br', 'pt-br', 'ro', 'ru', 'sk', 'sl', 'sr', 'sr-lat', 'sv', 'sw', 'ta', 'te', 'th', 'tr', 'uk', 'uz', 'vi', 'zh', 'zh-cn', 'zh-tw', 'zu')]
        [string]$Language = (Get-Culture | Select-Object -ExpandProperty 'TwoLetterISOLanguageName'),

        [switch]$OneLineOutput
    )
    
    [string]$Uri = 'https://wttr.in/'                                  # Base URL
    [string]$Uri += '<Location>' -replace '<Location>', $Location # Location
    [string]$Uri += '?lang=<Language>' -replace '<Language>', $Language # Language
    [string]$Uri += '&F'                                                # F => do not show the "Follow" line
    
    if ($OnlyCurrentWeather.IsPresent) {
        $Uri += '0' # only current weather
    }

    if ($OneLineOutput.IsPresent) {
        [string]$Uri += '&format=3'  # For one-line output format: 1: Current weather at location: 🌦 +11⁰C, 2: Current weather at location with more details: 🌦   🌡️+11°C 🌬️↓4km/h, 3: Name of location and current weather at location: Nuremberg: 🌦 +11⁰C, 4: Name of location and current weather at location with more details: Nuremberg: 🌦   🌡️+11°C 🌬️↓4km/h
    }
    
    "Used Uri $Uri" | Write-Verbose

    try {
        Invoke-RestMethod -Uri $Uri -UseBasicParsing -OperationTimeoutSeconds 3 -ErrorAction Stop -Verbose:$false
    }
    catch {
        throw "We were unable to find your location or could not retrieve weather data. Please check your internet connection or the location provided."
    }
}

<#
https://wttr.in/:help
Get-Weather -Location Hamburg -Verbose -OneLineOutput
#>
>>>>>>> 47bdafb926307894e343ff9720d2bc56b970228c
