function Get-TopTenCmdlet {
    [CmdletBinding()]
    param ()

    $Content = @(
        [PSCustomObject]@{ Rank = 1 ; Name = 'Get-Member'     ; Description = 'Inspect an object type and explore its available properties, methods, and events.' },
        [PSCustomObject]@{ Rank = 2 ; Name = 'Get-Command'    ; Description = 'Find available cmdlets, functions, aliases, and applications, and inspect their syntax.' },
        [PSCustomObject]@{ Rank = 3 ; Name = 'Get-Help'       ; Description = 'Read help content for commands and PowerShell concepts.' },
        [PSCustomObject]@{ Rank = 4 ; Name = 'Select-Object'  ; Description = 'Shape pipeline output by controlling what is returned and how much is shown.' }
        [PSCustomObject]@{ Rank = 5 ; Name = 'Where-Object'   ; Description = 'Filter pipeline objects by using conditions.' }
        [PSCustomObject]@{ Rank = 6 ; Name = 'Sort-Object'    ; Description = 'Sort pipeline objects.' }
        [PSCustomObject]@{ Rank = 7 ; Name = 'Measure-Object' ; Description = 'Measure pipeline data by count, sum, average, or property values.' }
    )

    return $Content 
}

