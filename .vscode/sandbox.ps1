<#
.SYNOPSIS
Open a Windows Sandbox instance and test an Intune Win32App package

.NOTES

Modification Log
----------------
20240706-001 AW Original script courtesy of Chris Gerke via Mattias Melkersen's GitHub
20240706-002 AW Update variables to use the $scriptState object
20240706-003 AW Changed <ReadOnly> to false so that logs can be returned to the host for DevOps
20240707-001 AW Change the nature of this script so that it is called from global.ps1

#>


# Vars
#. ".vscode\Global.ps1"

# Check that we have been called by global.ps1
if (Test-Path variable:scriptState) {
    Write-Host "Check for scriptState: Found"
} else {
    Write-Warning "Check for scriptState: Not Found"
    Write-Warning "Sandbox must be called from global.ps1.  Cannot continue"
    Exit 1
}

$sourceLogonCommand =  Join-Path -Path $scriptState.PSAppDeployFolderPath -ChildPath ".vscode\$($scriptState.LogonCommand)"
$sbFolder = "$($scriptState.WDADesktop)\DevOps"

$sbOutFile = Join-Path -Path $scriptState.SandboxFilesFolderPath -ChildPath "$($scriptState.Application).wsb"
$sbLogonCommand = Join-Path -Path $sbFolder -ChildPath $scriptState.LogonCommand

 
# Copy Resources
Copy-Item -Path "$sourceLogonCommand" -Destination "$($scriptState.AppCachePath)\" -Recurse -Force -Verbose -ErrorAction Ignore
#https://github.com/microsoft/winget-cli/releases/download/v1.8.1791/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

# Prepare Sandbox
@"
<Configuration>
<Networking>Enabled</Networking>
<MappedFolders>
    <MappedFolder>
    <HostFolder>$($scriptState.AppCachePath)</HostFolder>
    <SandboxFolder>$sbFolder</SandboxFolder>
    <ReadOnly>false</ReadOnly>
    </MappedFolder>
</MappedFolders>
<LogonCommand>
    <Command>powershell -ExecutionPolicy Unrestricted -Command "Start-Process powershell -ArgumentList ""-nologo -file $sbLogonCommand"""</Command>
</LogonCommand>
</Configuration>
"@ | Out-File "$sbOutFile"

# Execute Sandbox
Start-Process explorer -ArgumentList "$sbOutFile" -Verbose
