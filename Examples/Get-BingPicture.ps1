<<<<<<< HEAD
﻿# TODO Bzgl. EXIF z.b. https://dennisaa.wordpress.com/2017/04/26/powershell-updating-jpg-metadata/

function Get-BingPicture {
    <#
        .SYNOPSIS
        Download der letzten BING-Such-Hintergrundbilder

        .EXAMPLE
        Get-BingPicture -ShowPicture
        Es werden die letzten 8 Bilder im Download-Order gespeichert und angezeigt.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter','')]
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([PSCustomObject])]
    param (
        [string]$DestinationPath = "$env:USERPROFILE\Downloads",

        [ValidateSet("en-US", "zh-CN", "ja-JP", "en-AU", "en-UK", "de-DE", "en-NZ")]
        [string]$Market = "de-DE",

        [ValidateRange(1, 8)]
        [int]$LastPictures = 8,

        [switch]$ShowPicture
    )

    "Market = $Market | Last Pictures = $LastPictures | Destination Path = $DestinationPath" | Write-Verbose

    $request = Invoke-WebRequest -Uri "https://www.bing.com/HPImageArchive.aspx?mbl=1&mkt=$Market&idx=0&n=$LastPictures" -Verbose:$false
    [xml]$bingPictures = $request.Content

    $bingPictures.images.image | ForEach-Object -Process {

        $MyMatches = $_.copyright | Select-String -Pattern "^(.+)( \(© )(.*\))$"
        $picTitle = $MyMatches.Matches[0].Groups[1].Value.Replace("/", "-")
        $picDownloadUrl = "https://www.bing.com$($_.url)"
        $picPublished = [DateTime]::ParseExact($_.startdate, "yyyyMMdd", $null)
        $picDestinationUrl = Join-Path -Path $DestinationPath -ChildPath ("{0}.jpg" -f $picTitle)

        Invoke-WebRequest -Uri $picDownloadUrl -OutFile $picDestinationUrl -Verbose:$false

        $pictureFile = Get-Item -Path $picDestinationUrl
        $pictureFile.CreationTime = $picPublished
        $pictureFile.LastWriteTime = $picPublished

        [PSCustomObject]@{
            Title     = $picTitle
            Published = $picPublished
            Path      = $picDestinationUrl
        }

        if ($ShowPicture) {
            Start-Process -FilePath $picDestinationUrl
        }
    }
}
=======
﻿# TODO Bzgl. EXIF z.b. https://dennisaa.wordpress.com/2017/04/26/powershell-updating-jpg-metadata/

function Get-BingPicture {
    <#
        .SYNOPSIS
        Download der letzten BING-Such-Hintergrundbilder

        .EXAMPLE
        Get-BingPicture -ShowPicture
        Es werden die letzten 8 Bilder im Download-Order gespeichert und angezeigt.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter','')]
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([PSCustomObject])]
    param (
        [string]$DestinationPath = "$env:USERPROFILE\Downloads",

        [ValidateSet("en-US", "zh-CN", "ja-JP", "en-AU", "en-UK", "de-DE", "en-NZ")]
        [string]$Market = "de-DE",

        [ValidateRange(1, 8)]
        [int]$LastPictures = 8,

        [switch]$ShowPicture
    )

    "Market = $Market | Last Pictures = $LastPictures | Destination Path = $DestinationPath" | Write-Verbose

    $request = Invoke-WebRequest -Uri "https://www.bing.com/HPImageArchive.aspx?mbl=1&mkt=$Market&idx=0&n=$LastPictures" -Verbose:$false
    [xml]$bingPictures = $request.Content

    $bingPictures.images.image | ForEach-Object -Process {

        $MyMatches = $_.copyright | Select-String -Pattern "^(.+)( \(© )(.*\))$"
        $picTitle = $MyMatches.Matches[0].Groups[1].Value.Replace("/", "-")
        $picDownloadUrl = "https://www.bing.com$($_.url)"
        $picPublished = [DateTime]::ParseExact($_.startdate, "yyyyMMdd", $null)
        $picDestinationUrl = Join-Path -Path $DestinationPath -ChildPath ("{0}.jpg" -f $picTitle)

        Invoke-WebRequest -Uri $picDownloadUrl -OutFile $picDestinationUrl -Verbose:$false

        $pictureFile = Get-Item -Path $picDestinationUrl
        $pictureFile.CreationTime = $picPublished
        $pictureFile.LastWriteTime = $picPublished

        [PSCustomObject]@{
            Title     = $picTitle
            Published = $picPublished
            Path      = $picDestinationUrl
        }

        if ($ShowPicture) {
            Start-Process -FilePath $picDestinationUrl
        }
    }
}
>>>>>>> 47bdafb926307894e343ff9720d2bc56b970228c
