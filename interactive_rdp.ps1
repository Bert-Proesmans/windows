$ScriptContainerPath = Join-Path $([Environment]::GetFolderPath('CommonApplicationData')) -ChildPath 'proesmans'
$ToggleScriptPath = $ScriptContainerPath | Join-Path -ChildPath 'toggle_rdp.ps1'

if(-not (Test-Path -Path $ScriptContainerPath)) {
    Write-Host 'Creating folder for Proesmans scripts'
    New-Item -ItemType Directory -Path $ScriptContainerPath | Out-Null
}

Copy-Item "$($PSScriptRoot)\rdp\toggle_rdp.ps1" "$ToggleScriptPath"

schtasks /create /tn 'EnableRDP' /xml "$($PSScriptRoot)\rdp\enable_rdp.xml" /ru SYSTEM
# Task runs automatically at boot to ensure rdp is always disabled by default!
schtasks /create /tn 'DisableRDP' /xml "$($PSScriptRoot)\rdp\disable_rdp.xml" /ru SYSTEM

# Make tasks readable/runnable for all users
$scheduler = New-Object -ComObject "Schedule.Service"
$scheduler.Connect()
{
    $task = $scheduler.GetFolder("\").GetTask("EnableRDP")
    $sec = $task.GetSecurityDescriptor(0xF)
    $sec = $sec + '(A;;GRGX;;;IU)' # Add interactive users group with read+execute permissions
    $task.SetSecurityDescriptor($sec, 0)
}
{
    $task = $scheduler.GetFolder("\").GetTask("DisableRDP")
    $sec = $task.GetSecurityDescriptor(0xF)
    $sec = $sec + '(A;;GRGX;;;IU)' # Add interactive users group with read+execute permissions
    $task.SetSecurityDescriptor($sec, 0)
}

# Create shortcut to enable RDP
$WshShell = New-Object -COMObject WScript.Shell
# You can find the shortcut through windows search;
# 1. Open start menu
# 2. Search "enable"
# 3. Run app "EnableRDP"
$Shortcut = $WshShell.CreateShortcut("$([Environment]::GetFolderPath('COMMONAPPLICATIONDATA'))\Microsoft\Windows\Start Menu\Programs\EnableRDP.lnk")
$Shortcut.TargetPath = '%SystemRoot%\System32\schtasks.exe'
$Shortcut.Arguments = '/run /tn "EnableRDP"'
$Shortcut.Save()

Write-Host "Start secpol.msc and remove the group `"Administrators`" from the policy at path Local Policies > User Rights Assignment : Allow log on through Remote Desktop Services"
# This is not recommended, but I like having my no-privilege account without a password. There are lots of software that want to run 
# with unlocked permissions and typing a password is annoying.
Write-Host "Start secpol.msc and disable login limitations on passwordless accounts in the policy at path Local Policies > Security Options : Accounts: Limit local account use of blank passwords to console logon only"