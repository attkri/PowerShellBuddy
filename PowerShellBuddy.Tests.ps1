Describe "Module PowerShellBuddy Tests" {
    
    Context 'Basis Modul Testing' {

        $testCases = Get-ChildItem ".\Public\*.ps1" -File -Force | ForEach-Object -Process { return @{ Path = $_.FullName; Name = $_.Name } }

        It "Skript '<Name>' enthält keine Fehler." -TestCases $testCases {
            $contents = Get-Content -Path $Path -Raw -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            ($errors ? $errors.Count : 0) | Should -Be 0
        }

        It "Das Modul PowerShellBuddy kann ohne Probleme importiert werden." {
            Remove-Module -Name 'PowerShellBuddy' -Force -ErrorAction Ignore -WarningAction Ignore
            { Import-Module -Name ".\PowerShellBuddy.psd1" -Force } | Should -Not -Throw
        }

        It "Das Modul PowerShellBuddy kann ohne Probleme  entladen werden." {
            Import-Module -Name ".\PowerShellBuddy.psd1" -Force
            { Remove-Module -Name 'PowerShellBuddy' -Force } | Should -Not -Throw
        }
    
        It 'PSData.Tags ist gepflegt.' {
            $psd = (Import-PowerShellDataFile ".\PowerShellBuddy.psd1").PrivateData.PSData
            $psd.Tags | Should -Not -BeNullOrEmpty
            $psd.ProjectUri | Should -Match 'github\.com'
            $psd.LicenseUri | Should -Match 'github\.com'
        }

        It 'Copyright gesetzt.' {
            (Test-ModuleManifest -Path ".\PowerShellBuddy.psd1").Copyright |
            Should -Match '©'
        }
    
    
    }

    Context 'Modul-Manifest Tests' {

        It 'Module Manifest ist erfolgreich validiert.' {
            { Test-ModuleManifest -Path ".\PowerShellBuddy.psd1" -ErrorAction Stop -WarningAction SilentlyContinue } | Should -Not -Throw
        }
        It 'Modul-Name ist PowerShellBuddy.' {
            Test-ModuleManifest -Path ".\PowerShellBuddy.psd1" | Select-Object -ExpandProperty Name | Should -Be 'PowerShellBuddy'
        }
        It 'Modul-Description ist vorhanden.' {
            Test-ModuleManifest -Path ".\PowerShellBuddy.psd1" | Select-Object -ExpandProperty Description | Should -Not -BeNullOrEmpty
        }
        It 'Module-Root steht auf PowerShellBuddy.psm1.' {
            Test-ModuleManifest -Path ".\PowerShellBuddy.psd1" | Select-Object -ExpandProperty RootModule | Should -Be 'PowerShellBuddy.psm1'
        }
        It 'Modul GUID ist cb790b27-dcec-458f-888d-47d9e7c6599d.' {
            Test-ModuleManifest -Path ".\PowerShellBuddy.psd1" | Select-Object -ExpandProperty Guid | Should -Be 'cb790b27-dcec-458f-888d-47d9e7c6599d'
        }
        It 'Das Modul enthält 3 .Format.ps1xml-Dateien' {
            Test-ModuleManifest -Path ".\PowerShellBuddy.psd1" | Select-Object -ExpandProperty ExportedFormatFiles | Measure-Object | Select-Object -ExpandProperty Count | Should -BeExactly 3
        }

        It 'Alle benötigten .Format.ps1xml-Dateien sind vorhanden.' {
            $expected = 'Get-ModuleUpdate.format.ps1xml', 'Get-ParameterInfo.format.ps1xml', 'Test-SecurityState.format.ps1xml'
            $actual = (Test-ModuleManifest -Path ".\PowerShellBuddy.psd1").FormatsToProcess | Split-Path -Leaf
            foreach ($f in $expected) { $actual | Should -Contain $f }
        }
    }

    Context 'Exported Functions' {
        
        BeforeAll {
            Import-Module -Name '.\PowerShellBuddy.psd1'
            $Script:ManifestFunctions = Test-ModuleManifest -Path ".\PowerShellBuddy.psd1" | Select-Object -ExpandProperty ExportedFunctions | Select-Object -ExpandProperty Keys
        }

        AfterAll {
            Remove-Module -Name 'PowerShellBuddy' -Force -ErrorAction Ignore
        }

        It "Function <FunctionName> im Manifest hinterlegt." -TestCases (Get-ChildItem -Path ".\Public\*.ps1" -Exclude '*.Tests.ps1' | ForEach-Object -Process { @{ FunctionName = $_.BaseName } }) {
            param( $FunctionName )
            $FunctionName -in $Script:ManifestFunctions | Should -Be $true
        }

        It "<FunctionName> im function:\ enthalten?" -TestCases (Get-ChildItem -Path ".\Public\*.ps1" -Exclude '*.Tests.ps1' | ForEach-Object -Process { @{ FunctionName = $_.BaseName } }) {
            param($FunctionName)

            Test-Path -Path "function:\$FunctionName" | Should -BeTrue
        }

        It "Manifest-Funktion <FunctionName> als Public\<FunctionName>.ps1 enthalten?" -TestCases ( Test-ModuleManifest -Path ".\PowerShellBuddy.psd1" | Select-Object -ExpandProperty ExportedFunctions | Select-Object -ExpandProperty Keys | ForEach-Object -Process { @{ FunctionName = $_ } }) {
            param( $FunctionName )
            Test-Path -Path ".\Public\$FunctionName.ps1" | Should -BeTrue
        }
    }

}
