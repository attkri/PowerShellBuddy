<<<<<<< HEAD
﻿function DoIt($p1, $p2) { return $p1 + $p2 }

<#
.DESCRIPTION
    1.0
        Prohibits references to uninitialized variables, except for uninitialized variables in strings.
    2.0
        Prohibits references to uninitialized variables. This includes uninitialized variables in strings.
        Prohibits references to non-existent properties of an object.
        Prohibits function calls that use the syntax for calling methods.
    3.0
        Prohibits references to uninitialized variables. This includes uninitialized variables in strings.
        Prohibits references to non-existent properties of an object.
        Prohibits function calls that use the syntax for calling methods.
        Prohibit out of bounds or unresolvable array indexes.
#>
function Get-StrictMode {

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock','')]
    [CmdletBinding()]
    param ()

    try {
        [version]$StrictModeVersion = '3.0'
        $V3 = 1..3
        $null -eq $v3[3] | Out-Null

        $StrictModeVersion = '2.0'
        "Inhalt: $V2" | Out-Null
        $null -eq "I am".EMail | Out-Null
        DoIt(10, 20) | Out-Null

        $StrictModeVersion = '1.0'
        $V1 -gt 5 | Out-Null

        $StrictModeVersion = "0.0"
    }
    catch {  }
    finally {
        $StrictModeVersion
        Remove-Item -Path 'function:\DoIt', 'variable:\V1', 'variable:\V2', 'variable:\V3', 'variable:\StrictModeVersion' -Force -ErrorAction Ignore
    }
}
=======
﻿function DoIt($p1, $p2) { return $p1 + $p2 }

<#
.DESCRIPTION
    1.0
        Prohibits references to uninitialized variables, except for uninitialized variables in strings.
    2.0
        Prohibits references to uninitialized variables. This includes uninitialized variables in strings.
        Prohibits references to non-existent properties of an object.
        Prohibits function calls that use the syntax for calling methods.
    3.0
        Prohibits references to uninitialized variables. This includes uninitialized variables in strings.
        Prohibits references to non-existent properties of an object.
        Prohibits function calls that use the syntax for calling methods.
        Prohibit out of bounds or unresolvable array indexes.
#>
function Get-StrictMode {

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingEmptyCatchBlock','')]
    [CmdletBinding()]
    param ()

    try {
        [version]$StrictModeVersion = '3.0'
        $V3 = 1..3
        $null -eq $v3[3] | Out-Null

        $StrictModeVersion = '2.0'
        "Inhalt: $V2" | Out-Null
        $null -eq "I am".EMail | Out-Null
        DoIt(10, 20) | Out-Null

        $StrictModeVersion = '1.0'
        $V1 -gt 5 | Out-Null

        $StrictModeVersion = "0.0"
    }
    catch {  }
    finally {
        $StrictModeVersion
        Remove-Item -Path 'function:\DoIt', 'variable:\V1', 'variable:\V2', 'variable:\V3', 'variable:\StrictModeVersion' -Force -ErrorAction Ignore
    }
}
>>>>>>> 47bdafb926307894e343ff9720d2bc56b970228c
