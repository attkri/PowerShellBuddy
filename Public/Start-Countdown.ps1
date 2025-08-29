<#
    .SYNOPSIS
        Shows the remaining term.

    .EXAMPLE
        Start-Countdown -Title 'Coffee pause end in' -Hours 1 -Minutes 2 -seconds 30
#>
function Start-Countdown {

    [CmdletBinding(ConfirmImpact = 'Low')]
    param (
        [ValidateRange(0, 24)]
        [int]$Hours,
        
        [ValidateRange(0, 59)]
        [int]$Minutes,

        [ValidateRange(0, 59)]
        [int]$Seconds,

        # Title to display in the console
        [ValidateLength(3, 50)]
        [string]$Title = 'Remaining term of the countdown'
    )

    $My = [Hashtable]::Synchronized(@{})
    $My.Duration = New-TimeSpan -Hours $Hours -Minutes $Minutes -Seconds $Seconds 
    $My.End = (Get-Date) + $My.Duration
    $My.HundertPercentValue = $My.Duration.TotalSeconds

    $My.AsciDigits = @'
███;..█;███;███;█.█;███;███;███;███;███
█.█;..█;..█;..█;█.█;█..;█..;..█;█.█;█.█
█.█;..█;███;███;███;███;███;..█;███;███
█.█;..█;█..;..█;..█;..█;█.█;..█;█.█;..█
███;..█;███;███;..█;███;███;..█;███;..█
'@ | ConvertFrom-Csv -Delimiter ';' -Header '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'

    while (1 -eq 1) {
        
        $My.Difference = New-TimeSpan -End $My.End
        if ($My.Difference.Ticks -le 0) {
            break
        }

        Clear-Host

        $My.CountDownMode = if ($My.Difference.Hours -gt 0) { 'HH:mm' } else { 'mm:ss' }
        $My.Title = "$Title ($($My.CountDownMode))"
        
        "`r`n$($My.Title)" | Write-Host -ForegroundColor Yellow
        "▔" * $My.Title.Length | Write-Host -ForegroundColor Yellow

        $My.HourTenDigit = ($My.Difference.Hours - $My.Difference.Hours % 10) / 10 
        $My.HourOneDigit = $My.Difference.Hours % 10

        $My.MinuteTenDigit = ($My.Difference.Minutes - $My.Difference.Minutes % 10) / 10 
        $My.MinuteOneDigit = $My.Difference.Minutes % 10

        $My.SecondTenDigit = ($My.Difference.Seconds - $My.Difference.Seconds % 10) / 10
        $My.SecondOneDigit = $My.Difference.Seconds % 10
        
        for ($i = 0; $i -lt 5; $i++) {
            if ($i -in 1, 3) { $dot = "█" } else { $dot = "." }

            if ($My.Difference.Hours -gt 0) {
                '.' + $My.AsciDigits[$i].($My.HourTenDigit) + '.' + $My.AsciDigits[$i].($My.HourOneDigit) + '.' + $dot + '.' + $My.AsciDigits[$i].($My.MinuteTenDigit) + '.' + $My.AsciDigits[$i].($My.MinuteOneDigit) + '.' | Write-Host -ForegroundColor Green
            }
            else {
                '.' + $My.AsciDigits[$i].($My.MinuteTenDigit) + '.' + $My.AsciDigits[$i].($My.MinuteOneDigit) + '.' + $dot + '.' + $My.AsciDigits[$i].($My.SecondTenDigit) + '.' + $My.AsciDigits[$i].($My.SecondOneDigit) + '.' | Write-Host -ForegroundColor Green
            }
        }

        "`r`n" | Write-Host -NoNewline

        $My.ProgressInPercent = ($My.Difference.TotalSeconds - 1) / $My.Duration.TotalSeconds * 100
        if ($My.ProgressInPercent -lt 0) { $My.ProgressInPercent = 0 }
        "[$([Math]::Round($My.ProgressInPercent, 0)) %] " + "▌" * $My.ProgressInPercent | Write-Host
        
        ("LOOP       => Progress left: {0:0.00} % | CDMode: {1} | Current-Date: {2:ddd. dd. HH:mm:ss}" -f $My.ProgressInPercent, $My.CountDownMode, (Get-Date)) | Write-Verbose
        ("TARGETING  => Duration: {0} h {1} m {2} s                 | End-Date    : {3:ddd. dd. HH:mm:ss}" -f $My.Duration.Hours, $My.Duration.Minutes, $My.Duration.Seconds, $My.End) | Write-Verbose
        ("PARAMETERS => Hours: {0} | Minutes: {1} | Seconds: {2} | Title: {3}" -f $Hours, $Minutes, $Seconds, $Title) | Write-Verbose

        if ($My.Difference.Hours -gt 0) { Start-Sleep -Seconds 60 } else { Start-Sleep -Seconds 1 }
        
    }
}

<#
Start-Countdown -Title 'Coffee pause end in' -Hours 1 -Minutes 2 -seconds 30
Start-Countdown -Title 'Coffee pause end in'  -Minutes 2 -seconds 30
Start-Countdown -Title 'Coffee pause end in' -Hours 1 -Minutes 0 -seconds 3
Start-Countdown -Title 'Coffee pause end in' -Minutes 5 -seconds 10 -Verbose
#>
