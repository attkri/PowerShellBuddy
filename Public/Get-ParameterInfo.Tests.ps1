BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-ParameterInfo Test" {
    Context "Parameter" {
        It "Parameter -CmdletName ist obligatorisch und vom Typ System.String" {
            Get-Command -Name Get-ParameterInfo | Should -HaveParameter CmdletName -Type String  -Mandatory
        }
        It "Parameter -CmdletName validiert mit ValidateNotNullOrEmpty" {
            $target = (Get-Command -Name Get-ParameterInfo).Parameters['CmdletName']
            $target = $target.Attributes.Where({$_ -is [System.Management.Automation.ValidateNotNullOrEmptyAttribute]})
            $target | should -Not -BeNullOrEmpty
        }
        It "Throw => Get-ParameterInfo -CmdletName $null" {
            { Get-ParameterInfo -CmdletName $null } | Should -Throw -ErrorId 'ParameterArgumentValidationError,Get-ParameterInfo'
        }
        It "Throw => Get-ParameterInfo -CmdletName ''" {
            { Get-ParameterInfo -CmdletName '' } | Should -Throw -ErrorId 'ParameterArgumentValidationError,Get-ParameterInfo'
        }
        It "Throw => Get-ParameterInfo -CmdletName 'Gib-EsNicht'" {
            { Get-ParameterInfo -CmdletName 'Gib-EsNicht' } | Should -Throw -ErrorId 'ParameterArgumentValidationError,Get-ParameterInfo'
        }
    }
    Context "Rueckgabeobjekte vom Aufruf > Get-ParameterInfo -CmdletName 'Test-Dummy' < testen"  {
        BeforeAll {
            function Test-Dummy {
                [CmdletBinding(DefaultParameterSetName = 'SetA')]
                param (
                    [Parameter(ParameterSetName = 'SetA', Position = 0, Mandatory = $true)]
                    [Alias('epa')]
                    [String]
                    $ExParaA,

                    [Parameter(ParameterSetName = 'SetB', ValueFromPipeline = $true)]
                    [Alias('epb', 'pb')]
                    [switch]
                    $ExParaB,

                    [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true)]
                    [System.Diagnostics.Process[]]
                    $ExParaC
                )

                dynamicParam {

                    $parameterAttribute = New-Object -TypeName 'System.Management.Automation.ParameterAttribute'
                    $parameterAttribute.Mandatory = $true
                    $attributes = New-Object -TypeName 'System.Collections.ObjectModel.Collection[System.Attribute]'
                    $attributes.Add($parameterAttribute)
                    $parameter = New-Object -TypeName 'System.Management.Automation.RuntimeDefinedParameter' -ArgumentList 'ExParaD', 'System.Int32', $attributes
                    $parameters = New-Object -TypeName 'System.Management.Automation.RuntimeDefinedParameterDictionary'
                    $parameters.Add('ExParaD', $parameter)

                    return $parameters
                }
            }
        }
        AfterAll {
            Remove-Item -Path Function:\Test-Dummy -Force -ErrorAction Ignore
        }
        It "Gibt [CmdletParameterInfo]-Objekte zurueck" {

            $target = Get-ParameterInfo -CmdletName 'Test-Dummy' | Select-Object -First 1
            $target.GetType().FullName | Should -BeExactly 'CmdletParameterInfo'
        }
        It "Die Rueckgabe-Menge stimmt" {
            Get-ParameterInfo -CmdletName 'Test-Dummy' | Should -HaveCount 5
        }
        It "Die Rueckgabe enthaelt in der richtigen Reihenfolge alle Parameter-Namen" {
            $target = (Get-ParameterInfo -CmdletName 'Test-Dummy' | Select-Object -ExpandProperty 'Name') -join ';'
            $target | Should -BeExactly 'ExParaC;ExParaD;ProgressAction;ExParaA;ExParaB'
        }
        It "Die Rueckgabe enthaelt in der richtigen Reihenfolge alle Parameter-Aliase" {
            $target = (Get-ParameterInfo -CmdletName 'Test-Dummy' | Select-Object -ExpandProperty 'Aliases') -join ';'
            $target | Should -BeExactly 'proga;epa;epb;pb'
        }
        It "Die Rueckgabe enthaelt in der richtigen Reihenfolge alle Parameter-TypeNamen" {
            $target = (Get-ParameterInfo -CmdletName 'Test-Dummy' | Select-Object -ExpandProperty 'TypeName') -join ';'
            $target | Should -BeExactly 'Process[];Int32;ActionPreference;String;SwitchParameter'
        }
        It "Die Rueckgabe enthaelt in der richtigen Reihenfolge alle Parameter-SetNamen" {
            $target = (Get-ParameterInfo -CmdletName 'Test-Dummy' | Select-Object -ExpandProperty 'SetName') -join ';'
            $target | Should -BeExactly 'AllParameterSets;AllParameterSets;AllParameterSets;SetA (Default);SetB'
        }
        It "Die Rueckgabe enthaelt in der richtigen Reihenfolge alle Parameter-Positionen" {
            $target = (Get-ParameterInfo -CmdletName 'Test-Dummy' | Select-Object -ExpandProperty 'Position') -join ';'
            $target | Should -BeExactly '1;Named;Named;0;Named'
        }
        It "Die Rueckgabe enthaelt in der richtigen Reihenfolge alle Parameter-IsMandatories" {
            $target = (Get-ParameterInfo -CmdletName 'Test-Dummy' | Select-Object -ExpandProperty 'IsMandatory') -join ';'
            $target | Should -BeExactly 'False;True;False;True;False'
        }
        It "Die Rueckgabe enthaelt in der richtigen Reihenfolge alle Parameter-IsByValues" {
            $target = (Get-ParameterInfo -CmdletName 'Test-Dummy' | Select-Object -ExpandProperty 'IsByValue') -join ';'
            $target | Should -BeExactly 'False;False;False;False;True'
        }
        It "Die Rueckgabe enthaelt in der richtigen Reihenfolge alle Parameter-IsByPropertyNamen" {
            $target = (Get-ParameterInfo -CmdletName 'Test-Dummy' | Select-Object -ExpandProperty 'IsByPropertyName') -join ';'
            $target | Should -BeExactly 'True;False;False;False;False'
        }
        It "Die Rueckgabe enthaelt in der richtigen Reihenfolge alle Parameter-IsDynamics" {
            $target = (Get-ParameterInfo -CmdletName 'Test-Dummy' | Select-Object -ExpandProperty 'IsDynamic') -join ';'
            $target | Should -BeExactly 'False;True;False;False;False'
        }
    }
}