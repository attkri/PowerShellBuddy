$FileList = @()
$AbsoluteBasePath = (Resolve-Path -Path '.').Path + '\'
Get-ChildItem -Path '.' -Recurse -File | Sort-Object -Property DirectoryName, FullName | ForEach-Object -Process {
    $FileList += $_.FullName.Replace($AbsoluteBasePath, '')
}

$FunctionsToExport = @()
Get-ChildItem -Path '.\Public\*.ps1' -Exclude '*.Tests.ps1' -File | Sort-Object -Property Name | ForEach-Object -Process {
    $FunctionsToExport += $_.BaseName
}

Update-ModuleManifest -Path '.\PowerShellBuddy.psd1' -FileList $FileList -FunctionsToExport $FunctionsToExport