<<<<<<< HEAD
﻿BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-StringHash Tests" {
    Context "Stimmt das Cmdlet Manifest?" {
        It "Ist der String-Parameter 'Algorithm' korrekt definiert?" {
            $ParameterInfo = (Get-Command -Name 'Get-StringHash').Parameters['Algorithm']
            $ParameterInfo.Attributes.Where{ $_ -is [ValidateSet] } | Should -HaveCount 1
        
            $ValidateSet = $ParameterInfo.Attributes.Where{ $_ -is [ValidateSet] }
            $ValidateSet.ValidValues -contains 'SHA512' | Should -BeTrue
            $ValidateSet.ValidValues -contains 'MD5' | Should -BeTrue

            Get-Command -Name 'Get-StringHash' | Should -ParameterName 'Algorithm' -Type [String] -DefaultValue 'SHA512' -InParameterSet 'Text'
        }
        It "Ist der String-Parameter 'Text' Pflicht?" {
            Get-Command -Name 'Get-StringHash' | Should -ParameterName 'Text' -Type [String] -InParameterSet 'Text'
        }
        It "Ist der String-Parameter 'Password' Pflicht?" {
            Get-Command -Name 'Get-StringHash' | Should -ParameterName 'Password' -Type [SecureString] -InParameterSet 'Password'
        }
        It "Ist der String-Parameter 'Salt' Pflicht?" {
            Get-Command -Name 'Get-StringHash' | Should -ParameterName 'Salt' -Type [String] -InParameterSet 'Password'
        }
    }

    Context "Hash-Ausgabe Tests" {
        BeforeAll {
            function StringToMD5HashString([string]$Text) {
                $TextBytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
                $HashBytes = [System.Security.Cryptography.MD5]::HashData($TextBytes)
                return [System.Convert]::ToBase64String($HashBytes)
            }
            function StringToSHA512HashString([string]$Text) {
                $TextBytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
                $HashBytes = [System.Security.Cryptography.SHA512]::HashData($TextBytes)
                return [System.Convert]::ToBase64String($HashBytes)
            }
        }
        It "Wird Text korrekt in ein SHA512-Hash-Objekt umgewandelt?" {
            $TextToHash = "Das ist ein Testtext!"
            $ExpectedHash = StringToSHA512HashString($TextToHash)

            $Target = Get-StringHash -Text $TextToHash
            $Target.GetType().FullName | Should -BeExactly 'StringHashInfo'
            $Target.Algorithm | Should -BeExactly 'SHA512'
            $Target.Hash | Should -BeExactly $ExpectedHash
            $Target.Text | Should -BeExactly $TextToHash
        }
        It "Wird Text korrekt in ein MD5-Hash-Objekt umgewandelt?" {
            $TextToHash = "Das ist ein Testtext!"
            $ExpectedHash = StringToMD5HashString($TextToHash)

            $Target = Get-StringHash -Text $TextToHash -Algorithm MD5
            $Target.GetType().FullName | Should -BeExactly 'StringHashInfo'
            $Target.Algorithm | Should -BeExactly 'MD5'
            $Target.Hash | Should -BeExactly $ExpectedHash
            $Target.Text | Should -BeExactly $TextToHash
        }
        It "Wird der Passwort-Hash korrekt berechnet?" {
            $TextToHash = 'P@$$w0rd1' | ConvertTo-SecureString -AsPlainText
            $Salt = 'vb23er45zu'
        
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($TextToHash)
            $ExpectedHash = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            for ($i = 0; $i -lt 20000; $i++) {
                $ExpectedHash = StringToMD5HashString($ExpectedHash + $Salt)
            }

            $Target = Get-StringHash -Password $TextToHash -Salt $Salt
            $Target | Should -BeOfType [String]
            $Target | Should -BeExactly $ExpectedHash
        }
        It "Erwarteter MD5 <ExpectedHash> vom Text <TestText>" -TestCases @(
            @{ TestText = "Baumhaus!1234"; ExpectedHash = 'IkGlrOYsv1tFtBqMoEA5dQ==' }
            @{ TestText = "SuppenTüte471"; ExpectedHash = '2pVbM7L4/bLmD+aWNhAt1g==' }
            @{ TestText = "DingDong00815"; ExpectedHash = 'SKX11Dqvj3S7a37DNtrwcQ==' }
        ) {
            $Target = Get-StringHash -Text $TestText -Algorithm MD5
            $Target.Hash | Should -BeExactly $ExpectedHash
        }
        It "Arbeitet die Pipeline-Verarbeitung im Text-Modus korrekt?" {
            $Target = 'Baumhaus!1234', 'SuppenTüte471', 'DingDong00815' | Get-StringHash -Algorithm MD5
            $Target.Algorithm | Should -BeExactly @('MD5', 'MD5', 'MD5')
            $Target.Hash | Should -BeExactly @('IkGlrOYsv1tFtBqMoEA5dQ==', '2pVbM7L4/bLmD+aWNhAt1g==', 'SKX11Dqvj3S7a37DNtrwcQ==')
            $Target.Text | Should -BeExactly @('Baumhaus!1234', 'SuppenTüte471', 'DingDong00815')
        }
        It "Arbeitet die Pipeline-Verarbeitung im Passwort-Modus korrekt?" {
            $Target = 'Baumhaus!1234', 'SuppenTüte471', 'DingDong00815' | ConvertTo-SecureString -AsPlainText | Get-StringHash -Salt 'qweasdyxc'
            $Target | Should -BeExactly @('xO4BMk/SUNykHo64ctfbCA==', '5wChNzRaCuDyuvPwDIlahA==', 'FrLgcFKeMzxM8zJ4617uww==')
        }
    }
}
=======
﻿BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-StringHash Tests" {
    Context "Stimmt das Cmdlet Manifest?" {
        It "Ist der String-Parameter 'Algorithm' korrekt definiert?" {
            $ParameterInfo = (Get-Command -Name 'Get-StringHash').Parameters['Algorithm']
            $ParameterInfo.Attributes.Where{ $_ -is [ValidateSet] } | Should -HaveCount 1
        
            $ValidateSet = $ParameterInfo.Attributes.Where{ $_ -is [ValidateSet] }
            $ValidateSet.ValidValues -contains 'SHA512' | Should -BeTrue
            $ValidateSet.ValidValues -contains 'MD5' | Should -BeTrue

            Get-Command -Name 'Get-StringHash' | Should -ParameterName 'Algorithm' -Type [String] -DefaultValue 'SHA512' -InParameterSet 'Text'
        }
        It "Ist der String-Parameter 'Text' Pflicht?" {
            Get-Command -Name 'Get-StringHash' | Should -ParameterName 'Text' -Type [String] -InParameterSet 'Text'
        }
        It "Ist der String-Parameter 'Password' Pflicht?" {
            Get-Command -Name 'Get-StringHash' | Should -ParameterName 'Password' -Type [SecureString] -InParameterSet 'Password'
        }
        It "Ist der String-Parameter 'Salt' Pflicht?" {
            Get-Command -Name 'Get-StringHash' | Should -ParameterName 'Salt' -Type [String] -InParameterSet 'Password'
        }
    }

    Context "Hash-Ausgabe Tests" {
        BeforeAll {
            function StringToMD5HashString([string]$Text) {
                $TextBytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
                $HashBytes = [System.Security.Cryptography.MD5]::HashData($TextBytes)
                return [System.Convert]::ToBase64String($HashBytes)
            }
            function StringToSHA512HashString([string]$Text) {
                $TextBytes = [System.Text.Encoding]::UTF8.GetBytes($Text)
                $HashBytes = [System.Security.Cryptography.SHA512]::HashData($TextBytes)
                return [System.Convert]::ToBase64String($HashBytes)
            }
        }
        It "Wird Text korrekt in ein SHA512-Hash-Objekt umgewandelt?" {
            $TextToHash = "Das ist ein Testtext!"
            $ExpectedHash = StringToSHA512HashString($TextToHash)

            $Target = Get-StringHash -Text $TextToHash
            $Target.GetType().FullName | Should -BeExactly 'StringHashInfo'
            $Target.Algorithm | Should -BeExactly 'SHA512'
            $Target.Hash | Should -BeExactly $ExpectedHash
            $Target.Text | Should -BeExactly $TextToHash
        }
        It "Wird Text korrekt in ein MD5-Hash-Objekt umgewandelt?" {
            $TextToHash = "Das ist ein Testtext!"
            $ExpectedHash = StringToMD5HashString($TextToHash)

            $Target = Get-StringHash -Text $TextToHash -Algorithm MD5
            $Target.GetType().FullName | Should -BeExactly 'StringHashInfo'
            $Target.Algorithm | Should -BeExactly 'MD5'
            $Target.Hash | Should -BeExactly $ExpectedHash
            $Target.Text | Should -BeExactly $TextToHash
        }
        It "Wird der Passwort-Hash korrekt berechnet?" {
            $TextToHash = 'P@$$w0rd1' | ConvertTo-SecureString -AsPlainText
            $Salt = 'vb23er45zu'
        
            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($TextToHash)
            $ExpectedHash = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
            for ($i = 0; $i -lt 20000; $i++) {
                $ExpectedHash = StringToMD5HashString($ExpectedHash + $Salt)
            }

            $Target = Get-StringHash -Password $TextToHash -Salt $Salt
            $Target | Should -BeOfType [String]
            $Target | Should -BeExactly $ExpectedHash
        }
        It "Erwarteter MD5 <ExpectedHash> vom Text <TestText>" -TestCases @(
            @{ TestText = "Baumhaus!1234"; ExpectedHash = 'IkGlrOYsv1tFtBqMoEA5dQ==' }
            @{ TestText = "SuppenTüte471"; ExpectedHash = '2pVbM7L4/bLmD+aWNhAt1g==' }
            @{ TestText = "DingDong00815"; ExpectedHash = 'SKX11Dqvj3S7a37DNtrwcQ==' }
        ) {
            $Target = Get-StringHash -Text $TestText -Algorithm MD5
            $Target.Hash | Should -BeExactly $ExpectedHash
        }
        It "Arbeitet die Pipeline-Verarbeitung im Text-Modus korrekt?" {
            $Target = 'Baumhaus!1234', 'SuppenTüte471', 'DingDong00815' | Get-StringHash -Algorithm MD5
            $Target.Algorithm | Should -BeExactly @('MD5', 'MD5', 'MD5')
            $Target.Hash | Should -BeExactly @('IkGlrOYsv1tFtBqMoEA5dQ==', '2pVbM7L4/bLmD+aWNhAt1g==', 'SKX11Dqvj3S7a37DNtrwcQ==')
            $Target.Text | Should -BeExactly @('Baumhaus!1234', 'SuppenTüte471', 'DingDong00815')
        }
        It "Arbeitet die Pipeline-Verarbeitung im Passwort-Modus korrekt?" {
            $Target = 'Baumhaus!1234', 'SuppenTüte471', 'DingDong00815' | ConvertTo-SecureString -AsPlainText | Get-StringHash -Salt 'qweasdyxc'
            $Target | Should -BeExactly @('xO4BMk/SUNykHo64ctfbCA==', '5wChNzRaCuDyuvPwDIlahA==', 'FrLgcFKeMzxM8zJ4617uww==')
        }
    }
}
>>>>>>> 47bdafb926307894e343ff9720d2bc56b970228c
