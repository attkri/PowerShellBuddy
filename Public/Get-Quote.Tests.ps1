<<<<<<< HEAD
﻿BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-Quote" {

    Context "When QuoteOfDay switch is not used" {

        It "Should return a random quote" {
            $quote = Get-Quote
            $quote | Should -BeOfType [String]
        }
    }

    Context "When QuoteOfDay switch is used" {

        It "Should return a quote based on the current day of the year" {
            $quote = Get-Quote -QuoteOfDay
            $quote | Should -BeOfType [String]
        }
    }
}
=======
﻿BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "Get-Quote" {

    Context "When QuoteOfDay switch is not used" {

        It "Should return a random quote" {
            $quote = Get-Quote
            $quote | Should -BeOfType [String]
        }
    }

    Context "When QuoteOfDay switch is used" {

        It "Should return a quote based on the current day of the year" {
            $quote = Get-Quote -QuoteOfDay
            $quote | Should -BeOfType [String]
        }
    }
}
>>>>>>> 47bdafb926307894e343ff9720d2bc56b970228c
