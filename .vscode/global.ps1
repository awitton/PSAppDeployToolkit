<#
.SYNOPSIS
Prepare global variables for Build, Sandbox, and LogonCommand scripts

.NOTES

Modification Log
----------------
20240706-001 AW Original script courtesy of Chris Gerke via Mattias Melkersen's GitHub
20240706-002 AW Update to suit Harmonic IT style including object vs muliple variables
20240706-003 AW Add ServiceFolder to $scriptState
20240706-004 AW Add IntuneAppsFolder to $scriptState

#>

# Vars
$scriptState = [PSCustomObject]@{
    Desktop = [string]([Environment]::GetFolderPath('DesktopDirectory'))
    WDADesktop = [string]"C:\Users\WDAGUtilityAccount\Desktop"
    Win32App = [string]"C:\Service\Win32App"
    Application = [string]"$(& git branch --show-current)"
    Cache = ""
    LogonCommand = [string]"LogonCommand.ps1"
    ServiceFolder = [string]"C:\Service"
    IntuneAppsFolder = [string]"C:\Service\IntuneApps\Output"
}

# Set the cache location
$scriptState.Cache = "C:\Service\Win32App\$($scriptState.Application)"

# Display the configuration variables
$scriptState

# Cache resources
Write-Host "Removing $($scriptState.Cache)" -ForegroundColor Green
Remove-Item -Path "$($scriptState.Cache)" -Recurse -Force -ErrorAction Ignore

Write-Host "Updating $($scriptState.Cache)" -ForegroundColor Green
Copy-Item -Path "Toolkit" -Destination "$($scriptState.Cache)" -Recurse -Force -Verbose -ErrorAction Ignore
#explorer "$Cache"
