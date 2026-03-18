BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe 'Get-StringHash tests' {
    Context 'Cmdlet metadata' {
        It "defines the 'Algorithm' string parameter correctly." {
            $ParameterInfo = (Get-Command -Name 'Get-StringHash').Parameters['Algorithm']
            $ParameterInfo.Attributes.Where{ $_ -is [ValidateSet] } | Should -HaveCount 1
        
            $ValidateSet = $ParameterInfo.Attributes.Where{ $_ -is [ValidateSet] }
            $ValidateSet.ValidValues -contains 'SHA512' | Should -BeTrue
            $ValidateSet.ValidValues -contains 'MD5' | Should -BeTrue

            Get-Command -Name 'Get-StringHash' | Should -ParameterName 'Algorithm' -Type [String] -DefaultValue 'SHA512' -InParameterSet 'Text'
        }
        It "requires the 'Text' string parameter in the text parameter set." {
            Get-Command -Name 'Get-StringHash' | Should -ParameterName 'Text' -Type [String] -InParameterSet 'Text'
        }
        It "requires the 'Password' secure string parameter in the password parameter set." {
            Get-Command -Name 'Get-StringHash' | Should -ParameterName 'Password' -Type [SecureString] -InParameterSet 'Password'
        }
        It "requires the 'Salt' string parameter in the password parameter set." {
            Get-Command -Name 'Get-StringHash' | Should -ParameterName 'Salt' -Type [String] -InParameterSet 'Password'
        }
    }

    Context 'Hash output' {
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
            function StringToPbkdf2HashString([string]$Text, [string]$Salt) {
                $SaltBytes = [System.Text.Encoding]::UTF8.GetBytes($Salt)
                $Pbkdf2 = [System.Security.Cryptography.Rfc2898DeriveBytes]::new(
                    $Text,
                    $SaltBytes,
                    100000,
                    [System.Security.Cryptography.HashAlgorithmName]::SHA512
                )

                try {
                    return [System.Convert]::ToBase64String($Pbkdf2.GetBytes(32))
                }
                finally {
                    $Pbkdf2.Dispose()
                }
            }
        }
        It 'returns the correct SHA512 hash object for text input.' {
            $TextToHash = 'This is a test text!'
            $ExpectedHash = StringToSHA512HashString($TextToHash)

            $Target = Get-StringHash -Text $TextToHash
            $Target.GetType().FullName | Should -BeExactly 'StringHashInfo'
            $Target.Algorithm | Should -BeExactly 'SHA512'
            $Target.Hash | Should -BeExactly $ExpectedHash
            $Target.Text | Should -BeExactly $TextToHash
        }
        It 'returns the correct MD5 hash object for text input.' {
            $TextToHash = 'This is a test text!'
            $ExpectedHash = StringToMD5HashString($TextToHash)

            $Target = Get-StringHash -Text $TextToHash -Algorithm MD5
            $Target.GetType().FullName | Should -BeExactly 'StringHashInfo'
            $Target.Algorithm | Should -BeExactly 'MD5'
            $Target.Hash | Should -BeExactly $ExpectedHash
            $Target.Text | Should -BeExactly $TextToHash
        }
        It 'calculates the password hash correctly.' {
            $PasswordText = 'P@$$w0rd1'
            $TextToHash = $PasswordText | ConvertTo-SecureString -AsPlainText
            $Salt = 'vb23er45zu'

            $ExpectedHash = StringToPbkdf2HashString -Text $PasswordText -Salt $Salt

            $Target = Get-StringHash -Password $TextToHash -Salt $Salt
            $Target | Should -BeOfType [String]
            $Target | Should -BeExactly $ExpectedHash
        }
        It 'returns the expected MD5 value <ExpectedHash> for text <TestText>.' -TestCases @(
            @{ TestText = "Baumhaus!1234"; ExpectedHash = 'IkGlrOYsv1tFtBqMoEA5dQ==' }
            @{ TestText = "SuppenTüte471"; ExpectedHash = '2pVbM7L4/bLmD+aWNhAt1g==' }
            @{ TestText = "DingDong00815"; ExpectedHash = 'SKX11Dqvj3S7a37DNtrwcQ==' }
        ) {
            $Target = Get-StringHash -Text $TestText -Algorithm MD5
            $Target.Hash | Should -BeExactly $ExpectedHash
        }
        It 'handles pipeline input correctly in text mode.' {
            $Target = 'Baumhaus!1234', 'SuppenTüte471', 'DingDong00815' | Get-StringHash -Algorithm MD5
            $Target.Algorithm | Should -BeExactly @('MD5', 'MD5', 'MD5')
            $Target.Hash | Should -BeExactly @('IkGlrOYsv1tFtBqMoEA5dQ==', '2pVbM7L4/bLmD+aWNhAt1g==', 'SKX11Dqvj3S7a37DNtrwcQ==')
            $Target.Text | Should -BeExactly @('Baumhaus!1234', 'SuppenTüte471', 'DingDong00815')
        }
        It 'handles pipeline input correctly in password mode.' {
            $Passwords = 'Baumhaus!1234', 'SuppenTüte471', 'DingDong00815'
            $Expected = $Passwords | ForEach-Object { StringToPbkdf2HashString -Text $_ -Salt 'qweasdyxc' }
            $Target = $Passwords | ConvertTo-SecureString -AsPlainText | Get-StringHash -Salt 'qweasdyxc'
            $Target | Should -BeExactly $Expected
        }
    }
}
