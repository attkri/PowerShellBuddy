function Out-Speech {
    <#
        .SYNOPSIS
        Converts text into spoken output.

        .DESCRIPTION
        Converts string input into speech output with support for voice selection,
        asynchronous playback, and platform detection.

        .PARAMETER TextToSpeech
        The text that should be spoken.

        .PARAMETER VoiceName
        Name of the voice to use. Use -ShowAvailableVoices to list installed voices.

        .PARAMETER VoiceSpeed
        Speech rate from -10 to 10.

        .PARAMETER Volume
        Output volume from 0 to 100.

        .PARAMETER Asynchronous
        Starts speech playback asynchronously without waiting for completion.

        .PARAMETER ShowAvailableVoices
        Lists all available voices and exits.

        .EXAMPLE
        Out-Speech -TextToSpeech 'Hello world!'
        Simple text-to-speech output.

        .EXAMPLE
        Out-Speech -TextToSpeech 'PowerShell can automate repetitive work.' -VoiceSpeed 2 -Volume 80
        Speech output with custom speed and volume.

        .EXAMPLE
        Out-Speech -ShowAvailableVoices
        List all available voices.

        .EXAMPLE
        Out-Speech -TextToSpeech 'Background message' -Asynchronous
        Speech playback continues in the background.

        .EXAMPLE
        'Short sentence one', 'Short sentence two' | Out-Speech
        Speak multiple texts from the pipeline.
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
                Write-Warning 'Out-Speech is fully supported only on Windows with System.Speech available.'
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
                        Write-Warning "Voice '$VoiceName' was not found. Using the default voice instead."
                    }
                } catch {
                    Write-Warning "Error while selecting the voice: $_"
                }
            }

            $Speaker.Rate = $VoiceSpeed
            $Speaker.Volume = $Volume

        } catch {
            Write-Error "Error while initializing speech output: $_"
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
                Write-Error "Speech output failed: $_"
            }
        }
    }

    end {
        if ($Speaker -and -not $Asynchronous) {
            $Speaker.Dispose()
        }
    }
}
