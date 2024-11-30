#Requires -RunAsAdministrator

$User = "Bert" # CHANGEME; Your username
$Targets = @( # CHANGEME; Your paths that contain your library files on other disks or partitions (aka not on C: drive)
    "F:\User Data\Documents"
    "F:\User Data\Git"
    "F:\User Data\Music"
    "F:\User Data\Pictures"
    "F:\User Data\Video's"
)

# The username must be resolved at the local computer scope. AKA to setup the user in an ACL rule we have to transform
# the username reference to "<computername>\<username>"" eg mycomputer\myuser
$ComputerName = (Get-CimInstance -ClassName Win32_ComputerSystem).Name

# Set Access Control List (ACL) rules on the library folders provided above.
#
# Updating the ACL data is necessary because, after a new Windows install, the folders still point to the user account from the previous Windows installation.
# The ACL data contains a global unique identifier (GUID) that is unique for every (local) user account. A new windows installation, followed by creating a new local user,
# creates a new GUID for that user which isn't the same as the one stored in the ACL data. The old one must be replaced with the new one!
$NewACL = New-Object System.Security.AccessControl.DirectorySecurity
$NewACL.SetAccessRuleProtection($true, $false) # Disable inheritance
$NewACL.SetOwner([System.Security.Principal.NTAccount]"$ComputerName\$User")

# WARN; This is powershell so don't try to do anything clever because this shit is full of footguns
$Inheritance = ([System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit)
@(
    (New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList "NT AUTHORITY\SYSTEM", "FullControl", $Inheritance, 0, "Allow")
    (New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList "BUILTIN\Administrators", "FullControl", $Inheritance, 0, "Allow")
    (New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList "$ComputerName\$User", "FullControl", $Inheritance, 0, "Allow")
) | Foreach-Object {$NewACL.AddAccessRule($_)}

$Targets | Foreach-Object {Set-ACL -Path $_ -AclObject $NewACL}

# NOTE; Inheritance is expected to take over for all sub-items, but this will not update the OWNER!
$SubDirACL = New-Object System.Security.AccessControl.DirectorySecurity
$SubDirACL.SetAccessRuleProtection($false, $true) # ENABLE inheritance
$SubDirACL.SetOwner([System.Security.Principal.NTAccount]"$ComputerName\$User")

$Targets | `
    <# Force on Get-ChildItem will also return hidden files #>
    Foreach-Object {Get-ChildItem -Path $_ -Recurse -Directory -Force} | `
    Foreach-Object {Set-ACL -Path $_.FullName -AclObject $SubDirACL}

# Set Access Control List (ACL) rules on the Public Desktop (aka the desktop shared between all users)
# so all users can delete files from that folder.
# This is useful to remove "Shortcuts for all users" when your user is not an administrator.
$PublicDesktopACL = Get-Acl -Path "C:\Users\Public\Desktop"
$FilesOnlyInherit = [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
$AllowInteractiveDeleteRule = New-Object System.Security.AccessControl.FileSystemAccessRule -ArgumentList "INTERACTIVE", "Delete", $FilesOnlyInherit, 0, "Allow"
$PublicDesktopACL.AddAccessRule($AllowInteractiveDeleteRule)
Set-Acl -Path "C:\Users\Public\Desktop" -AclObject $PublicDesktopACL

