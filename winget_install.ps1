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
    "flux.flux"
    "Fork.Fork"
    "Google.GoogleDrive"
    "gurnec.HashCheckShellExtension"
    "Gyan.FFmpeg"
    "IrfanSkiljan.IrfanView"
    "MHNexus.HxD"
    "Microsoft.OpenJDK.17"
    "Mikrotik.Winbox"
    "Mozilla.Firefox"
    "OBSProject.OBSStudio"
    "Python.Python.3.8"
    "qBittorrent.qBittorrent"
    "RamenSoftware.Windhawk"
    "Romanitho.WiGUI"
    "Rustlang.Rustup"
    "SumatraPDF.SumatraPDF"
    "tailscale.tailscale"
    "UderzoSoftware.SpaceSniffer"
    "Valve.Steam"
    "VideoLAN.VLC"
    "WiresharkFoundation.Wireshark"
    "Yubico.YubikeyManager"
) | ForEach-Object { winget.exe install --source winget --exact --id $_ }

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
) | ForEach-Object { winget.exe install --source msstore --accept-source-agreements --accept-package-agreements --exact --id $_ }

# Install rust pre-requisites
winget.exe install --source winget --exact --id Microsoft.VisualStudio.2022.Community `
    --override "--add Microsoft.VisualStudio.Workload.NativeDesktop;includeRecommended --focusedUi --wait"

# Install winget package auto-updater
# Whitelist is stored at "C:\ProgramData\Winget-AutoUpdate\included_apps.txt"
& (Get-Item "$($env:LOCALAPPDATA)/Microsoft/WinGet/Packages/Romanitho.WiGUI*/WiGui.exe")
