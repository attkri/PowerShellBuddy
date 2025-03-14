<<<<<<< HEAD
﻿
<#
todo Test
Out-Speech -TextToSpeech 'Zwölf laxe Typen qualmen verdächtig süße Objekte.' -VoiceSpeed +2 -Volume 80
Out-Speech
Out-Speech -TextToSpeech 'Zwölf laxe Typen qualmen verdächtig süße Objekte.' -VoiceSpeed 200 -Volume 70
Out-Speech -TextToSpeech 'Zwölf laxe Typen qualmen verdächtig süße Objekte.' -VoiceSpeed zwei -Volume 70
Get-Command Out-Speech -Syntax
Get-Help -Name Out-Speech -ShowWindow
'Franz jagt im komplett verwahrlosten Taxi quer durch Bayern', 'Bei jedem klugen Wort von Sokrates rief Xanthippe zynisch: Quatsch!' | Out-Speech
Get-ChildItem c:\temp -File | Out-Speech
#>
function Out-Speech {
    <#
        .SYNOPSIS
        Text zu Sprach-Ausgabe.

        .DESCRIPTION
        Wandelt String-Objekte in Sprachausgabe um.

        .PARAMETER TextToSpeech
        Das String String-Objekt das in eine Sprachausgabe umgewandelt werden soll.

        .PARAMETER VoiceSpeed
        Geschwindigkeit der Sprachausgabe von -10 bis 10.

        .PARAMETER Volume
        Lautstärke der Sprachausgaben von 0 bis 100

        .EXAMPLE
        Get-Command -Name Out-Speech -Syntax
        Get-Help -Name Out-Speech -ShowWindow
        Cmdlet verstehen.

        .EXAMPLE
        Out-Speech -TextToSpeech 'Zwölf laxe Typen qualmen verdächtig süße Objekte.'
        Beschreibung des Beispiels....

        .EXAMPLE
        Out-Speech -TextToSpeech 'Zwölf laxe Typen qualmen verdächtig süße Objekte.' -VoiceSpeed +2 -Volume 80
        Beschreibung des Beispiels....
    #>
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$TextToSpeech,

        [ValidateRange(-10,10)]
        [int]$VoiceSpeed = 0,

        [ValidateRange(0,100)]
        [int]$Volume = 100
    )

    begin {
        Add-Type -AssemblyName System.Speech # TODO Evtl. wird das akt. immer geladen
        $Speaker = New-Object -TypeName 'System.Speech.Synthesis.SpeechSynthesizer'
        $Speaker.Rate = $VoiceSpeed
        $Speaker.Volume = $Volume
    }
    process {
        $Speaker.Speak($TextToSpeech)
    }
    end {
        Remove-Variable -Name Speaker -Force -ErrorAction Ignore
    }
}
=======
﻿
<#
todo Test
Out-Speech -TextToSpeech 'Zwölf laxe Typen qualmen verdächtig süße Objekte.' -VoiceSpeed +2 -Volume 80
Out-Speech
Out-Speech -TextToSpeech 'Zwölf laxe Typen qualmen verdächtig süße Objekte.' -VoiceSpeed 200 -Volume 70
Out-Speech -TextToSpeech 'Zwölf laxe Typen qualmen verdächtig süße Objekte.' -VoiceSpeed zwei -Volume 70
Get-Command Out-Speech -Syntax
Get-Help -Name Out-Speech -ShowWindow
'Franz jagt im komplett verwahrlosten Taxi quer durch Bayern', 'Bei jedem klugen Wort von Sokrates rief Xanthippe zynisch: Quatsch!' | Out-Speech
Get-ChildItem c:\temp -File | Out-Speech
#>
function Out-Speech {
    <#
        .SYNOPSIS
        Text zu Sprach-Ausgabe.

        .DESCRIPTION
        Wandelt String-Objekte in Sprachausgabe um.

        .PARAMETER TextToSpeech
        Das String String-Objekt das in eine Sprachausgabe umgewandelt werden soll.

        .PARAMETER VoiceSpeed
        Geschwindigkeit der Sprachausgabe von -10 bis 10.

        .PARAMETER Volume
        Lautstärke der Sprachausgaben von 0 bis 100

        .EXAMPLE
        Get-Command -Name Out-Speech -Syntax
        Get-Help -Name Out-Speech -ShowWindow
        Cmdlet verstehen.

        .EXAMPLE
        Out-Speech -TextToSpeech 'Zwölf laxe Typen qualmen verdächtig süße Objekte.'
        Beschreibung des Beispiels....

        .EXAMPLE
        Out-Speech -TextToSpeech 'Zwölf laxe Typen qualmen verdächtig süße Objekte.' -VoiceSpeed +2 -Volume 80
        Beschreibung des Beispiels....
    #>
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$TextToSpeech,

        [ValidateRange(-10,10)]
        [int]$VoiceSpeed = 0,

        [ValidateRange(0,100)]
        [int]$Volume = 100
    )

    begin {
        Add-Type -AssemblyName System.Speech # TODO Evtl. wird das akt. immer geladen
        $Speaker = New-Object -TypeName 'System.Speech.Synthesis.SpeechSynthesizer'
        $Speaker.Rate = $VoiceSpeed
        $Speaker.Volume = $Volume
    }
    process {
        $Speaker.Speak($TextToSpeech)
    }
    end {
        Remove-Variable -Name Speaker -Force -ErrorAction Ignore
    }
}
>>>>>>> 47bdafb926307894e343ff9720d2bc56b970228c
