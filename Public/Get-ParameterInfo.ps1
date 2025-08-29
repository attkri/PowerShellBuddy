# TODO: Switch-Parameter für die Anzeige der Common-Parameter

class CmdletParameterInfo {
    [System.String]$Name
    [System.String[]]$Aliases
    [System.String]$TypeName
    [System.String]$SetName
    [System.String]$Position
    [System.Boolean]$IsMandatory
    [System.Boolean]$IsByValue
    [System.Boolean]$IsByPropertyName
    [System.Boolean]$IsDynamic
}

function Get-ParameterInfo {
    <#
        .SYNOPSIS
        Zeigt eine Übersicht an Cmdlet-Parameter-Informationen die u.a. für das Verständnis der Cmdlet- und Pipeline-Verarbeitung hilfreich sind.

        .PARAMETERNAME CommandName
        Command-Let Name das Analysiert werden soll.

        .EXAMPLE
        Get-ParameterInfo -CmdletName Get-ChildItem
        Zeigt Cmdlet-Parameter-Informationen für das Cmdlet Get-ChildItem

        .OUTPUTS
        CmdletParameterInfo
    #>
    [OutputType('CmdletParameterInfo')]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
            try {
                Get-Command -Name $_ -ErrorAction Stop | Out-Null
                return $true
            }
            catch {
                throw "Das CommandLet $_ wurde nicht gefunden."
            }
        })]
        [System.String]
        $CmdletName
    )

    Get-Command -Name "$CmdletName" -PipelineVariable 'command' | Select-Object -ExpandProperty 'Parameters' | Select-Object -ExpandProperty 'Values' | Where-Object -Property 'Name' -NotIn -Value 'Confirm', 'Debug', 'ErrorAction', 'ErrorVariable', 'InformationAction', 'InformationVariable', 'OutBuffer', 'OutVariable', 'PipelineVariable', 'Verbose', 'WarningAction', 'WarningVariable', 'WhatIf' -PipelineVariable 'parameter' | Select-Object -ExpandProperty 'Attributes' -PipelineVariable 'attribute' | Where-Object -FilterScript { $attribute.TypeId.Name -eq 'ParameterAttribute' } | ForEach-Object -Process {

            $result = [CmdletParameterInfo]::new()
            $result.Name             = $parameter.Name
            $result.Aliases          = $parameter.Aliases
            $result.TypeName         = $parameter.ParameterType.Name
            $result.SetName          = $attribute.ParameterSetName
            $result.Position         = $attribute.Position
            $result.IsMandatory      = $attribute.Mandatory
            $result.IsByValue        = $attribute.ValueFromPipeline
            $result.IsByPropertyName = $attribute.ValueFromPipelineByPropertyName
            $result.IsDynamic        = $parameter.IsDynamic

            if([int]$result.Position -lt 0) {
                $result.Position = 'Named'
            }

            $parameterSetInfo = $command.ParameterSets | Where-Object -Property 'Name' -EQ -Value $attribute.ParameterSetName
            if ($null -ne $parameterSetInfo -and $parameterSetInfo.IsDefault) {
                $result.SetName += " (Default)"
            }

            $result.SetName = $result.SetName -replace '__', [String]::Empty

            return $result
        } | Sort-Object -Property 'SetName', 'Name'
}
