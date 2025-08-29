function Get-TopTenCmdlet {
    [CmdletBinding()]
    param ()

    $Content = @(
        [PSCustomObject]@{ Platz = 1 ; Name = 'Get-Member'     ; Beschreibung = 'Objekt-Analyse. Zeigt den Objekt-Typ auf und dessen verfügbaren Mitglieder wie Eigenschaften, Methoden, und Ereignisse.' },
        [PSCustomObject]@{ Platz = 2 ; Name = 'Get-Command'    ; Beschreibung = 'Findet und listet alle verfügbaren Cmdlets, Funktionen, Aliase und Anwendungen auf und kann die Syntax anzeigen.' },
        [PSCustomObject]@{ Platz = 3 ; Name = 'Get-Help'       ; Beschreibung = 'Zeigt Hilfeinformationen für Cmdlets sowie PS-Konzepte an.' },
        [PSCustomObject]@{ Platz = 4 ; Name = 'Select-Object'  ; Beschreibung = 'Das Pipeline-Objekt anpassen, bzgl. Was und Wie viel soll angezeigt werden.' }
        [PSCustomObject]@{ Platz = 5 ; Name = 'Where-Object'   ; Beschreibung = 'Die Pipeline-Objekte über Kriterien filtern.' }
        [PSCustomObject]@{ Platz = 6 ; Name = 'Sort-Object'    ; Beschreibung = 'Die Pipeline-Objekte sortieren.' }
        [PSCustomObject]@{ Platz = 7 ; Name = 'Measure-Object' ; Beschreibung = 'Das Pipeline-Objekte nach einer Eigenschaft messen.' }
    )

    return $Content 
}

