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
20240707-001 AW Change property Cache to AppCache to more accurately reflect which folder is being used
                That is, we only work with a subfolder of the main Win32App folder.
20240707-002 AW Add SandboxFiles to $scriptState.  
20240707-003 AW Split $scriptState assignments out of the custom object definition so that they
                can build upon a single ServiceFolder assignment.

#>

###################################################################################################
# Requires                                                                                        #
###################################################################################################

# This script does not require administrator access to build packages or run the sandbox
###Requires -RunAsAdministrator


###################################################################################################
# Parameters                                                                                      #
###################################################################################################

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$AppName
)



###################################################################################################
# Variables                                                                                       #
###################################################################################################

$scriptState = [PSCustomObject]@{
    AppCachePath = ""
    AppDefName = "psadt.json"
    AppDefPath = ""
    Application = ""
    CacheFolderName = "99-Cache"
    CacheFolderPath = ""
    ConfigFolderName = "00-Config"
    ConfigFolderPath = ""
    Desktop = ""
    IntuneFolderName = "IntuneApps"
    IntuneFolderPath = ""
    LogonCommand = "LogonCommand.ps1"
    OutputName = "20-Output"
    OutputFolderPath = ""
    ProdFolderName = "02-Prod"
    ProdFolderPath = ""
    PSAppDeployName = "10-PSAppDeployToolkit"
    PSAppDeployPath = ""
    RepoFolderName = "01-Repo"
    RepoFolderPath = ""
    SandboxFilesName = "30-SandboxFiles"
    SandboxFilesPath = ""
    ServiceFolderPath = "C:\Service"
    UtilsFolderName = "90-Utils"
    UtilsFolderPath = ""
    WDADesktop = "C:\Users\WDAGUtilityAccount\Desktop"
}


###################################################################################################
# Main Program                                                                                    #
###################################################################################################

# Build out our name/path variables starting from a base of $scriptState.ServiceFolderPath


$scriptState.IntuneFolder = Join-Path -Path $scriptState.ServiceFolder -ChildPath $scriptState.IntuneAppsName

# 00-Config
$scriptState.ConfigFolderPath = Join-Path -Path $scriptState.IntuneFolderPath -ChildPath $scriptState.ConfigFolderName

# 01-Repo
$scriptState.ConfigFolderPath = Join-Path -Path $scriptState.IntuneFolderPath -ChildPath $scriptState.RepoFolderName

# 02-Prod
$scriptState.ConfigFolderPath = Join-Path -Path $scriptState.IntuneFolderPath -ChildPath $scriptState.ProdFolderName

# 10-PSAppDeployToolkit
$scriptState.ConfigFolderPath = Join-Path -Path $scriptState.IntuneFolderPath -ChildPath $scriptState.PSAppDeployFolderName

# 20-Output
$scriptState.IntuneOutputFolder = Join-Path -Path $scriptState.IntuneFolder -ChildPath $scriptState.OutputFolderName

# 30-SandboxFiles
$scriptState.SandboxFiles = Join-Path -Path $scriptState.IntuneFolder -ChildPath $scriptState.SandboxFilesName

# 90-Utils
$scriptState.ConfigFolderPath = Join-Path -Path $scriptState.IntuneFolderPath -ChildPath $scriptState.UtilsFolderName

# 99-Cache
$scriptState.Application = "$(& git branch --show-current)"
$scriptState.CacheFolderPath = Join-Path $scriptState.IntuneFolder -ChildPath $scriptState.CacheFolderName
$scriptState.AppCache = Join-Path $scriptState.CacheFolderPath -ChildPath $scriptState.Application

# Miscellaneous
$scriptState.Desktop = [string]([Environment]::GetFolderPath('DesktopDirectory'))


# Display the configuration variables
$scriptState

# Cache resources
Write-Host "Removing $($scriptState.AppCache)" -ForegroundColor Green
Remove-Item -Path "$($scriptState.AppCache)" -Recurse -Force -ErrorAction Ignore

Write-Host "Updating $($scriptState.AppCache)" -ForegroundColor Green
Copy-Item -Path "Toolkit" -Destination "$($scriptState.AppCache)" -Recurse -Force -Verbose -ErrorAction Ignore
#explorer "$Cache"
