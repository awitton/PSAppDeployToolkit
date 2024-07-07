<#
.SYNOPSIS
Open a Windows Sandbox instance and test an Intune Win32App package

.NOTES

Modification Log
----------------
20240706-001 AW Original script courtesy of Chris Gerke via Mattias Melkersen's GitHub
20240706-002 AW Update variables to use the $scriptState object
20240706-003 AW Changed <ReadOnly> to false


#>


# Vars
. ".vscode\Global.ps1"

$sourceLogonCommand = ".vscode\$($scriptState.LogonCommand)"
$hostFolder = "{0}\{1}" -f $scriptState.Win32App, $scriptState.Application
$sbFolder = $scriptState.WDADesktop
$sbOutFile = "{0}\{1}.wsb" -f $scriptState.Win32App, $scriptState.Application
$sbLogonCommand = "{0}\{1}" -f $sbFolder, $scriptState.LogonCommand

 
# Copy Resources
Copy-Item -Path "$sourceLogonCommand" -Destination "$($hostFolder)\" -Recurse -Force -Verbose -ErrorAction Ignore
#https://github.com/microsoft/winget-cli/releases/download/v1.8.1791/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

# Prepare Sandbox
@"
<Configuration>
<Networking>Enabled</Networking>
<MappedFolders>
    <MappedFolder>
    <HostFolder>$hostFolder</HostFolder>
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
