# This script requires winget as a precondition!

# == First ensure winget is installed and updated to the latest version ==

if (!(Get-Command "winget" -ErrorAction SilentlyContinue)) {
    Write-Output "winget is not on the PATH. Run the script winget_install.ps1 ! Exiting.."
    exit 1
}

# TODO - Include package and if it should be updated into a single table
# TODO - Autogenerate the app update whitelist based on the table

# Configure WAU and install
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

# TODO - Update WAU install. They fixed the whitelist overwrite


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
    "Google.GoogleDrive"
    "gurnec.HashCheckShellExtension"
    "IrfanSkiljan.IrfanView"
    "MHNexus.HxD"
    "Microsoft.OpenJDK.17"
    "Microsoft.OpenSSH.Beta"
    "Mozilla.Firefox"
    "OBSProject.OBSStudio"
    "Python.Python.3.8"
    "qBittorrent.qBittorrent"
    "RamenSoftware.Windhawk"
    "tailscale.tailscale"
    "Valve.Steam"
    "VideoLAN.VLC"
    "WiresharkFoundation.Wireshark"
    "Yubico.YubikeyManager"
) | ForEach-Object { winget.exe install --accept-source-agreements --accept-package-agreements --source winget --exact --id $_ }

# Git needs to be installed manually because it doesn't want to elevate itself.
# Git.Git --override '/DIR="C:\Program Files\Git" /ALLUSERS /COMPONENTS="gitlfs,scalar"'

# Custom install for VSCode
winget.exe install --source winget --scope machine --exact --id Microsoft.VisualStudioCode `
    --override '/verysilent /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"'

# Install rust pre-requisites
winget.exe install --source winget --exact --id Microsoft.VisualStudio.2022.Community `
    --override "--add Microsoft.VisualStudio.Workload.NativeDesktop;includeRecommended --focusedUi --wait"

#
$processUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$sessionUser = (Get-WmiObject -Query "SELECT UserName FROM Win32_ComputerSystem").UserName
if ($processUser -ne $sessionUser) 
{
    Write-Host ("**WARNING*; The user owning the current process is _NOT_ the logon session user." +
    " This discrepancy will cause confusion as the next software will be installed in USER CONTEXT, which is the context of the process user!" +
    " The process user is relevant for both user-installs of software and windows store applications.")
    Write-Host "Press enter to continue..."
    Read-Host
}

# This software MUST be executed as the user that is going to run it.
# Using a separate administrator user to install it will not make the software available to all users!
@(
    "flux.flux" 
    "Fork.Fork" 
    "Gyan.FFmpeg"
    "Hashicorp.Vault"
    "Mikrotik.Winbox"
    "Rustlang.Rustup"
    "SumatraPDF.SumatraPDF"
    "UderzoSoftware.SpaceSniffer"
) | ForEach-Object { winget.exe install --accept-source-agreements --accept-package-agreements --source winget --exact --id $_ }

@(
    "9NBLGGH516XP" # Eartrumpet
    "9P7KNL5RWT25" # Sysinternal (zoomit)
    "9PLJWWSV01LK" # TwinkleTray
) | ForEach-Object { winget.exe install --accept-source-agreements --accept-package-agreements --source msstore --exact --id $_ }
