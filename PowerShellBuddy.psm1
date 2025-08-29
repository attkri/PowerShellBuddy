using namespace System.Management.Automation

#region Public Cmdlets-Code ausführen und Function in die Session Exportieren

Get-ChildItem "$PSScriptRoot\Public\*.ps1" -PipelineVariable cmdlet -Exclude '*.Tests.ps1' -File |  ForEach-Object -Process {
    . $cmdlet.FullName
    Export-ModuleMember -Function $cmdlet.BaseName
}

#endregion

#region Aufräumarbeiten bei Remove-Module -Name AKPT

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { }

#endregion









#region Public Cmdlets laden
$publicScripts = Get-ChildItem -Path (Join-Path $PSScriptRoot 'Public') -Filter '*.ps1' -Exclude '*.Tests.ps1' -File
foreach ($s in $publicScripts) { . $s.FullName }
#endregion

#region Export: nur tatsächlich definierte Funktionen exportieren
# Annahme: Funktionsname = Dateiname (BaseName). Falls du abweichst, trage sie in $explicit ein.
$byConvention = $publicScripts.BaseName

# Optional: manuelle Ausnahmen/Abweichungen ergänzen (falls nötig)
$explicit = @()  # z.B. 'Get-WeatherEx'

# Nur Funktionen exportieren, die lokal wirklich existieren
$toExport = @($byConvention + $explicit) |
    Where-Object { Test-Path Function:\$_ } |
    Sort-Object -Unique

# Aliasse automatisch mit exportieren (falls du welche setzt)
$aliases = Get-Alias | Where-Object { $_.Definition -in $toExport } | Select-Object -ExpandProperty Name

#endregion

#region Aufräumen bei Remove-Module PowerShellBuddy
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    try {
        # Beispiel: Event-Handler, Jobs, temporäre Variablen etc. aufräumen
        Get-Job -Name 'PowerShellBuddy-*' -ErrorAction SilentlyContinue | Remove-Job -Force -ErrorAction SilentlyContinue
        Unregister-Event -SourceIdentifier 'PowerShellBuddy-*' -ErrorAction SilentlyContinue
        Remove-Variable -Name 'PowerShellBuddy*' -Scope Script -ErrorAction SilentlyContinue
    } catch { }
}
#endregion
