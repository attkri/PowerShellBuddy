enum ModuleUpdateStatus {
    Unknown
    InPSGalleryNotFound
    UpToDate
    UpdateNeed
}

class ModuleInfo {
    [string]$Name
    [version]$LocalVersion
    [version]$GalleryVersion
    [ModuleUpdateStatus]$UpdateStatus
    [string] $LocalModulePath
}


<#
.SYNOPSIS
Overview of modules that could be updated.

.DESCRIPTION
All local modules are available with an existing version in the Power Shell Gallery compared to a newer module version.
#>
function Get-ModuleUpdate {
    [CmdletBinding(ConfirmImpact = 'Low')]
    param (
        [Parameter()]
        [string]$Name = '*',

        [Parameter()]
        [switch]$ShowAll
    )

    process {
        $galleryModules = @{}

        Get-Module -Name $Name -ListAvailable |
            Group-Object -Property Name |
            ForEach-Object -Process {
                $_.Group | Sort-Object -Property Version -Descending | Select-Object -First 1
            } |
            Sort-Object -Property Name |
            ForEach-Object -Process {
            $localModule = $_

            if (-not $galleryModules.ContainsKey($localModule.Name)) {
                $galleryModules[$localModule.Name] = Find-Module -Name $localModule.Name -ErrorAction Ignore |
                    Sort-Object -Property Version -Descending |
                    Select-Object -First 1
            }

            $GalleyModule = $galleryModules[$localModule.Name]
            $Result = [ModuleInfo]::new()
            $Result.Name = $localModule.Name
            $Result.LocalModulePath = $localModule.ModuleBase
            $Result.LocalVersion = $localModule.Version
            $Result.UpdateStatus = [ModuleUpdateStatus]::InPSGalleryNotFound
            if ($null -ne $GalleyModule) {
                $Result.GalleryVersion = $GalleyModule.Version
                $Result.UpdateStatus = [ModuleUpdateStatus]::UpToDate
                if ([version]($GalleyModule.Version) -gt $localModule.Version) {
                    $Result.UpdateStatus = [ModuleUpdateStatus]::UpdateNeed
                }
            }
            
            if($ShowAll -or $Result.UpdateStatus -eq [ModuleUpdateStatus]::UpdateNeed -or $Name -eq $localModule.Name) {
                return $Result
            }
        }
    }
}

<#
Update-FormatData -PrependPath .\Modules\PowerShellBuddy\Public\Get-ModuleUpdate.format.ps1xml
Get-ModuleUpdate
Get-ModuleUpdate -ShowAll
Get-ModuleUpdate -Name Pester 
Get-ModuleUpdate | Update-Module -PassThru
#>
