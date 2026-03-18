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
        $My.Quotes += [Quote]::new(001, 'Unknown', '"What day is it?" asked Pooh. "It is today," squeaked Piglet. "My favorite day," said Pooh.')
        $My.Quotes += [Quote]::new(015, 'Sir Arthur Conan Doyle', 'When you have eliminated the impossible, whatever remains, however improbable, must be the truth.')
        $My.Quotes += [Quote]::new(030, 'Unknown', 'In the end, everything will be okay. If it is not okay, it is not the end yet.')
        $My.Quotes += [Quote]::new(045, 'Forrest Gump', 'Life is like a box of chocolates. You never know what you are going to get.')
        $My.Quotes += [Quote]::new(064, 'Edward Aloysius Murphy Jr.', 'Anything that can go wrong will go wrong.')
        $My.Quotes += [Quote]::new(090, 'Unknown', 'Work will not run away while you show your child a rainbow, but the rainbow will not wait until your work is done.')
        $My.Quotes += [Quote]::new(125, 'Confucius', 'The longest journey begins with a single step.')
        $My.Quotes += [Quote]::new(136, 'Guido van Rossum', 'Code is like humor. When you have to explain it, it is bad.')
        $My.Quotes += [Quote]::new(150, 'Unknown', 'If you think you are too small to make a difference, try sleeping with a mosquito in the room.')
        $My.Quotes += [Quote]::new(180, 'Unknown', 'A little dirt can hide the shine of gold, but once you clean it, the shine returns.')
        $My.Quotes += [Quote]::new(200, 'Edward Aloysius Murphy Jr.', 'If there are several ways to do something and one of them leads to disaster, someone will choose that one.')
        $My.Quotes += [Quote]::new(225, 'Unknown', 'When your goal is truly clear, doubt loses much of its power.')
        $My.Quotes += [Quote]::new(260, 'Unknown', 'It may sound logical in your head, but I am dealing with the real world out here.')
        $My.Quotes += [Quote]::new(270, 'Unknown', 'When the winds of change blow, some build walls and others build windmills.')
        $My.Quotes += [Quote]::new(280, 'Unknown', 'You can learn math, probability, and logic and still stare at the oven wondering which rack is actually the middle one.')
        $My.Quotes += [Quote]::new(300, 'Erich Kastner', 'It is far better to build dams in time than to hope the flood will come to its senses.')
        $My.Quotes += [Quote]::new(350, 'Orson Welles', 'Many people are too well educated to speak with a full mouth, but they have no problem speaking with an empty head.')

        $My.SelectedQuote = $My.Quotes | Get-Random

        if ($QuoteOfDay) {
            $My.DayOfYear = [datetime]::Today.DayOfYear
            $My.SelectedQuote = $My.Quotes | Sort-Object -Property { return [Math]::Abs($My.DayOfYear - $_[0].Number) } | Select-Object -First 1
        }

        "`n$($My.ESC)[92m$($My.SelectedQuote.Text)$($My.ESC)[0m`n$($My.ESC)[97m$($My.SelectedQuote.Author), $($My.SelectedQuote.Number)$($My.ESC)[0m" | Write-Output
    }
}
