#Requires -RunAsAdministrator

# This script requires a functional windows app store as precondition!
#
# If there is no store (IoT release) or it's broken, run reset_windows_appstore.ps1 first!

# == First ensure winget is installed and updated to the latest version ==

if (!(Get-Command "winget" -ErrorAction SilentlyContinue)) {
    Write-Output "winget is not on the PATH. Forcing synchronous package install..."
    # Synchronously wait for the windows app store to install the package
    Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe

    if (!(Get-Command "winget" -ErrorAction SilentlyContinue)) {
        Write-Host "Adding winget to the PATH failed. This requires a manual fix. Exiting"
        exit 1
    }
}

# == Second Forcing update of all windows store apps ==

Write-Output "Forcing scan + update of all windows store apps (including winget)"
Get-CimInstance -Namespace "root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | Invoke-CimMethod -MethodName "UpdateScanMethod" 

# == Third ensure winget has proper package index sources ==

winget.exe source reset --force
winget.exe source update
# Synchronously wait for the windows app store to process the sources update
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.Winget.Source_8wekyb3d8bbwe
