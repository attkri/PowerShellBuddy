function Get-Hotkey {
    [CmdletBinding()]
    param ()

    $Content = @(
        [PSCustomObject]@{ Bereich = 'VSCode'  ; Tastaturkürzel = '[F8]'                           ; Beschreibung = 'Führt die aktuelle Zeile aus oder die Selektion.' }
        [PSCustomObject]@{ Bereich = 'VSCode'  ; Tastaturkürzel = '[F5]'                           ; Beschreibung = 'Führt die gesamt .PS1-Datei aus.' }
        [PSCustomObject]@{ Bereich = 'VSCode'  ; Tastaturkürzel = '[SHIFT + [ALT] + [PFEIL-TASTE]' ; Beschreibung = 'Klont die aktuelle Zeile aus oder die Selektion.' }
        [PSCustomObject]@{ Bereich = 'VSCode'  ; Tastaturkürzel = '[ALT + [PFEIL-TASTE]'           ; Beschreibung = 'Verschiebt die aktuelle Zeile aus oder die Selektion.' }
        [PSCustomObject]@{ Bereich = 'VSCode'  ; Tastaturkürzel = '[STRG] + [SPACE]'               ; Beschreibung = 'Öffnet die Vorschlagsliste.' }
        [PSCustomObject]@{ Bereich = 'VSCode'  ; Tastaturkürzel = '[STRG] + [ALT] + [J]'           ; Beschreibung = 'Öffnet eine Übersicht zur Auswahl sämtlicher PowerShell-Templates.' }
        [PSCustomObject]@{ Bereich = 'Console' ; Tastaturkürzel = '[STRG] + [SPACE]'               ; Beschreibung = 'Öffnet die Vorschlagsliste.' }
    )

    return $Content 
}

<#
Get-Hotkey
#>