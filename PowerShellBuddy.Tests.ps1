<<<<<<< HEAD
﻿Describe "Module PowerShellBuddy Tests" {
    Context 'Basis Modul Testing' {

        $testCases = Get-ChildItem "$PSScriptRoot\Public\*.ps1" -File -Force | ForEach-Object -Process { return @{ Path=$_.FullName } }

        It "Skript '<Path>' enthält keine Fehler." -TestCases $testCases  {
            $contents = Get-Content -Path $Path -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.Count | Should -Be 0
        }

        It "Das Modul PowerShellBuddy kann ohne Probleme importiert werden." {
            Remove-Module -Name 'PowerShellBuddy' -Force -ErrorAction Ignore -WarningAction Ignore
            { Import-Module -Name "$PSScriptRoot\PowerShellBuddy.psd1" -Force } | Should -Not -Throw
        }

        It "Das Module PowerShellBuddy kann ohne Probleme  entladen werden." {
            Import-Module -Name "$PSScriptRoot\PowerShellBuddy.psd1" -Force
            { Remove-Module -Name 'PowerShellBuddy' -Force } | Should -Not -Throw
        }
    }
    Context 'Modul-Manifest Tests' {

        It 'Modul-Version ist Neu' {
            Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1" | Select-Object -ExpandProperty Version | Should -GE '1.0'
        }
        It 'Module Manifest ist erfolgreich validiert.' {
            { Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1" -ErrorAction Stop -WarningAction SilentlyContinue } | Should -Not -Throw
        }
        It 'Modul-Name ist PowerShellBuddy.' {
            Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1" | Select-Object -ExpandProperty Name | Should -Be 'PowerShellBuddy'
        }
        It 'Modul-Description ist vorhanden.' {
            Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1" | Select-Object -ExpandProperty Description | Should -Not -BeNullOrEmpty
        }
        It 'Module-Root steht auf PowerShellBuddy.psm1.' {
            Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1" | Select-Object -ExpandProperty RootModule | Should -Be 'PowerShellBuddy.psm1'
        }
        It 'Modul GUID ist cb790b27-dcec-458f-888d-47d9e7c6599d.' {
            Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1" | Select-Object -ExpandProperty Guid | Should -Be 'cb790b27-dcec-458f-888d-47d9e7c6599d'
        }
        It 'Das Modul enthält 2 .Format.ps1xml-Dateien' {
            Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1" | Select-Object -ExpandProperty ExportedFormatFiles | Measure-Object | Select-Object -ExpandProperty Count | Should -BeExactly 3
        }
        It 'Das Modul enthält alle benötigten .Format.ps1xml-Dateien' {
            Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1" | Select-Object -ExpandProperty ExportedFormatFiles | Split-Path -Leaf | Should -BeIn 'Get-ModuleUpdate.format.ps1xml', 'Get-ParameterInfo.format.ps1xml', 'Test-SecurityState.Format.ps1xml'
        }
    }
    Context 'Exported Functions' {
        BeforeAll {
            Import-Module -Name $PSScriptRoot
            $Script:Manifest = Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1"
        }
        AfterAll {
            Remove-Module -Name 'PowerShellBuddy' -Force -ErrorAction Ignore
        }
        It "Function Public\<FunctionName>.ps1 als ExportedFunction <FunctionName> im Manifest hinterlegt." -TestCases (
            Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -Exclude '*.Tests.ps1' | Select-Object -ExpandProperty Name | Foreach-Object -Process {
            @{ FunctionName = $_.Replace('.ps1', ''
            ) }
        }) {
            $ManifestFunctions = Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1" | Select-Object -ExpandProperty ExportedFunctions | Select-Object -ExpandProperty Keys
            $FunctionName -in $ManifestFunctions | Should -Be $true
        }
        It "Ist die <FunctionName> im function:\-Laufwerk enthalten?" -TestCases (Get-Command -Module 'PowerShellBuddy' -CommandType Function | ForEach-Object -Process {
            @{ FunctionName = $_.Name }
        }) {
            param(
                $FunctionName
            )

            Get-Item -Path "function:\$FunctionName" | Select-Object -ExpandProperty Name | Should -BeExactly $FunctionName
        }
        It "Ist die Manifest-Funktion <FunctionName> als Public\<FunctionName>.ps1 enthalten?" -TestCases (
            Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1" | Select-Object -ExpandProperty ExportedFunctions | Select-Object -ExpandProperty Keys | ForEach-Object -Process { @{ FunctionName = $_ } }
            ) {
            param(
                $FunctionName
            )
            Test-Path -Path "$PSScriptRoot\Public\$FunctionName.ps1" | Should -BeTrue
        }
    }
}
=======
﻿Describe "Module PowerShellBuddy Tests" {
    Context 'Basis Modul Testing' {

        $testCases = Get-ChildItem "$PSScriptRoot\Public\*.ps1" -File -Force | ForEach-Object -Process { return @{ Path=$_.FullName } }

        It "Skript '<Path>' enthält keine Fehler." -TestCases $testCases  {
            $contents = Get-Content -Path $Path -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.Count | Should -Be 0
        }

        It "Das Modul PowerShellBuddy kann ohne Probleme importiert werden." {
            Remove-Module -Name 'PowerShellBuddy' -Force -ErrorAction Ignore -WarningAction Ignore
            { Import-Module -Name "$PSScriptRoot\PowerShellBuddy.psd1" -Force } | Should -Not -Throw
        }

        It "Das Module PowerShellBuddy kann ohne Probleme  entladen werden." {
            Import-Module -Name "$PSScriptRoot\PowerShellBuddy.psd1" -Force
            { Remove-Module -Name 'PowerShellBuddy' -Force } | Should -Not -Throw
        }
    }
    Context 'Modul-Manifest Tests' {

        It 'Modul-Version ist Neu' {
            Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1" | Select-Object -ExpandProperty Version | Should -GE '1.0'
        }
        It 'Module Manifest ist erfolgreich validiert.' {
            { Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1" -ErrorAction Stop -WarningAction SilentlyContinue } | Should -Not -Throw
        }
        It 'Modul-Name ist PowerShellBuddy.' {
            Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1" | Select-Object -ExpandProperty Name | Should -Be 'PowerShellBuddy'
        }
        It 'Modul-Description ist vorhanden.' {
            Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1" | Select-Object -ExpandProperty Description | Should -Not -BeNullOrEmpty
        }
        It 'Module-Root steht auf PowerShellBuddy.psm1.' {
            Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1" | Select-Object -ExpandProperty RootModule | Should -Be 'PowerShellBuddy.psm1'
        }
        It 'Modul GUID ist cb790b27-dcec-458f-888d-47d9e7c6599d.' {
            Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1" | Select-Object -ExpandProperty Guid | Should -Be 'cb790b27-dcec-458f-888d-47d9e7c6599d'
        }
        It 'Das Modul enthält 2 .Format.ps1xml-Dateien' {
            Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1" | Select-Object -ExpandProperty ExportedFormatFiles | Measure-Object | Select-Object -ExpandProperty Count | Should -BeExactly 3
        }
        It 'Das Modul enthält alle benötigten .Format.ps1xml-Dateien' {
            Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1" | Select-Object -ExpandProperty ExportedFormatFiles | Split-Path -Leaf | Should -BeIn 'Get-ModuleUpdate.format.ps1xml', 'Get-ParameterInfo.format.ps1xml', 'Test-SecurityState.Format.ps1xml'
        }
    }
    Context 'Exported Functions' {
        BeforeAll {
            Import-Module -Name $PSScriptRoot
            $Script:Manifest = Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1"
        }
        AfterAll {
            Remove-Module -Name 'PowerShellBuddy' -Force -ErrorAction Ignore
        }
        It "Function Public\<FunctionName>.ps1 als ExportedFunction <FunctionName> im Manifest hinterlegt." -TestCases (
            Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -Exclude '*.Tests.ps1' | Select-Object -ExpandProperty Name | Foreach-Object -Process {
            @{ FunctionName = $_.Replace('.ps1', ''
            ) }
        }) {
            $ManifestFunctions = Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1" | Select-Object -ExpandProperty ExportedFunctions | Select-Object -ExpandProperty Keys
            $FunctionName -in $ManifestFunctions | Should -Be $true
        }
        It "Ist die <FunctionName> im function:\-Laufwerk enthalten?" -TestCases (Get-Command -Module 'PowerShellBuddy' -CommandType Function | ForEach-Object -Process {
            @{ FunctionName = $_.Name }
        }) {
            param(
                $FunctionName
            )

            Get-Item -Path "function:\$FunctionName" | Select-Object -ExpandProperty Name | Should -BeExactly $FunctionName
        }
        It "Ist die Manifest-Funktion <FunctionName> als Public\<FunctionName>.ps1 enthalten?" -TestCases (
            Test-ModuleManifest -Path "$PSScriptRoot\PowerShellBuddy.psd1" | Select-Object -ExpandProperty ExportedFunctions | Select-Object -ExpandProperty Keys | ForEach-Object -Process { @{ FunctionName = $_ } }
            ) {
            param(
                $FunctionName
            )
            Test-Path -Path "$PSScriptRoot\Public\$FunctionName.ps1" | Should -BeTrue
        }
    }
}
>>>>>>> 47bdafb926307894e343ff9720d2bc56b970228c
