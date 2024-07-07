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
20240707-004 AW Add $AppName parameter so that the script can run independently of VSCode
20240707-005 AW Add support for reading the psadt.json appdef file


VSCode Debug Strings
--------------------
"args": ["-AppName 'GoogleChrome'"]

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
    AppDef = [System.Collections.ArrayList]@()
    AppDefItem = $null
    AppDefName = "psadt.json"
    AppDefPath = ""
    Application = ""
    CacheFolderName = "99-Cache"
    CacheFolderPath = ""
    ConfigFolderName = "00-Config"
    ConfigFolderPath = ""
    Desktop = ""
    FilesFolderName = "Files"
    FilesFolderPath = ""
    IntuneFolderName = "IntuneApps"
    IntuneFolderPath = ""
    LogonCommand = "LogonCommand.ps1"
    OutputFolderName = "20-Output"
    OutputFolderPath = ""
    ProdFolderName = "02-Prod"
    ProdFolderPath = ""
    PSAppDeployFolderName = "10-PSAppDeployToolkit"
    PSAppDeployFolderPath = ""
    RepoFolderName = "01-Repo"
    RepoFolderPath = ""
    SandboxFilesFolderName = "30-SandboxFiles"
    SandboxFilesFolderPath = ""
    ServiceFolderPath = "C:\Service"
    ToolkitFolderName = "Toolkit"
    ToolkitFolderPath = ""
    UtilsFolderName = "90-Utils"
    UtilsFolderPath = ""
    WDADesktop = "C:\Users\WDAGUtilityAccount\Desktop"
}


###################################################################################################
# Main Program                                                                                    #
###################################################################################################

# Build out our name/path variables starting from a base of $scriptState.ServiceFolderPath
$scriptState.IntuneFolderPath = Join-Path -Path $scriptState.ServiceFolderPath -ChildPath $scriptState.IntuneFolderName

# 00-Config
$scriptState.ConfigFolderPath = Join-Path -Path $scriptState.IntuneFolderPath -ChildPath $scriptState.ConfigFolderName
$scriptState.AppDefPath = Join-Path -Path $scriptState.ConfigFolderPath -ChildPath $scriptState.AppDefName

# 01-Repo
$scriptState.RepoFolderPath = Join-Path -Path $scriptState.IntuneFolderPath -ChildPath $scriptState.RepoFolderName

# 02-Prod
$scriptState.ProdFolderPath = Join-Path -Path $scriptState.IntuneFolderPath -ChildPath $scriptState.ProdFolderName

# 10-PSAppDeployToolkit
$scriptState.PSAppDeployFolderPath = Join-Path -Path $scriptState.IntuneFolderPath -ChildPath $scriptState.PSAppDeployFolderName
$scriptState.ToolkitFolderPath = Join-Path $scriptState.PSAppDeployFolderPath -ChildPath $scriptState.ToolkitFolderName

# 20-Output
$scriptState.OutputFolderPath = Join-Path -Path $scriptState.IntuneFolderPath -ChildPath $scriptState.OutputFolderName

# 30-SandboxFiles
$scriptState.SandboxFilesFolderPath = Join-Path -Path $scriptState.IntuneFolderPath -ChildPath $scriptState.SandboxFilesFolderName

# 90-Utils
$scriptState.UtilsFolderPath = Join-Path -Path $scriptState.IntuneFolderPath -ChildPath $scriptState.UtilsFolderName

# 99-Cache
if ($AppName) {
    $scriptState.Application = $AppName
    Write-Host "Assign Application from AppName parameter: $AppName"
} else {
    $gitBranch = "$(& git branch --show-current)"
    $scriptState.Application = $gitBranch
    Write-Host "Assign Application from Git branch: $gitBranch"
}

$scriptState.CacheFolderPath = Join-Path $scriptState.IntuneFolderPath -ChildPath $scriptState.CacheFolderName
$scriptState.AppCachePath = Join-Path $scriptState.CacheFolderPath -ChildPath $scriptState.Application
$scriptState.FilesFolderPath = Join-Path $scriptState.AppCachePath -Childpath $scriptState.FilesFolderName

# Miscellaneous
$scriptState.Desktop = [string]([Environment]::GetFolderPath('DesktopDirectory'))


# Display the configuration variables
$scriptState | 
    Select-Object Application, ServiceFolderPath, IntuneFolderPath, ConfigFolderPath, `
        AppDefPath, RepoFolderPath, ProdFolderPath, PSAppDeployFolderPath, ToolkitFolderPath, OutputFolderPath, `
        SandboxFilesFolderPath, UtilsFolderPath, CacheFolderPath, AppCachePath, WDADesktop


# Import our JSON application config file
if (Test-Path -Path $scriptState.AppDefPath -PathType Leaf) {
    Write-Host -MsgSev "debug" -Message "Check for JSON file: Found"
    
    
    # Import the file into an object
    try {
        $scriptState.AppDef = Get-Content -Path $scriptState.AppDefPath -Raw | ConvertFrom-Json
        Write-Host "Load AppDef file: Pass"
    } catch {
        Write-Host "Load AppDef file: Fail"
        Write-Warning "Failed to load AppDef file.  Cannot continue."
        Exit 1
    }
} else {
    Write-Host -MsgSev "debug" -Message "Check for JSON file: Not Found"
    Write-Warning "Failed to find AppDef file.  Cannot continue."
    Exit 1
}


# Check through our new AppDef array for an AppName that matches $scriptState.Application
$scriptState.AppDefItem = $scriptState.AppDef |
    Where-Object {$_.AppName -eq "$($scriptState.Application)"}

if ($scriptState.AppDefitem) {
    Write-Host "Check AppDef array for $($scriptState.Application): Found"
    $scriptState.AppDefItem
} else {
    Write-Warning "Check AppDef array for $($scriptState.Application): Not Found"
    Write-Warning "Failed to find application.  Cannot continue."
    Exit 1
}


# Cache resources
# Remove
Write-Host "Removing cache folder $($scriptState.AppCachePath)"
Remove-Item -Path "$($scriptState.AppCachePath)" -Recurse -Force -ErrorAction Ignore

# Update
Write-Host "Updating cache folder $($scriptState.AppCachePath) from $($scriptState.ToolkitFolderPath)"
Copy-Item -Path "$($scriptState.ToolkitFolderPath)" -Destination "$($scriptState.AppCachePath)" -Recurse -Force -Verbose -ErrorAction Ignore

# Copy application installer files from the related 02-Prod folder
$sourceFilesFolder = Join-Path -Path $scriptState.ProdFolderPath -ChildPath $scriptState.Application
$sourceFilesFolder += "\*"

Write-Host "Adding AppDef files from $sourceFilesFolder to Files cache folder"
Copy-Item -Path $sourceFilesFolder -Destination $scriptState.FilesFolderPath -Force -Verbose


#explorer "$Cache"
