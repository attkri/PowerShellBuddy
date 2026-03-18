class StringHashInfo {
    [string]$Algorithm
    [string]$Hash
    [string]$Text
}

<#
.SYNOPSIS
Calculate the hash value of a string.

.DESCRIPTION
Calculate the hash value of a string or derive a password hash with PBKDF2.

.PARAMETER Algorithm
The hash algorithm to use. `SHA512` is used by default.

.PARAMETER Text
The text of which is to be calculated.

.PARAMETER Password
The password of which is to be calculated.

.PARAMETER Salt
The salt value used for password hashing. The password path uses PBKDF2-SHA512 with 100,000 iterations.

.NOTES
The password path uses PBKDF2-SHA512 with 100,000 iterations and a 32-byte derived key. This is substantially stronger than a repeated fast hash such as MD5.

.INPUTS
A string for text hashing or a secure string for password hashing can be passed through the pipeline.

.OUTPUTS
Returns a `StringHashInfo` object for text hashing and a PBKDF2-SHA512 hash string for password hashing.

.EXAMPLE
Get-StringHash -Text 'This is a test text!'
Determines the SHA512 hash value of the supplied text.

.EXAMPLE
Get-StringHash -Password ('P@$$w0rd!' | ConvertTo-SecureString -AsPlainText) -Salt 'vb23er45zu'
Determines the password hash while applying the provided salt value.

.EXAMPLE
'ForestHouse!1234', 'SoupBag471', 'DoorBell00815' | Get-StringHash -Algorithm MD5
Returns three `StringHashInfo` objects.

.EXAMPLE
'ForestHouse!1234', 'SoupBag471', 'DoorBell00815' | ConvertTo-SecureString -AsPlainText | Get-StringHash -Salt 'qweasdyxc'
Returns three password hashes.
#>
function Get-StringHash {
    [CmdletBinding(DefaultParameterSetName = 'Text')]
    param (
        [Parameter(ParameterSetName = 'Text')]
        [ValidateSet('MD5', 'SHA512')]
        [String]$Algorithm = 'SHA512',

        [Parameter(ParameterSetName = 'Text', Mandatory, ValueFromPipeline)]
        [String]$Text,

        [Parameter(ParameterSetName = 'Password', Mandatory, ValueFromPipeline)]
        [SecureString]$Password,
        
        [Parameter(ParameterSetName = 'Password', Mandatory)]
        [String]$Salt
    )
begin { 
        $My = [HashTable]::Synchronized(@{})
    }

    process {
        
        if ($PSCmdlet.ParameterSetName -eq 'Password') {
            $My.Iterations = 100000
            $My.KeyLength = 32
            $My.BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)

            try {
                $My.PasswordText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($My.BSTR)
            }
            finally {
                if ($My.BSTR -ne [IntPtr]::Zero) {
                    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($My.BSTR)
                    $My.BSTR = [IntPtr]::Zero
                }
            }

            $My.SaltBytes = [System.Text.Encoding]::UTF8.GetBytes($Salt)
            $My.Pbkdf2 = [System.Security.Cryptography.Rfc2898DeriveBytes]::new(
                $My.PasswordText,
                $My.SaltBytes,
                $My.Iterations,
                [System.Security.Cryptography.HashAlgorithmName]::SHA512
            )

            try {
                $My.Result = [System.Convert]::ToBase64String($My.Pbkdf2.GetBytes($My.KeyLength))
            }
            finally {
                $My.Pbkdf2.Dispose()
            }

            $My.PasswordText = $null
            return $My.Result
        }

        $My.Duration = 1
        $My.Hash = $Text

        for ($i = 0; $i -lt $My.Duration; $i++) {
            $My.TextBytes = [System.Text.Encoding]::UTF8.GetBytes($My.Hash + $Salt)
            $My.HashBytes = switch ($Algorithm.ToUpperInvariant()) {
                'MD5' {
                    [System.Security.Cryptography.MD5]::HashData($My.TextBytes)
                    break
                }
                'SHA512' {
                    [System.Security.Cryptography.SHA512]::HashData($My.TextBytes)
                    break
                }
                default {
                    throw "Unsupported hash algorithm: $Algorithm"
                }
            }
            $My.Hash = [System.Convert]::ToBase64String($My.HashBytes)
        }

        $My.Result = New-Object -TypeName StringHashInfo
        $My.Result.Algorithm = $Algorithm.ToUpper()
        $My.Result.Hash = $My.Hash
        $My.Result.Text = $Text
        
        return $My.Result
    }
    end { 
        $My.Clear()
        $My = $null
        Remove-Variable -Name My -Force
    }
}
