BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe 'Get-ParameterInfo tests' {
    Context 'Parameter metadata' {
        It 'requires -CmdletName as a System.String parameter.' {
            Get-Command -Name Get-ParameterInfo | Should -HaveParameter CmdletName -Type String  -Mandatory
        }
        It 'validates -CmdletName with ValidateNotNullOrEmpty.' {
            $target = (Get-Command -Name Get-ParameterInfo).Parameters['CmdletName']
            $target = $target.Attributes.Where({$_ -is [System.Management.Automation.ValidateNotNullOrEmptyAttribute]})
            $target | should -Not -BeNullOrEmpty
        }
        It 'throws for Get-ParameterInfo -CmdletName $null.' {
            { Get-ParameterInfo -CmdletName $null } | Should -Throw -ErrorId 'ParameterArgumentValidationError,Get-ParameterInfo'
        }
        It "throws for Get-ParameterInfo -CmdletName ''." {
            { Get-ParameterInfo -CmdletName '' } | Should -Throw -ErrorId 'ParameterArgumentValidationError,Get-ParameterInfo'
        }
        It "throws for Get-ParameterInfo -CmdletName 'Missing-Command'." {
            { Get-ParameterInfo -CmdletName 'Missing-Command' } | Should -Throw -ErrorId 'ParameterArgumentValidationError,Get-ParameterInfo'
        }
    }
    Context "Output objects for Get-ParameterInfo -CmdletName 'Test-Dummy'"  {
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
        It 'returns [CmdletParameterInfo] objects.' {

            $target = Get-ParameterInfo -CmdletName 'Test-Dummy' | Select-Object -First 1
            $target.GetType().FullName | Should -BeExactly 'CmdletParameterInfo'
        }
        It 'returns the expected number of objects.' {
            Get-ParameterInfo -CmdletName 'Test-Dummy' | Should -HaveCount 5
        }
        It 'returns parameter names in the expected order.' {
            $target = (Get-ParameterInfo -CmdletName 'Test-Dummy' | Select-Object -ExpandProperty 'Name') -join ';'
            $target | Should -BeExactly 'ExParaC;ExParaD;ProgressAction;ExParaA;ExParaB'
        }
        It 'returns parameter aliases in the expected order.' {
            $target = (Get-ParameterInfo -CmdletName 'Test-Dummy' | Select-Object -ExpandProperty 'Aliases') -join ';'
            $target | Should -BeExactly 'proga;epa;epb;pb'
        }
        It 'returns parameter type names in the expected order.' {
            $target = (Get-ParameterInfo -CmdletName 'Test-Dummy' | Select-Object -ExpandProperty 'TypeName') -join ';'
            $target | Should -BeExactly 'Process[];Int32;ActionPreference;String;SwitchParameter'
        }
        It 'returns parameter set names in the expected order.' {
            $target = (Get-ParameterInfo -CmdletName 'Test-Dummy' | Select-Object -ExpandProperty 'SetName') -join ';'
            $target | Should -BeExactly 'AllParameterSets;AllParameterSets;AllParameterSets;SetA (Default);SetB'
        }
        It 'returns parameter positions in the expected order.' {
            $target = (Get-ParameterInfo -CmdletName 'Test-Dummy' | Select-Object -ExpandProperty 'Position') -join ';'
            $target | Should -BeExactly '1;Named;Named;0;Named'
        }
        It 'returns IsMandatory values in the expected order.' {
            $target = (Get-ParameterInfo -CmdletName 'Test-Dummy' | Select-Object -ExpandProperty 'IsMandatory') -join ';'
            $target | Should -BeExactly 'False;True;False;True;False'
        }
        It 'returns IsByValue values in the expected order.' {
            $target = (Get-ParameterInfo -CmdletName 'Test-Dummy' | Select-Object -ExpandProperty 'IsByValue') -join ';'
            $target | Should -BeExactly 'False;False;False;False;True'
        }
        It 'returns IsByPropertyName values in the expected order.' {
            $target = (Get-ParameterInfo -CmdletName 'Test-Dummy' | Select-Object -ExpandProperty 'IsByPropertyName') -join ';'
            $target | Should -BeExactly 'True;False;False;False;False'
        }
        It 'returns IsDynamic values in the expected order.' {
            $target = (Get-ParameterInfo -CmdletName 'Test-Dummy' | Select-Object -ExpandProperty 'IsDynamic') -join ';'
            $target | Should -BeExactly 'False;True;False;False;False'
        }
    }
}
