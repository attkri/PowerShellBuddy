$ProjectRoot = Split-Path -Parent $PSScriptRoot
$AbsoluteBasePath = (Resolve-Path -Path $ProjectRoot).Path + '\'

$PackageFiles = @(
    'License.md'
    'PowerShellBuddy.psd1'
    'PowerShellBuddy.psm1'
    'README.md'
)

$FileList = [System.Collections.Generic.List[string]]::new()

foreach ($file in $PackageFiles) {
    $sourcePath = Join-Path $ProjectRoot $file
    if (Test-Path -Path $sourcePath -PathType Leaf) {
        $FileList.Add($file)
    }
}

Get-ChildItem -Path (Join-Path $ProjectRoot 'en-US') -Recurse -File -ErrorAction SilentlyContinue |
    Sort-Object -Property FullName |
    ForEach-Object -Process {
        $FileList.Add($_.FullName.Replace($AbsoluteBasePath, ''))
    }

Get-ChildItem -Path (Join-Path $ProjectRoot 'Public') -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notlike '*.Tests.ps1' } |
    Sort-Object -Property FullName |
    ForEach-Object -Process {
        $FileList.Add($_.FullName.Replace($AbsoluteBasePath, ''))
    }

$FunctionsToExport = @(
    Get-ChildItem -Path (Join-Path $ProjectRoot 'Public\*.ps1') -Exclude '*.Tests.ps1' -File |
        Sort-Object -Property Name |
        Select-Object -ExpandProperty BaseName
)

Update-ModuleManifest -Path (Join-Path $ProjectRoot 'PowerShellBuddy.psd1') -FileList @($FileList | Sort-Object -Unique) -FunctionsToExport $FunctionsToExport
