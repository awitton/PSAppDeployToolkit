<#
.SYNOPSIS
Build an Intune Win32App package

.NOTES

References
----------
https://blog.ironmansoftware.com/daily-powershell/powershell-download-github/


Modification Log
----------------
20240706-001 AW Original script courtesy of Chris Gerke via Mattias Melkersen's GitHub
20240706-002 AW Update to suit Harmonic IT style including object vs muliple variables
20240706-003 AW Add Write-Host output for debugging
20240706-004 AW Supplied Uri was creating a 16-bit version of IntuneWinAppUtil somehow.
                Found a reference that suggested getting the URL from the RAW button
                Changed $Uri from 'tree' to 'raw'
                (Noted that the YouTube video has the correct URI)

#>

# Vars
. ".vscode\Global.ps1"

# intunewin
[string]$Uri = "https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/raw/master"
[string]$Exe = "IntuneWinAppUtil.exe"
[string]$SourceUrl = "$Uri/$Exe"

# Source content prep tool
$outFile = Join-Path -Path $scriptState.ServiceFolder -ChildPath $Exe

if (-not(Test-Path -Path $outFile)){
    Write-Host "Check for $($exe): Not Found (will be downloaded)"
   
    try {
        Invoke-WebRequest -Uri $sourceUrl -OutFile $outFile
        Write-Host "Download $exe from $($uri): Pass"
    } catch {
        Write-Host "Download $exe from $($uri): Fail"
        Write-Host "Cannot continue build step without $exe"
        Exit 1
    }
} else {
    Write-Host "Check for $($exe): Found"
}

# Execute content prep tool
Write-Host "Building Deploy-Application and saving to $($env:TEMP)"
$setupFolder = $scriptState.Cache
$setupFile = "$($scriptState.Cache)\Deploy-Application.exe"
$outputFolder = $env:TEMP

$processOptions = @{
    FilePath = $outFile
    ArgumentList  = "-c ""$setupFolder"" -s ""$setupFile"" -o ""$outputFolder"" -q"
    WindowStyle = "Maximized"
    Wait = $true
}
Start-Process @processOptions

# Rename and prepare for upload
Move-Item -Path "$env:TEMP\Deploy-Application.intunewin" -Destination "$($scriptState.IntuneAppsFolder)\$Application.intunewin" -Force -Verbose
explorer $scriptState.IntuneAppsFolder
