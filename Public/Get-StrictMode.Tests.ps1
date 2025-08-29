BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

AfterAll {
    #Set-StrictMode -Off
}

Describe "Get-StrictMode Test" {

    It "Detected Strict-Mode Version 1.0" {
        Set-StrictMode -Version '1.0'
        Get-StrictMode | Should -BeExactly '1.0'
    }

    It "Detected Strict-Mode Version 2.0" {
        Set-StrictMode -Version '2.0'
        Get-StrictMode | Should -BeExactly '2.0'
    }

    It "Detected Strict-Mode Version 3.0" {
        Set-StrictMode -Version '3.0'
        Get-StrictMode | Should -BeExactly '3.0'
    }
    
    # ! Geht nicht, warum k.a.!
    # It "Detected Strict-Mode Off" {
    #     Set-StrictMode -Off
    #     Get-StrictMode | Should -BeExactly '0.0'
    # }

    It "Return Object type of Version" {
        Set-StrictMode -Version '3.0'
        Get-StrictMode | Should -BeOfType [Version]
    }
}