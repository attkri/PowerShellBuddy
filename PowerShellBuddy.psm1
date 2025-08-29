using namespace System.Management.Automation

#region Public Cmdlets-Code ausführen 

Get-ChildItem "$PSScriptRoot\Public\*.ps1" -PipelineVariable cmdlet -Exclude '*.Tests.ps1' |  ForEach-Object -Process {
    . $cmdlet.FullName
}

#endregion

#region Aliase definieren

New-Alias -Name 'gh' -Value 'Get-Help'

#endregion

#region Aufräumarbeiten bei Remove-Module -Name AKPT

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    'alias:\gh', 'alias:\help' | Remove-Item -Force -ErrorAction 'Ignore'
}

#endregion
