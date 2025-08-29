function Get-Enum {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter','')]
    param (
        [string]$FindEnumValue,
        [String]$FindEnumName,
        [switch]$IncludeAllEnums
    )
    $defaultManifestModules = 'CommonLanguageRuntimeLibrary',
                              'Microsoft.CSharp.dll',
                              'Microsoft.Management.Infrastructure.dll',
                              'Microsoft.PowerShell.Commands.Management.dll',
                              'Microsoft.PowerShell.commands.Utility.dll',
                              'System.dll',
                              'System.Configuration.dll',
                              'System.Configuration.Install.dll',
                              'System.Core.dll',
                              'System.Data.dll',
                              'System.DirectoryServices.dll',
                              'System.Management.Automation.dll',
                              'System.Management.dll',
                              'System.ServiceProcess.dll',
                              'System.Transactions.dll',
                              'System.Xml.dll'

    [System.AppDomain]::CurrentDomain.GetAssemblies() | Where-Object -FilterScript { $IncludeAllEnums -or ($defaultManifestModules -contains $_.ManifestModule) } | ForEach-Object -Process { 
        try { 
            $_.GetExportedTypes() 
        } 
        catch { 
            "Keine ExportedTypes vorhanden" | Write-Verbose 
        } 
    } | Where-Object -FilterScript { $_.IsEnum -and $_.Name -IMatch $FindEnumName } | ForEach-Object -Process {
            return [PSCustomObject]@{
                Name   = $_.FullName
                Source = $_.Module.ScopeName
                Values = [System.Enum]::GetNames($_)
            }
        } | Where-Object -Property Values -IMatch -Value $FindEnumValue
}
