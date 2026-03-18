using namespace System.Management.Automation

$publicScripts = @(
    Get-ChildItem -Path (Join-Path $PSScriptRoot 'Public') -Filter '*.ps1' -Exclude '*.Tests.ps1' -File |
        Sort-Object -Property Name
)

foreach ($scriptFile in $publicScripts) {
    . $scriptFile.FullName
}

$functionsToExport = @(
    $publicScripts.BaseName |
        Sort-Object -Unique
)

Export-ModuleMember -Function $functionsToExport

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    try {
        Get-Job -Name 'PowerShellBuddy-*' -ErrorAction SilentlyContinue |
            Remove-Job -Force -ErrorAction SilentlyContinue

        Get-EventSubscriber -ErrorAction SilentlyContinue |
            Where-Object SourceIdentifier -like 'PowerShellBuddy-*' |
            Unregister-Event -ErrorAction SilentlyContinue

        Get-Variable -Name 'PowerShellBuddy*' -Scope Script -ErrorAction SilentlyContinue |
            ForEach-Object {
                Remove-Variable -Name $_.Name -Scope Script -Force -ErrorAction SilentlyContinue
            }
    }
    catch {
    }
}
