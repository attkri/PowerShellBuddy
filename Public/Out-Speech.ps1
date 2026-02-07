function Out-Speech {
    <#
        .SYNOPSIS
        Text zu Sprach-Ausgabe.

        .DESCRIPTION
        Wandelt String-Objekte in Sprachausgabe um mit Unterstützung für verschiedene Stimmen,
        asynchrone Wiedergabe und Plattform-Erkennung.

        .PARAMETER TextToSpeech
        Das String-Objekt das in eine Sprachausgabe umgewandelt werden soll.

        .PARAMETER VoiceName
        Name der zu verwendenden Stimme. Verwende Get-SpeechVoice um verfügbare Stimmen anzuzeigen.

        .PARAMETER VoiceSpeed
        Geschwindigkeit der Sprachausgabe von -10 bis 10.

        .PARAMETER Volume
        Lautstärke der Sprachausgaben von 0 bis 100.

        .PARAMETER Asynchronous
        Startet die Sprachausgabe asynchron ohne auf Beendigung zu warten.

        .PARAMETER ShowAvailableVoices
        Zeigt alle verfügbaren Stimmen an und beendet die Funktion.

        .EXAMPLE
        Out-Speech -TextToSpeech 'Hallo Welt!'
        Einfache Text-to-Speech Ausgabe.

        .EXAMPLE
        Out-Speech -TextToSpeech 'Zwölf laxe Typen qualmen verdächtig süße Objekte.' -VoiceSpeed +2 -Volume 80
        Sprachausgabe mit angepasster Geschwindigkeit und Lautstärke.

        .EXAMPLE
        Out-Speech -ShowAvailableVoices
        Zeigt alle verfügbaren Stimmen an.

        .EXAMPLE
        Out-Speech -TextToSpeech 'Asynchrone Nachricht' -Asynchronous
        Sprachausgabe läuft im Hintergrund weiter.

        .EXAMPLE
        'Franz jagt im komplett verwahrlosten Taxi quer durch Bayern', 'Bei jedem klugen Wort von Sokrates rief Xanthippe zynisch: Quatsch!' | Out-Speech
        Mehrere Texte aus der Pipeline.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ParameterSetName = 'Speak')]
        [string]$TextToSpeech,

        [Parameter(ParameterSetName = 'Speak')]
        [string]$VoiceName,

        [Parameter(ParameterSetName = 'Speak')]
        [ValidateRange(-10, 10)]
        [int]$VoiceSpeed = 0,

        [Parameter(ParameterSetName = 'Speak')]
        [ValidateRange(0, 100)]
        [int]$Volume = 100,

        [Parameter(ParameterSetName = 'Speak')]
        [switch]$Asynchronous,

        [Parameter(ParameterSetName = 'ListVoices')]
        [switch]$ShowAvailableVoices
    )

    begin {
        try {
            $platform = [System.Environment]::OSVersion.Platform

            if ($platform -ne 'Win32NT' -and $PSEdition -ne 'Desktop') {
                Write-Warning "Out-Speech wird nur auf Windows mit System.Speech voll unterstützt. Auf anderen Plattformen wird eine Warnung angezeigt."
                return
            }

            Add-Type -AssemblyName System.Speech -ErrorAction Stop
            $Speaker = New-Object -TypeName 'System.Speech.Synthesis.SpeechSynthesizer' -ErrorAction Stop

            if ($ShowAvailableVoices) {
                $Speaker.GetInstalledVoices() | ForEach-Object {
                    if ($_.Enabled) {
                        [PSCustomObject]@{
                            Name        = $_.VoiceInfo.Name
                            Culture     = $_.VoiceInfo.Culture.Name
                            Gender      = $_.VoiceInfo.Gender
                            Age         = $_.VoiceInfo.Age
                            Description = $_.VoiceInfo.Description
                        }
                    }
                }
                $Speaker.Dispose()
                return
            }

            if ($VoiceName) {
                try {
                    $availableVoice = $Speaker.GetInstalledVoices() | Where-Object { 
                        $_.Enabled -and $_.VoiceInfo.Name -like "*$VoiceName*" 
                    } | Select-Object -First 1

                    if ($availableVoice) {
                        $Speaker.SelectVoice($availableVoice.VoiceInfo.Name)
                    } else {
                        Write-Warning "Stimme '$VoiceName' nicht gefunden. Verwende Standardstimme."
                    }
                } catch {
                    Write-Warning "Fehler beim Auswählen der Stimme: $_"
                }
            }

            $Speaker.Rate = $VoiceSpeed
            $Speaker.Volume = $Volume

        } catch {
            Write-Error "Fehler beim Initialisieren der Sprachausgabe: $_"
            if ($Speaker) { $Speaker.Dispose() }
            throw
        }
    }

    process {
        if (-not $ShowAvailableVoices -and $Speaker -and $TextToSpeech) {
            try {
                if ($Asynchronous) {
                    $Speaker.SpeakAsync($TextToSpeech) | Out-Null
                } else {
                    $Speaker.Speak($TextToSpeech)
                }
            } catch {
                Write-Error "Fehler bei der Sprachausgabe: $_"
            }
        }
    }

    end {
        if ($Speaker -and -not $Asynchronous) {
            $Speaker.Dispose()
        }
    }
}
