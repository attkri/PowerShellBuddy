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
        Get-Module -Name $Name -ListAvailable | Sort-Object -Property 'Name' | ForEach-Object -Process {
            $GalleyModule = $_ | Find-Module -ErrorAction Ignore | Sort-Object -Property 'Version' -Descending | Select-Object -First 1
            $Result = [ModuleInfo]::new()
            $Result.Name = $_.Name
            $Result.LocalModulePath = $_.ModuleBase
            $Result.LocalVersion = $_.Version
            $Result.UpdateStatus = [ModuleUpdateStatus]::InPSGalleryNotFound
            if ($null -ne $GalleyModule) {
                $Result.GalleryVersion = $GalleyModule.Version
                $Result.UpdateStatus = [ModuleUpdateStatus]::UpToDate
                if ([version]($GalleyModule.Version) -gt $_.Version) {
                    $Result.UpdateStatus = [ModuleUpdateStatus]::UpdateNeed
                }
            }
            
            if($ShowAll -or $Result.UpdateStatus -eq [ModuleUpdateStatus]::UpdateNeed -or $Name -eq $_.Name) {
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