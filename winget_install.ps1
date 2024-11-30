# This script DOES NOT REQUIRE a functional windows app store as precondition!
#
# Winget can fully replace the windows store app as another (CLI) frontend, but the UI could be useful.
# If there is no store app (in IoT releases for example) or it's broken, run reset_windows_appstore.ps1 first!

$processUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$sessionUser = (Get-WmiObject -Query 'SELECT UserName FROM Win32_ComputerSystem').UserName

if (<# Session could be empty/null in sandbox #> `
    ($null -ne $sessionUser) `
    -and ($processUser -ne $sessionUser) `
) {
    Write-Host ("**WARNING*; The user owning the current process is _NOT_ the logon session user." +
    " This discrepancy will cause WinRT to not work! Specifically updating of windows store applications will fail." +
    " No administrator permissions are required to update the winget package. Run this program again as the user owning the current desktop session." +
    " But administrator permissions are required to install and reset the winget package index cache. In that case make the user owning" +
    " the desktop session a temporary administrator and run this script again.")
    Write-Host "Press enter to continue..."
    Read-Host
}

<#
.SYNOPSIS
    On Windows 11 I expect winget to be already installed. If not, install directly from the released packages.
#>
$hasPackageManager = Get-AppPackage -name 'Microsoft.DesktopAppInstaller'
if (!$hasPackageManager -or [version]$hasPackageManager.Version -lt [version]'1.10.0.0') {
    try {
        # We need a temporary directory to handle all winget dependencies at once and license install
        $tempDir = Join-Path $([System.IO.Path]::GetTempPath()) 'winget_install'

        if (Test-Path -Path $tempDir) {
            $response = Read-Host "The temporary directory already exists. Do you want to remove it? (y/N)"
            if ($response -eq "Y" -or $response -eq "y") {
                Write-Host 'Cleaning existing temporary directory'
                Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            } else {
                Write-Host "Keeping the temporary directory. Existing contents may affect the script."
            }
        }
        
        if (-not (Test-Path -Path $tempDir)) {
            Write-Host 'Creating temporary directory'
            New-Item -ItemType Directory -Path $tempDir | Out-Null
        }

        Write-Host 'Downloading resources'
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $releases = Invoke-RestMethod -uri 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'

        $MSIXLatest = Join-Path $tempDir 'winget.msixbundle'
        if (-not (Test-Path -Path $MSIXLatest)) {
            Invoke-WebRequest -OutFile $MSIXLatest -Uri $($releases.assets | Where { $_.browser_download_url.EndsWith('.msixbundle') } | Select -First 1 -ExpandProperty browser_download_url)
        }
        $licenseLatest = Join-Path $tempDir 'license.xml'
        if (-not (Test-Path -Path $licenseLatest)) {
            Invoke-WebRequest -OutFile $licenseLatest -Uri $($releases.assets | Where { $_.browser_download_url.EndsWith('License1.xml') } | Select -First 1 -ExpandProperty browser_download_url)
        }
        $dependenciesLatest = Join-Path $tempDir 'dependencies.zip'
        if (-not (Test-Path -Path $dependenciesLatest)) {
            Invoke-WebRequest -OutFile $dependenciesLatest -Uri $($releases.assets | Where { $_.browser_download_url.EndsWith('Dependencies.zip') } | Select -First 1 -ExpandProperty browser_download_url)
        }

        Write-Host 'Installing winget Dependencies'
        Expand-Archive -Path $dependenciesLatest -DestinationPath $tempDir -Force
        $dependenciesUnpacked = Join-Path $tempDir 'x64' # WARN; Subdirectory for architecture!
        Get-ChildItem -Path $dependenciesUnpacked -Filter *.appx | Select -ExpandProperty FullName | Add-AppxPackage


        Write-Host 'Installing winget'
        Add-AppxPackage -Path $MSIXLatest

        Write-Host 'Installing winget license'
        Add-AppxProvisionedPackage -Online -PackagePath $MSIXLatest -LicensePath $licenseLatest

        Write-Host 'Finished installing winget'
    }
    catch {
        Write-Error "Problem installing winget package: $_"
        Write-Error 'Exiting..'
        exit 1
    }
}
else {
    Write-Host 'winget already installed'
}

<#
.SYNOPSIS
    Synchronously triggers store updates for a select set of apps. You should run this in
    legacy powershell.exe, as some of the code has problems in pwsh on older OS releases.

    REF; https://github.com/microsoft/winget-cli/discussions/1738#discussioncomment-5484927
