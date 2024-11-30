# It's recommended to run this script as the target everyday user account, but give that account
# temporary administrator permissions.

$applications = @(
    @{ Name = "7zip.7zip"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "9N0DX20HK701"; AutoUpdate = $true; Source = "msstore"; }, # Windows Terminal
    @{ Name = "9NBLGGH516XP"; AutoUpdate = $true; Source = "msstore"; }, # Eartrumpet
    @{ Name = "9P7KNL5RWT25"; AutoUpdate = $true; Source = "msstore"; }, # Sysinternal (zoomit)
    @{ Name = "9PLJWWSV01LK"; AutoUpdate = $true; Source = "msstore"; }, # TwinkleTray
    @{ Name = "Almico.SpeedFan"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "Audacity.Audacity"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "BelgianGovernment.Belgium-eIDmiddleware"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "BelgianGovernment.eIDViewer"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "BotProductions.IconViewer"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "CodeSector.TeraCopy"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "CPUID.CPU-Z"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "CPUID.HWMonitor"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "CrystalDewWorld.CrystalDiskInfo"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "flux.flux" ; AutoUpdate = $true; Source = "winget"; IsUserApp = $true; },
    @{ Name = "Fork.Fork" ; AutoUpdate = $false; Source = "winget"; IsUserApp = $true; },
    @{ Name = "Git.Git"; AutoUpdate = $true; Source = "winget"; }
    @{ Name = "Google.GoogleDrive"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "gurnec.HashCheckShellExtension"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "Gyan.FFmpeg"; AutoUpdate = $true; Source = "winget"; IsUserApp = $true; },
    @{ Name = "IrfanSkiljan.IrfanView"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "MHNexus.HxD"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "Microsoft.OpenJDK.17"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "Microsoft.OpenSSH.Beta"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "Microsoft.VisualStudio.2022.Community"; AutoUpdate = $false; Source = "custom"; },
    @{ Name = "Microsoft.VisualStudioCode"; AutoUpdate = $true; Source = "custom"; }
    @{ Name = "Mikrotik.Winbox"; AutoUpdate = $true; Source = "winget"; IsUserApp = $true; },
    @{ Name = "Mozilla.Firefox"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "OBSProject.OBSStudio"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "Python.Python.3.12"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "qBittorrent.qBittorrent"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "RamenSoftware.Windhawk"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "Romanitho.Winget-AutoUpdate"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "Rustlang.Rustup"; AutoUpdate = $true; Source = "winget"; IsUserApp = $true; },
    @{ Name = "SumatraPDF.SumatraPDF"; AutoUpdate = $true; Source = "winget"; IsUserApp = $true; },
    @{ Name = "tailscale.tailscale"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "UderzoSoftware.SpaceSniffer"; AutoUpdate = $true; Source = "winget"; IsUserApp = $true; },
    @{ Name = "Valve.Steam"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "VideoLAN.VLC"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "WiresharkFoundation.Wireshark"; AutoUpdate = $true; Source = "winget"; },
    @{ Name = "Yubico.YubikeyManager"; AutoUpdate = $true; Source = "winget"; }
    # ERROR; Last record should not end with a comma!
) | ForEach-Object { [PSCustomObject]$_ } # Required because the default initializer is HashTable and I want PSCustomObjects

if (!(Get-Command "winget" -ErrorAction SilentlyContinue)) {
    Write-Output "winget is not on the PATH. Run the script winget_install.ps1 first ! Exiting.."
    exit 1
}

Write-Host '== Configuring WAU =='
$registryPath = "HKLM:\Software\Policies\Romanitho\Winget-AutoUpdate"
if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# WARN; AppData is write+delete protected! Only the owner/creator and administrators can update files.
# This allows the process user that did the installation with admin permissions to, later when permissions are
# dropped, update this list without additional blockers.
# Non-elevated users cannot install software, so there is no security risk. This is a feature!
$wauStatePath = Join-Path $([Environment]::GetFolderPath('CommonApplicationData')) 'WAU_data'
$wauAppWhitelistPath = Join-Path $wauStatePath 'app_whitelist.txt'

if(-not (Test-Path -Path $wauStatePath)) {
    Write-Host "Creating folder for Winget Auto Updater configuration"
    New-Item -ItemType Directory -Path $wauStatePath | Out-Null
}

# Winget AutoUpdater GPO keys
# REF; https://github.com/Romanitho/Winget-AutoUpdate/blob/main/Sources/Policies/ADMX/WAU.admx
$data = @{
    "WAU_ActivateGPOManagement" = 1
    "WAU_DisableAutoUpdate" = 0
    "WAU_UseWhiteList" = 1
    # MUST BE a folder path!
    "WAU_ListPath" = $wauAppWhitelistPath
    "WAU_UpdatesInterval" = "Daily"
    "WAU_StartMenuShortcut" = 1
    "WAU_DesktopShortcut" = 0
}
$data.Keys | ForEach-Object {
    Set-ItemProperty -Path $registryPath -Name $_ -Value $data[$_]
}

Write-Host '== Writing out application whitelist =='
$applications `
| Where-Object { $_.AutoUpdate -eq $true } `
| Select-Object -Expand Name `
<# Automatically clear the file and write all data at once #> `
| Out-File -FilePath $wauAppWhitelistPath -Encoding utf8

Write-Host '== Running system-context installers =='
$applications `
| Where-Object { ($_.Source -eq "winget") -and ($_.IsUserApp -ne $true) } `
| ForEach-Object { Write-Host $_.Name; winget.exe install --accept-source-agreements --accept-package-agreements --source winget --exact --id $_.Name }

Write-Host '== Custom install for VSCode =='
winget.exe install --accept-source-agreements --accept-package-agreements --source winget --scope machine --exact --id 'Microsoft.VisualStudioCode' `
    --override '/verysilent /mergetasks="!runcode,addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"'

Write-Host '== Custom install for Visual Studio (rust dependency) =='
winget.exe install --accept-source-agreements --accept-package-agreements --source winget --exact --id 'Microsoft.VisualStudio.2022.Community' `
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
Write-Host '== Running user-context installers =='
$applications `
| Where-Object { ($_.Source -eq "winget") -and ($_.IsUserApp -eq $true) } `
| ForEach-Object { Write-Host $_.Name; winget.exe install --accept-source-agreements --accept-package-agreements --source winget --exact --id $_.Name }

Write-Host '== Installing applications from Windows app store =='
$applications `
| Where-Object { $_.Source -eq "msstore" } `
| ForEach-Object { Write-Host $_.Name; winget.exe install --accept-source-agreements --accept-package-agreements --source msstore --exact --id $_.Name }
