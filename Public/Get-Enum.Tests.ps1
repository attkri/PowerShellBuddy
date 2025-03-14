<<<<<<< HEAD
﻿Describe "Get-Enum" -Tag 'UnitTests' {

    Context "When searching for a specific enum value" {

        It "Should return the correct enum object" {
            # Arrange
            $expectedEnum = [System.DayOfWeek]::Monday

            # Act
            $result = Get-Enum -FindEnumValue 'Monday' -IncludeAllEnums

            # Assert
            $result.Values | Should -Contain $expectedEnum.ToString()
        }
    }

    Context "When searching for a specific enum name" {

        It "Should return the correct enum object" {
            # Arrange
            $expectedEnum = [System.DayOfWeek]

            # Act
            $result = Get-Enum -FindEnumName 'DayOfWeek' -IncludeAllEnums

            # Assert
            $result.Name | Should -Be $expectedEnum.FullName
        }
    }
}
=======
﻿Describe "Get-Enum" -Tag 'UnitTests' {

    Context "When searching for a specific enum value" {

        It "Should return the correct enum object" {
            # Arrange
            $expectedEnum = [System.DayOfWeek]::Monday

            # Act
            $result = Get-Enum -FindEnumValue 'Monday' -IncludeAllEnums

            # Assert
            $result.Values | Should -Contain $expectedEnum.ToString()
        }
    }

    Context "When searching for a specific enum name" {

        It "Should return the correct enum object" {
            # Arrange
            $expectedEnum = [System.DayOfWeek]

            # Act
            $result = Get-Enum -FindEnumName 'DayOfWeek' -IncludeAllEnums

            # Assert
            $result.Name | Should -Be $expectedEnum.FullName
        }
    }
}
>>>>>>> 47bdafb926307894e343ff9720d2bc56b970228c