#>
try
{
    if ($PSVersionTable.PSVersion.Major -ne 5)
    {
        throw 'This script has problems in pwsh on some platforms; please run it with legacy Windows PowerShell (5.1) (powershell.exe).'
    }

    if (<# Session could be empty/null in sandbox #> `
        ($null -ne $sessionUser) `
        -and ($processUser -ne $sessionUser) `
    )
    {
        # This exception will be caught below to skip updating the windows store application. This is intentional.
        throw 'Due to WinRT limitations, this script must run as the same user that created this logon session; please run this script as the user owning the current desktop session.'
    }

    # https://fleexlab.blogspot.com/2018/02/using-winrts-iasyncoperation-in.html
    Add-Type -AssemblyName System.Runtime.WindowsRuntime
    $asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
    function Await($WinRtTask, $ResultType) {
        $asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
        $netTask = $asTask.Invoke($null, @($WinRtTask))
        $netTask.Wait(-1) | Out-Null
        $netTask.Result
    }

    # https://docs.microsoft.com/uwp/api/windows.applicationmodel.store.preview.installcontrol.appinstallmanager?view=winrt-22000
    # We need to tell PowerShell about this WinRT API before we can call it...
    Write-Host 'Enabling Windows.ApplicationModel.Store.Preview.InstallControl.AppInstallManager WinRT type'
    [Windows.ApplicationModel.Store.Preview.InstallControl.AppInstallManager,Windows.ApplicationModel.Store.Preview,ContentType=WindowsRuntime] | Out-Null
    $appManager = New-Object -TypeName Windows.ApplicationModel.Store.Preview.InstallControl.AppInstallManager

    # Customize this list of apps to suit... the key one for making sure that winget.exe is
    # installed is the DesktopAppInstaller one.
    $appsToUpdate = @(
        'Microsoft.WindowsStore_8wekyb3d8bbwe',
        'Microsoft.DesktopAppInstaller_8wekyb3d8bbwe'  # <-- winget comes from this one
    )

    foreach ($app in $appsToUpdate)
    {
        try
        {
            Write-Host "Requesting an update for $app..."
            $updateOp = $appManager.UpdateAppByPackageFamilyNameAsync($app)
            $updateResult = Await $updateOp ([Windows.ApplicationModel.Store.Preview.InstallControl.AppInstallItem])
            while ($true)
            {
                if ($null -eq $updateResult)
                {
                    Write-Host 'Update is null. It must already be completed (or there was no update)...'
                    break
                }

                if ($null -eq $updateResult.GetCurrentStatus())
                {
                    Write-Host 'Current status is null. WAT'
                    break
                }

                Write-Host $updateResult.GetCurrentStatus().PercentComplete
                if ($updateResult.GetCurrentStatus().PercentComplete -eq 100)
                {
                    Write-Host "Install completed ($app)"
                    break
                }
                Start-Sleep -Seconds 3
            }
        }
        catch [System.AggregateException]
        {
            # If the thing is not installed, we can't update it. In this case, we get an
            # ArgumentException with the message "Value does not fall within the expected
            # range." I cannot figure out why *that* is the error in the case of "app is
            # not installed"... perhaps we could be doing something different/better, but
            # I'm happy to just let this slide for now.
            $problem = $_.Exception.InnerException # we'll just take the first one
            Write-Host "Error updating app $app : $problem"
            Write-Host '(this is expected if the app is not installed; you can probably ignore this)'
        }
        catch
        {
            Write-Host "Unexpected error updating app $app : $_"
        }
    }

    Write-Host 'Store updates completed'
}
catch
{
    Write-Error "Problem updating store apps: $_"
    Write-Error 'Exiting..'
    exit 1
}

<#
.SYNOPSIS
    Ensure the winget package is available in our user session.
    This contains (recursively) applying proper permissions to the (shared) package cache, linking package matrix, and making binaries available on PATH.
#>
if (!(Get-Command 'winget' -ErrorAction SilentlyContinue)) {
    Write-Output 'winget is not on the PATH. Forcing synchronous package install.'
    # Synchronously wait for the windows app store to finish preparation of this package for the current user
    Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe

    if (!(Get-Command 'winget' -ErrorAction SilentlyContinue)) {
        Write-Error 'Adding winget to the PATH failed. This requires a manual fix. Exiting..'
        exit 1
    }
}

<#
.SYNOPSIS
    Ensure winget has available and valid package index data
#>
winget.exe source reset --force
winget.exe source update
# Synchronously wait for the windows app store to process the sources update
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.Winget.Source_8wekyb3d8bbwe
