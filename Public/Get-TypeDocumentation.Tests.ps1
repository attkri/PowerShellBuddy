BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-TypeDocumentation" -Tag 'UnitTests' {

    Context "Input Validation" {

        It "Should throw an error if no input is provided" {
            { Get-TypeDocumentation } | Should -Throw
        }

        It "Should not throw an error if valid input is provided" {
            { Get-ChildItem -Path 'C:\' | Get-TypeDocumentation } | Should -Not -Throw
        }
    }

    Context "Output Validation" {

        It "Should return a string for each unique type name" {
            $types = Get-ChildItem -Path 'C:\' | Get-TypeDocumentation
            $types | ForEach-Object {
                $_ | Should -BeOfType [System.String]
            }
        }

        It "Should open the Microsoft documentation URL for each type" {
            $types = Get-Process | Get-TypeDocumentation
            $types | ForEach-Object {
                $url = 'https://docs.microsoft.com/de-de/dotnet/api/{0}' -f $_
                Start-Process $url | Should -Not -Throw
            }
        }
    }
}
