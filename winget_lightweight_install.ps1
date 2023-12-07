# This could be run as an admin user that has not been logged in yet
if (!(Get-Command "winget" -ErrorAction SilentlyContinue)) {
    Write-Output "winget is not on the PATH. Forcing synchronous package install..."
    # Synchronously push the windows store to work for us!
    Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe

    if (!(Get-Command "winget" -ErrorAction SilentlyContinue)) {
        Write-Host "Adding winget to the PATH failed. This requires a manual fix. Exiting"
        exit 1
    }
}

# Proactively reset winget sources to not hang onto outdated, invalid caches
winget.exe source reset --force
winget.exe source update
# Synchronously push the windows store to work for us
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.Winget.Source_8wekyb3d8bbwe

@(
    "7zip.7zip"
    "Adobe.Acrobat.Reader.64-bit"
    "BelgianGovernment.Belgium-eIDmiddleware"
    "Google.Chrome"
    "Google.GoogleDrive"
    "IrfanSkiljan.IrfanView"
    "Mozilla.Firefox"
    "VideoLAN.VLC"
) | ForEach-Object { winget.exe install --accept-source-agreements --accept-package-agreements --source winget --exact --id $_ }

# Configure winget auto-updater
$programPath = [Environment]::GetFolderPath("COMMONAPPLICATIONDATA") + "\Winget-AutoUpdate-data"
if (!(Test-Path $programPath)) {
    New-Item -Path $programPath -ItemType Directory -Force | Out-Null
}
# Cannot store file within WingetAutoUpdate programdata folder, the folder contents are overwritten during install
$programWhitelist = $programPath + "\included_apps.txt"
Copy-Item -Path .\wau_lightweight_whitelist.txt -Destination $programWhitelist

$registryPath = "HKLM:\Software\Policies\Romanitho\Winget-AutoUpdate"
if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Winget AutoUpdater GPO keys
$data = @{
    "WAU_ActivateGPOManagement" = 1
    "WAU_DisableAutoUpdate" = 0
    "WAU_UseWhiteList" = 1
    # MUST BE a folder path!
    "WAU_ListPath" = $programPath
    "WAU_UpdatesInterval" = "Daily"
    "WAU_StartMenuShortcut" = 1
    "WAU_DesktopShortcut" = 0
}
$data.Keys | ForEach-Object {
    Set-ItemProperty -Path $registryPath -Name $_ -Value $data[$_]
}

# Install Winget Auto Update
$url = Invoke-RestMethod -Uri "https://api.github.com/repos/Romanitho/Winget-AutoUpdate/releases/latest" | `
    Select-Object -ExpandProperty assets | `
    Where-Object {"WAU.zip" -eq $_.name} | `
    Select-Object -ExpandProperty browser_download_url

$downloadPath = $env:TEMP + "\WAU.zip"
Invoke-WebRequest -Uri $url -OutFile $downloadPath -Force
$unzippedPath = $env:TEMP + "\WAU"
Expand-Archive -Path $downloadPath -DestinationPath $unzippedPath -Force
Start-Process -Wait -FilePath ($unzippedPath + "\install.bat")
