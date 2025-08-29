BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Function Out-Log" -Tag 'UnitTests' {

    Context "Logging to a new log file" {

        It "Creates a new log file if it doesn't exist" {
            $logFilePath = "TestDrive:\Test_Out-Log_$(Get-Random).log"
            
            $logFilePath | Should -Not -Exist
            
            Out-Log -LogFilePath $logFilePath -Message "Test message" -Status Information
            
            $logFilePath | Should -Exist
        }
        
        It "Logs the message with the specified status" {
            $logFilePath = "TestDrive:\Test_Out-Log_$(Get-Random).log"
            
            Out-Log -LogFilePath $logFilePath -Message "Test message" -Status Warning
            
            $logContents = Get-Content -Path $logFilePath -Raw
            $logContents | Should -Match " > Warning     > Test message"
        }
    }

    Context "Logging to an existing log file" {
                
                It "Appends the message to the existing log file" {
                    $logFilePath = "TestDrive:\Test_Out-Log_$(Get-Random).log"
                    
                    Out-Log -LogFilePath $logFilePath -Message "Test message" -Status Error
                    $logContentsBefore = Get-Content -Path $logFilePath
                    $logContentsBefore[-1] | Should -Match " > Error       > Test message"
                    
                    Out-Log -LogFilePath $logFilePath -Message "Test message" -Status Information
                    $logContentsAfter = Get-Content -Path $logFilePath
                    $logContentsAfter[-1] | Should -Match "Information > Test message"
        }
    }
}
