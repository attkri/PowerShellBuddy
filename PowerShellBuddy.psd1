@{
      #
      # MODUL-INFORMATION
      #
      
      GUID                  = 'cb790b27-dcec-458f-888d-47d9e7c6599d'
      Description           = 'Things that make the life of a PowerShell developer easier.'
      ModuleVersion         = '1.2.0'
      RootModule            = 'PowerShellBuddy.psm1'

      #
      # AUTHOR
      #

      Author                = 'Attila Krick'
      CompanyName           = 'ATTILAKRCK.COM'
      Copyright             = '(c) 2024 Attila Krick. All rights reserved.'

      #
      # REQUIREMENTS
      #

      PowerShellVersion     = '7.4.1'
      ProcessorArchitecture = 'None'
      CompatiblePSEditions  = @('Desktop', 'Core')

      #
      # PREPARATION
      #

      FormatsToProcess      = @(
            'Public\Get-ModuleUpdate.format.ps1xml',
            'Public\Get-ParameterInfo.format.ps1xml',
            'Public\Test-SecurityState.format.ps1xml'
      )
      FunctionsToExport     = @(
            'Get-Enum',
            'Get-ModuleUpdate',
            'Get-ParameterInfo',
            'Get-PowerShellNews',
            'Get-StrictMode',
            'Get-StringHash',
            'Get-Quote',
            'Get-Weather',
            'Out-Log',
            'Out-Speech',
            'Read-Window',
            'Test-PSDeveloperReady',
            'Test-SecurityState',
            'Use-NewPrompt'
      )
      CmdletsToExport       = @()
      AliasesToExport       = @()
      VariablesToExport     = @()
      FileList              = @(
            'de-DE\about_PowerShellBuddy_AboutTemplate.help.txt',
            'de-DE\about_PowerShellBuddy.help.txt',
            'Examples\Get-BingPicture.ps1',
            'Examples\Get-EuroExchange.ps1',
            'Examples\Get-EuroExchange.Tests.ps1',
            'Public\Get-Enum.ps1',
            'Public\Get-ModuleUpdate.format.ps1xml',
            'Public\Get-ModuleUpdate.ps1',
            'Public\Get-ParameterInfo.format.ps1xml',
            'Public\Get-ParameterInfo.ps1',
            'Public\Get-ParameterInfo.Tests.ps1',
            'Public\Get-PowerShellNews.ps1',
            'Public\Get-Quote.ps1'
            'Public\Get-StrictMode.ps1',
            'Public\Get-StrictMode.Tests.ps1',
            'Public\Get-StringHash.ps1',
            'Public\Get-StringHash.Tests.ps1',
            'Public\Get-Weather.ps1',
            'Public\Get-Weather.Tests.ps1',
            'Public\Out-Log.ps1',
            'Public\Out-Speech.ps1',
            'Public\Read-Window.ps1',
            'Public\Test-PSDeveloperReady.ps1',
            'Public\Test-SecurityState.ps1',
            'Public\Test-SecurityState.Format.ps1xml',
            'Public\Use-NewPrompt.ps1',
            'PowerShellBuddy.psd1',
            'PowerShellBuddy.psm1',
            'PowerShellBuddy.Tests.ps1'
      )

      #
      # POWERSHELL GALLERY INFORMATION
      #

      PrivateData           = @{
            PSData = @{
                  LicenseUri   = 'https://attilakrick.com/datenschutzerklaerung'
                  ProjectUri   = 'https://attilakrick.com/powershell/'
                  IconUri      = 'https://attilakrick.com/media/AKPT-Logo.png'
                  Tags         = @('Attila',  'Krick', 'Developer', 'Tools', 'Helpful', 'Scripting', 'Debugging', 'Analysis')
                  ReleaseNotes = @'
Version 1.2:
      - New Cmdlet Get-Weather
      - Remove Get-TypeDocumentation
Version 1.1:
      - New Cmdlet Get-StringHash
Version 1.0:
      - Initial release
'@
            }
      }
}