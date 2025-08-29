class StringHashInfo {
    [string]$Algorithm
    [string]$Hash
    [string]$Text
}

<#
.SYNOPSIS
Calculate the hash value of a string.

.DESCRIPTION
Calculate the hash value of a string or a password with a salt value.

.PARAMETER Algorithm
The hash algorithm to be used.SHA512 is used by default.

.PARAMETER Text
The text of which is to be calculated.

.PARAMETER Password
The password of which is to be calculated.

.PARAMETER Salt
The salt value that is to be used for the calculation (20,000 times) of the password-hashes.

.NOTES
The hash value of a password is determined in which the salt value is calculated again 20,000 times in a loop.This procedure protects a) from a rainbow attack and b) due to the long calculation time from the brutal-force attack.

.INPUTS
A string for text-hash or securest ring for password-hash calculation can be handed over via the pipeline.

.OUTPUTS
For text-hash calculation we returned a stringhashinfo object to the pipeline.A string object for the password calculation.

.EXAMPLE
Get-StringHash -Text 'Das ist ein Testtext!'
Determines the SHA512 Hash value of the text 'This is a test text!'.

.EXAMPLE
Get-StringHash -Password ('P@$$w0rd!' | ConvertTo-SecureString -AsPlainText) -Salt 'vb23er45zu'
Determine the password hash taking into account the salt value (see also notes).

.EXAMPLE
'Baumhaus!1234', 'SuppenTüte471', 'DingDong00815' | Get-StringHash -Algorithm MD5
Gives back three StringHashInfo object.

.EXAMPLE
'Baumhaus!1234', 'SuppenTüte471', 'DingDong00815' | ConvertTo-SecureString -AsPlainText | Get-StringHash -Salt 'qweasdyxc'
Gives back three password hashes.
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
        
        switch ($PSCmdlet.ParameterSetName) {
            'Password' { 
                $Algorithm = 'MD5'
                $My.Duration = 20000
                $My.BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
                $My.Hash = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($My.BSTR)
                break
            }
            'Text' { 
                $My.Duration = 1
                $My.Hash = $Text
                break
            }
        }

        for ($i = 0; $i -lt $My.Duration; $i++) {
            $My.TextBytes = [System.Text.Encoding]::UTF8.GetBytes($My.Hash + $Salt)
            $My.HashBytes = Invoke-Expression -Command ('[System.Security.Cryptography.{0}]::HashData($My.TextBytes)' -f $Algorithm)
            $My.Hash = [System.Convert]::ToBase64String($My.HashBytes)
        }

        switch ($PSCmdlet.ParameterSetName) {
            'Password' { 
                $My.Result = $My.Hash
                break
            }
            'Text' { 
                $My.Result = New-Object -TypeName StringHashInfo
                $My.Result.Algorithm = $Algorithm.ToUpper()
                $My.Result.Hash = $My.Hash
                $My.Result.Text = $Text
                break
            }
        }
        
        return $My.Result
    }
    end { 
        $My.Clear()
        $My = $null
        Remove-Variable -Name My -Force
    }
}