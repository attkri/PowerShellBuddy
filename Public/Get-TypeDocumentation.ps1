<#
.SYNOPSIS
Opens the microsoft documentation of the respective types in the browser.

.DESCRIPTION
Opens the microsoft documentation of the respective types in the browser.

.INPUTS
System.Object

.OUTPUTS
System.String

.EXAMPLE
Get-ChildItem c:\ -Force | Get-TypeDocumentation

.EXAMPLE
Get-Process | Get-TypeDocumentation

.EXAMPLE
Get-Service | Get-TypeDocumentation

.EXAMPLE
1 | Get-TypeDocumentation
#>
function Get-TypeDocumentation {
    begin {
        $My = [HashTable]::Synchronized(@{})
        $My.TypeNames = @()
    }
    process {
        $My.TypeNames += $_.GetType().FullName
    }
    end {
        $My.TypeNames | Select-Object -Unique | ForEach-Object -Process {
            $url = 'https://docs.microsoft.com/de-de/dotnet/api/{0}' -f $_
            $_
            Start-Process $url
        }
        Remove-Variable -Name 'My' -Force
    }
}
