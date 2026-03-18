function Get-Hotkey {
    [CmdletBinding()]
    param ()

    $Content = @(
        [PSCustomObject]@{ Area = 'VS Code'; Shortcut = '[F8]'; Description = 'Run the current line or the current selection.' }
        [PSCustomObject]@{ Area = 'VS Code'; Shortcut = '[F5]'; Description = 'Run the entire .ps1 file.' }
        [PSCustomObject]@{ Area = 'VS Code'; Shortcut = '[SHIFT] + [ALT] + [ARROW KEY]'; Description = 'Duplicate the current line or selection.' }
        [PSCustomObject]@{ Area = 'VS Code'; Shortcut = '[ALT] + [ARROW KEY]'; Description = 'Move the current line or selection.' }
        [PSCustomObject]@{ Area = 'VS Code'; Shortcut = '[CTRL] + [SPACE]'; Description = 'Open the suggestion list.' }
        [PSCustomObject]@{ Area = 'VS Code'; Shortcut = '[CTRL] + [ALT] + [J]'; Description = 'Open the PowerShell snippet and template picker.' }
        [PSCustomObject]@{ Area = 'Console'; Shortcut = '[CTRL] + [SPACE]'; Description = 'Open the suggestion list.' }
    )

    return $Content 
}

<#
Get-Hotkey
#>
