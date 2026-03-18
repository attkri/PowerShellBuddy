Describe 'PowerShellBuddy module tests' {
    
    Context 'Basic module validation' {

        $testCases = Get-ChildItem ".\Public\*.ps1" -File -Force | ForEach-Object -Process { return @{ Path = $_.FullName; Name = $_.Name } }

        It "Script '<Name>' has no parser errors." -TestCases $testCases {
            $contents = Get-Content -Path $Path -Raw -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            ($errors ? $errors.Count : 0) | Should -Be 0
        }

        It 'imports the PowerShellBuddy module successfully.' {
            Remove-Module -Name 'PowerShellBuddy' -Force -ErrorAction Ignore -WarningAction Ignore
            { Import-Module -Name ".\PowerShellBuddy.psd1" -Force } | Should -Not -Throw
        }

        It 'removes the PowerShellBuddy module successfully.' {
            Import-Module -Name ".\PowerShellBuddy.psd1" -Force
            { Remove-Module -Name 'PowerShellBuddy' -Force } | Should -Not -Throw
        }
    
        It 'maintains PSData tags.' {
            $psd = (Import-PowerShellDataFile ".\PowerShellBuddy.psd1").PrivateData.PSData
            $psd.Tags | Should -Not -BeNullOrEmpty
            $psd.ProjectUri | Should -Match 'github\.com'
            $psd.LicenseUri | Should -Match 'github\.com'
        }

        It 'sets a copyright notice.' {
            (Test-ModuleManifest -Path ".\PowerShellBuddy.psd1").Copyright |
            Should -Match '©'
        }
    
    
    }

    Context 'Module manifest tests' {

        It 'validates the module manifest successfully.' {
            { Test-ModuleManifest -Path ".\PowerShellBuddy.psd1" -ErrorAction Stop -WarningAction SilentlyContinue } | Should -Not -Throw
        }
        It 'uses PowerShellBuddy as the module name.' {
            Test-ModuleManifest -Path ".\PowerShellBuddy.psd1" | Select-Object -ExpandProperty Name | Should -Be 'PowerShellBuddy'
        }
        It 'contains a module description.' {
            Test-ModuleManifest -Path ".\PowerShellBuddy.psd1" | Select-Object -ExpandProperty Description | Should -Not -BeNullOrEmpty
        }
        It 'uses PowerShellBuddy.psm1 as the root module.' {
            Test-ModuleManifest -Path ".\PowerShellBuddy.psd1" | Select-Object -ExpandProperty RootModule | Should -Be 'PowerShellBuddy.psm1'
        }
        It 'uses the expected module GUID.' {
            Test-ModuleManifest -Path ".\PowerShellBuddy.psd1" | Select-Object -ExpandProperty Guid | Should -Be 'cb790b27-dcec-458f-888d-47d9e7c6599d'
        }
        It 'contains 3 .Format.ps1xml files.' {
            Test-ModuleManifest -Path ".\PowerShellBuddy.psd1" | Select-Object -ExpandProperty ExportedFormatFiles | Measure-Object | Select-Object -ExpandProperty Count | Should -BeExactly 3
        }

        It 'contains all required .Format.ps1xml files.' {
            $expected = 'Get-ModuleUpdate.format.ps1xml', 'Get-ParameterInfo.format.ps1xml', 'Test-SecurityState.format.ps1xml'
            $actual = (Import-PowerShellDataFile ".\PowerShellBuddy.psd1").FormatsToProcess | Split-Path -Leaf
            foreach ($f in $expected) { $actual | Should -Contain $f }
        }
    }

    Context 'Exported Functions' {
        
        BeforeAll {
            Import-Module -Name '.\PowerShellBuddy.psd1' -Force
            $Script:ManifestFunctions = Test-ModuleManifest -Path ".\PowerShellBuddy.psd1" | Select-Object -ExpandProperty ExportedFunctions | Select-Object -ExpandProperty Keys
        }

        AfterAll {
            Remove-Module -Name 'PowerShellBuddy' -Force -ErrorAction Ignore
        }

        It 'declares <FunctionName> in the manifest.' -TestCases (Get-ChildItem -Path ".\Public\*.ps1" -Exclude '*.Tests.ps1' | ForEach-Object -Process { @{ FunctionName = $_.BaseName } }) {
            param( $FunctionName )
            $FunctionName -in $Script:ManifestFunctions | Should -Be $true
        }

        It 'exports <FunctionName> after module import.' -TestCases (Get-ChildItem -Path ".\Public\*.ps1" -Exclude '*.Tests.ps1' | ForEach-Object -Process { @{ FunctionName = $_.BaseName } }) {
            param($FunctionName)

            $command = Get-Command -Name $FunctionName -ErrorAction SilentlyContinue
            $command | Should -Not -BeNullOrEmpty
            $command.Source | Should -Be 'PowerShellBuddy'
        }

        It 'contains Public\<FunctionName>.ps1 for each manifest function.' -TestCases ( Test-ModuleManifest -Path ".\PowerShellBuddy.psd1" | Select-Object -ExpandProperty ExportedFunctions | Select-Object -ExpandProperty Keys | ForEach-Object -Process { @{ FunctionName = $_ } }) {
            param( $FunctionName )
            Test-Path -Path ".\Public\$FunctionName.ps1" | Should -BeTrue
        }
    }

    Context 'Removed Commands' {

        BeforeAll {
            Import-Module -Name '.\PowerShellBuddy.psd1' -Force
            $Script:ModuleCommandNames = Get-Command -Module PowerShellBuddy | Select-Object -ExpandProperty Name
        }

        AfterAll {
            Remove-Module -Name 'PowerShellBuddy' -Force -ErrorAction Ignore
        }

        It 'Get-Tipp is no longer exported.' {
            $Script:ModuleCommandNames | Should -Not -Contain 'Get-Tipp'
        }

        It 'Get-EuroExchange is no longer present in the repository.' {
            Test-Path '.\Examples\Get-EuroExchange.ps1' | Should -BeFalse
        }
    }

}
