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
    "Almico.SpeedFan"
    "Audacity.Audacity"
    "BelgianGovernment.Belgium-eIDmiddleware"
    "BotProductions.IconViewer"
    "CodeSector.TeraCopy"
    "CPUID.CPU-Z"
    "CPUID.HWMonitor"
    "CrystalDewWorld.CrystalDiskInfo"
    # "flux.flux" # User install, breaks install from another user but works on update
    # "Fork.Fork" # User install, breaks install from another user but works on update
    "Google.GoogleDrive"
    "gurnec.HashCheckShellExtension"
    # "Gyan.FFmpeg" # User install, breaks install from another user but works on update
    "IrfanSkiljan.IrfanView"
    "MHNexus.HxD"
    "Microsoft.OpenJDK.17"
    # "Mikrotik.Winbox" # User install, breaks install from another user but works on update
    "Mozilla.Firefox"
    "OBSProject.OBSStudio"
    "Python.Python.3.8"
    "qBittorrent.qBittorrent"
    "RamenSoftware.Windhawk"
    # "Rustlang.Rustup" # User install, breaks install from another user but works on update
    # "SumatraPDF.SumatraPDF" # User install, breaks install from another user but works on update
    "tailscale.tailscale"
    "UderzoSoftware.SpaceSniffer"
    "Valve.Steam"
    "VideoLAN.VLC"
    "WiresharkFoundation.Wireshark"
    "Yubico.YubikeyManager"
) | ForEach-Object { winget.exe install --accept-source-agreements --accept-package-agreements --source winget --exact --id $_ }

# This software MUST be executed as the user that is going to run it.
# Using a separate administrator user to install it will not make the software available to all users!
@(
    "flux.flux" 
    "Fork.Fork" 
    "Gyan.FFmpeg"
    "Mikrotik.Winbox"
    "Rustlang.Rustup"
    "SumatraPDF.SumatraPDF"
) | ForEach-Object { winget.exe install --accept-source-agreements --accept-package-agreements --source winget --exact --id $_ }

# Git needs to be installed manually because it doesn't want to elevate itself.
# Git used to be simple man, now the installer alone is already a pain in the ass.
# What the fuck is a git-credential-manager? We only do private key auth in this house!
# Git.Git --override '/DIR="C:\Program Files\Git" /ALLUSERS /COMPONENTS="gitlfs,scalar"'

# Custom install for VSCode
winget.exe install --source winget --scope machine --exact --id Microsoft.VisualStudioCode `
    --override '/verysilent /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"'

@(
    "9NBLGGH516XP" # Eartrumpet
    "9P7KNL5RWT25" # Sysinternal
    "9PLJWWSV01LK" # TwinkleTray
) | ForEach-Object { winget.exe install --accept-source-agreements --accept-package-agreements --source msstore --exact --id $_ }

# Install rust pre-requisites
winget.exe install --source winget --exact --id Microsoft.VisualStudio.2022.Community `
    --override "--add Microsoft.VisualStudio.Workload.NativeDesktop;includeRecommended --focusedUi --wait"

# Configure winget auto-updater
$programPath = [Environment]::GetFolderPath("COMMONAPPLICATIONDATA") + "\Winget-AutoUpdate-data"
if (!(Test-Path $programPath)) {
    New-Item -Path $programPath -ItemType Directory -Force | Out-Null
}
# Cannot store file within WingetAutoUpdate programdata folder, the folder contents are overwritten during install
$programWhitelist = $programPath + "\included_apps.txt"
Copy-Item -Path .\wau_whitelist.txt -Destination $programWhitelist

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
