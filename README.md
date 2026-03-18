# PowerShellBuddy

PowerShellBuddy is a practical toolbox for day-to-day PowerShell work. It bundles small, focused commands for logging, prompt customization, command discovery, weather and news lookups, security checks, and a few developer-oriented helpers.

Created and maintained by [Attila Krick](https://attilakrick.com).

## Overview

The module is designed for people who work in PowerShell regularly and want a lightweight set of convenience commands instead of a large framework.

You can use it to explore parameters and enums, check for module updates, write quick log files, display spoken output, fetch public web data, and run a few workstation readiness or security-oriented checks.

Most commands are small and easy to try interactively. A few commands are Windows-specific because they depend on WPF, speech APIs, Defender, certificate stores, or Windows security features.

## Prerequisites

- PowerShell `7.4` or later
- Internet access for commands such as `Get-Weather`, `Get-PowerShellNews`, and `Get-ModuleUpdate`
- Windows for commands such as `Read-Window`, `Out-Speech`, `Test-SecurityState`, and parts of `Test-PSDeveloperReady`

## Install

Install the module from the [PowerShell Gallery](https://www.powershellgallery.com/packages/PowerShellBuddy):

```powershell
Install-Module -Name PowerShellBuddy -Scope CurrentUser
```

Then import it:

```powershell
Import-Module PowerShellBuddy
```

## Quick Start

```powershell
Get-Command -Module PowerShellBuddy
Get-ParameterInfo -CmdletName Get-ChildItem
Get-ModuleUpdate
Get-Weather -Location Hamburg -OnlyCurrentWeather
Get-PowerShellNews -AfterDate (Get-Date).AddDays(-30)
Out-Log -Message 'Build started' -Status Information
```

## Included Commands

### Discovery and inspection

- `Get-Enum` - list enum types and values from loaded assemblies
- `Get-ParameterInfo` - inspect parameter metadata for any command
- `Get-ModuleUpdate` - compare local modules with PowerShell Gallery versions

### Everyday utilities

- `Get-Weather` - retrieve weather data from `wttr.in`
- `Get-PowerShellNews` - read recent posts from the Microsoft PowerShell blog feed
- `Get-Quote` - show a random quote or a quote of the day
- `Get-StringHash` - hash plain text or derive password hashes with PBKDF2-SHA512
- `Out-Log` - write simple log entries to a file
- `Start-Countdown` - show a countdown in the console

### Developer helpers

- `Get-Hotkey` - show useful editor and console shortcuts
- `Use-NewPrompt` - temporarily replace the current prompt
- `Test-PSDeveloperReady` - check a workstation for a few common PowerShell development basics

### Windows-focused commands

- `Read-Window` - open a simple input dialog
- `Out-Speech` - convert text to speech
- `Test-SecurityState` - inspect a Windows machine for selected PowerShell-related security signals

## Notes

- External services can change their responses over time. Internet-facing commands should be treated as convenience helpers, not hard production dependencies.
- Some commands intentionally favor interactive use. If you want to automate them, inspect their output first with `Get-Member`.
- Repository example scripts can still be kept outside the published package for reference and experimentation.

## Project Links

- Source code: [github.com/attkri/PowerShellBuddy](https://github.com/attkri/PowerShellBuddy)
- Author website: [attilakrick.com](https://attilakrick.com)
