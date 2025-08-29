function Get-Quote {

    [CmdletBinding()]
    param (
        [switch]$QuoteOfDay
    )

    begin {
        class Quote {
            [int] $Number
            [string] $Text
            [string] $Author
            Quote([int] $number, [string] $author, [string] $text) {
                $this.Number = $number
                $this.Author = $author
                $this.Text = $text
            }
        }

        $My = [hashtable]::Synchronized(@{})
        $My.ESC = [char]0x1b
        $My.Quotes = @()
        # (Get-Date).DayOfYear
        $My.Quotes += [Quote]::new(001, 'Unbekannt', '"Welcher Tag ist heute?", fragte Winnie Puuh. "Es ist Heute!", quiekte das Ferkel. "Mein Lieblingstag!", sagte Puuh!')
        $My.Quotes += [Quote]::new(015, 'Sir Arthur Conan Doyle', 'Wenn du das Unmögliche ausgeschlossen hast, dann ist das, was übrig bleibt, die Wahrheit, wie unwahrscheinlich sie auch ist.')
        $My.Quotes += [Quote]::new(030, 'Unbekannt', 'Am Ende wird alles gut. Und wenn es nicht gut ist, ist es noch nicht das Ende.')
        $My.Quotes += [Quote]::new(045, 'Forrest Gump', 'Das Leben ist wie eine Schachtel Pralinen, man weiß nie, was man bekommt.')
        $My.Quotes += [Quote]::new(064, 'Edward Aloysius Murphy Jr.', 'Alles, was schiefgehen kann, geht schief.')
        $My.Quotes += [Quote]::new(090, 'Unbekannt', 'Die Arbeit läuft Dir nicht davon, wenn Du Deinem Kind den Regenbogen zeigst. Aber der Regenbogen wartet nicht, bis Du mit Deiner Arbeit fertig bist. Lebe und Liebe!')
        $My.Quotes += [Quote]::new(136, 'Guido van Rossum', 'Software ist wie Humor, es sollte sich selbst erklären.')
        $My.Quotes += [Quote]::new(125, 'Konfuzius', 'Auch der weiteste Weg beginnt mit einem ersten Schritt.')
        $My.Quotes += [Quote]::new(150, 'Unbekannt', 'Wenn Du denkst, dass Du zu klein bist, um etwas zu bewirken, dann versuche mal zu schlafen, wenn eine Mücke im Raum ist.')
        $My.Quotes += [Quote]::new(180, 'Walter Wemmer', 'Schmutz kann einem Goldstück den Glanz nehmen, aber wenn Du das Goldstück putzt, wird es wiederneu erstrahlen. Fürchte Dich daher nicht, wenn Dich jemand in den Schlamm zieht, putz Dich ab und erfreue Dich an Deinem neuen Glanz.')
        $My.Quotes += [Quote]::new(200, 'Edward Aloysius Murphy Jr.', 'Wenn es mehrere Möglichkeiten gibt, eine Aufgabe zu erledigen, und eine davon in einer Katastrophe endet oder sonstwie unerwünschte Konsequenzen nach sich zieht, dann wird es jemand genau so machen.')
        $My.Quotes += [Quote]::new(225, 'Christina Gruber-Eifert', 'Wenn dein Ziel wirklich klar ist, wird dich auch kein Zweifel mehr von deinem Weg ab bringen!')
        $My.Quotes += [Quote]::new(270, 'Unbekannt', 'Wenn der Wind der Veränderung weht, bauen die einen Mauern und die anderen Windmühlen. Zu Welchen der Beiden gehörst Du? Jetzt kommt es drauf an, dass Du weitermachst, auch wenn die Dinge nicht so laufen wie Du sie Dir vorgestellt hast. Nimm den Windstoß und fliege!')
        $My.Quotes += [Quote]::new(260, 'Unbekannt', 'In deinem Kopf mag das logisch sein, aber ich bin hier draußen!')
        $My.Quotes += [Quote]::new(280, 'Unbekannt', 'Da lernt man Dreisatz und Wahrscheinlichkeitsrechnung und steht trotzdem grübelnd vor dem Backofen, welche der vier Schienen nun die Mittlere ist.')
        $My.Quotes += [Quote]::new(300, 'Erich Kestner', 'Es ist ungleich besser, beizeiten Dämme zu bauen, als darauf zu hoffen, dass die Flut Vernunft annimmt.')
        $My.Quotes += [Quote]::new(350, 'Orson Welles', 'Viele Menschen sind zu gut erzogen, um mit vollem Mund zu sprechen, aber sie haben keine Bedenken, es mit leerem Kopf zu tun')

        $My.SelectedQuote = $My.Quotes | Get-Random

        if ($QuoteOfDay) {
            $My.DayOfYear = [datetime]::Today.DayOfYear
            $My.SelectedQuote = $My.Quotes | Sort-Object -Property { return [Math]::Abs($My.DayOfYear - $_[0].Number) } | Select-Object -First 1
        }

        "`n$($My.ESC)[92m$($My.SelectedQuote.Text)$($My.ESC)[0m`n$($My.ESC)[97m$($My.SelectedQuote.Author), $($My.SelectedQuote.Number)$($My.ESC)[0m" | Write-Output
    }
}