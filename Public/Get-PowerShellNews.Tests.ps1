<<<<<<< HEAD
﻿BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-PowerShellNews" {

    It "Should return news items when no parameters are specified" {
        # Act
        $newsItems = Get-PowerShellNews
        
        # Assert
        $newsItems | Should -Not -BeNullOrEmpty
    }

    Context "When the AfterDate parameter is specified" {

        It "Should return news items before a specified date" {
            # Arrange
            $afterDate = Get-Date "2022-01-01"
            
            # Act
            $newsItems = Get-PowerShellNews -AfterDate $afterDate
            
            # Assert
            $newsItems | ForEach-Object -Process {
                $_.Release | Should -BeGreaterOrEqual $afterDate
            }
        }
    }
}
=======
﻿BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-PowerShellNews" {

    It "Should return news items when no parameters are specified" {
        # Act
        $newsItems = Get-PowerShellNews
        
        # Assert
        $newsItems | Should -Not -BeNullOrEmpty
    }

    Context "When the AfterDate parameter is specified" {

        It "Should return news items before a specified date" {
            # Arrange
            $afterDate = Get-Date "2022-01-01"
            
            # Act
            $newsItems = Get-PowerShellNews -AfterDate $afterDate
            
            # Assert
            $newsItems | ForEach-Object -Process {
                $_.Release | Should -BeGreaterOrEqual $afterDate
            }
        }
    }
}
>>>>>>> 47bdafb926307894e343ff9720d2bc56b970228c
