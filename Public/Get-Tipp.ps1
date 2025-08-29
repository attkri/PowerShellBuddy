function Get-Tipp {
    [CmdletBinding()]
    param (
        [switch]$All
    )

    $Content = @(
        [PSCustomObject]@{ Tipp = 'Überfliege regelmäßig die About-Seiten und lese dich in spannende Artikel an, um am Ball zu bleiben.' }
        [PSCustomObject]@{ Tipp = 'Beschäftige dich mit Pester, um deine Skripte automatisch zu testen.' }
        [PSCustomObject]@{ Tipp = 'Installiere die PowerShell-Offline-Hilfe, um immer an den Hilfe-Inhalt, auch von nicht MS-Cmdlets.' }
        [PSCustomObject]@{ Tipp = 'Benutze Visual Studio Code mit der PowerShell-Extension, weil das ist der Beste Editor, nicht nur für PowerShell.' }
        [PSCustomObject]@{ Tipp = 'Mit Get-Member und Select-Object ist es schnell nachgeschaut als durch Try-And-Error die Lösung zu erraten.' }
        [PSCustomObject]@{ Tipp = 'Nutze in der Pipeline Extend Properties, um Pipeline-Objekte anzupassen. Das erhöht die Bindungsfähigkeit und passt die Ausgabe an die eigene Bedürfnis an.' }
        [PSCustomObject]@{ Tipp = 'Um weitere hilfreiche Tools zu erhalten siehe PowerShell-Gallery nach PowerShellBuddy, WindowsAid und PowerShellTutor von Attila Krick.' }
        [PSCustomObject]@{ Tipp = 'Um realistische Vorlagen von Module-Aufbau und Cmdlets zu studieren siehe PowerShell-Gallery nach PowerShellBuddy, WindowsAid und PowerShellTutor von Attila Krick.' }
    )

    if(-not $All.IsPresent) {
        $Content = $Content | Get-Random -Count 1
    }

    return $Content
}

<#
Get-Tipp
Get-Tipp -All
#>


