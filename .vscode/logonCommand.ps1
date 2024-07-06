# Configure the sandbox environment to better match a prod PC
$appName = "Deploy-Application.exe"

# Create the default Intune log folder
$intuneLogFolder = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs"
New-Item -Path $intuneLogFolder -ItemType Directory 

# Create a desktop shortcut for 
Write-Host "Creating a desktop shortcut for the Intune Logs folder" -ForegroundColor Green
$desktopFolder = "C:\Users\WDAGUtilityAccount\Desktop"
$shortcutPath = "C:\Users\Public\Desktop\IntuneLogs.lnk"
$targetPath = $intuneLogFolder

$WScriptObj = New-Object -ComObject WScript.Shell
$shortcut = $WscriptObj.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $targetPath
$shortcut.Save()

$intuneAppPath = "{0}\{1}\{2}" -f $desktopFolder, "devops", $appName

Write-host "Testing has started..." -ForegroundColor Cyan
Start-Process -FilePath $intuneAppPath -Wait
Write-host "Installation completed" -ForegroundColor DarkGreen
Write-host "you have 60 seconds to verify the installation before it is automatically uninstalled" -ForegroundColor Cyan

$Seconds = 60
$EndTime = [datetime]::UtcNow.AddSeconds($Seconds)

while (($TimeRemaining = ($EndTime - [datetime]::UtcNow)) -gt 0) {
  Write-Progress -Activity 'Waiting for...' -Status testing -SecondsRemaining $TimeRemaining.TotalSeconds
  Start-Sleep 1
}

Start-Process -FilePath $intuneAppPath -ArgumentList "Uninstall" -Wait
Write-host "test completed" -ForegroundColor DarkGreen
Write-host "You can close sandbox now!" -ForegroundColor Cyan
Read-Host -Prompt "Press any key to continue..."
