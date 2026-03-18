<#
.SYNOPSIS
Publishes the PowerShellBuddy module to the PowerShell Gallery.

.DESCRIPTION
Creates a clean staging directory with only the files required for the module
package, validates the staged manifest, and then publishes the module.

.PARAMETER ApiKey
The NuGet API key for the PowerShell Gallery.

.PARAMETER Repository
The target repository. Defaults to 'PSGallery'.

.EXAMPLE
.\Publish-PowerShellBuddy.ps1 -ApiKey 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'

.EXAMPLE
.\Publish-PowerShellBuddy.ps1 -ApiKey $env:PSGALLERY_API_KEY -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$ApiKey,

    [string]$Repository = 'PSGallery'
)

$ErrorActionPreference = 'Stop'
$ModuleName = 'PowerShellBuddy'
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$StagingRoot = Join-Path $env:TEMP "$ModuleName-Publish-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$StagingPath = Join-Path $StagingRoot $ModuleName

$RootFiles = @(
    'License.md'
    'PowerShellBuddy.psd1'
    'PowerShellBuddy.psm1'
    'README.md'
)

try {
    Write-Host "Creating staging directory: $StagingPath" -ForegroundColor Cyan
    New-Item -Path $StagingPath -ItemType Directory -Force | Out-Null

    foreach ($file in $RootFiles) {
        $source = Join-Path $ProjectRoot $file
        if (-not (Test-Path $source -PathType Leaf)) {
            throw "Required module file not found: $source"
        }

        Copy-Item -Path $source -Destination (Join-Path $StagingPath $file)
    }

    foreach ($directory in 'en-US', 'Public') {
        $source = Join-Path $ProjectRoot $directory
        if (-not (Test-Path $source -PathType Container)) {
            throw "Required module directory not found: $source"
        }

        Copy-Item -Path $source -Destination (Join-Path $StagingPath $directory) -Recurse
    }

    Get-ChildItem -Path (Join-Path $StagingPath 'Public') -Recurse -File -Filter '*.Tests.ps1' |
        Remove-Item -Force

    $stagedManifestPath = Join-Path $StagingPath "$ModuleName.psd1"
    $stagedRoot = (Resolve-Path -Path $StagingPath).Path + '\'
    $stagedFileList = Get-ChildItem -Path $StagingPath -Recurse -File |
        Sort-Object -Property FullName |
        ForEach-Object { $_.FullName.Replace($stagedRoot, '') }
    $functionsToExport = Get-ChildItem -Path (Join-Path $StagingPath 'Public\*.ps1') -Exclude '*.Tests.ps1' -File |
        Sort-Object -Property Name |
        Select-Object -ExpandProperty BaseName

    Update-ModuleManifest -Path $stagedManifestPath -FileList $stagedFileList -FunctionsToExport $functionsToExport

    Write-Host 'Validating staged module manifest...' -ForegroundColor Cyan
    $manifest = Test-ModuleManifest -Path $stagedManifestPath
    Write-Host "Module: $($manifest.Name) v$($manifest.Version)" -ForegroundColor Green

    Write-Host "`nStaging contents:" -ForegroundColor Cyan
    Get-ChildItem -Path $StagingPath -Recurse -File | ForEach-Object {
        Write-Host "  $($_.FullName.Replace($StagingPath, '.'))" -ForegroundColor Gray
    }

    if ($PSCmdlet.ShouldProcess("$ModuleName v$($manifest.Version)", "Publish to $Repository")) {
        Write-Host "`nPublishing to $Repository..." -ForegroundColor Cyan
        Publish-Module -Path $StagingPath -NuGetApiKey $ApiKey -Repository $Repository -Verbose
        Write-Host 'Publish completed successfully.' -ForegroundColor Green
    }
}
finally {
    if (Test-Path $StagingRoot) {
        Remove-Item $StagingRoot -Recurse -Force
        Write-Host 'Cleaned up staging directory.' -ForegroundColor Gray
    }
}
