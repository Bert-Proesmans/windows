#Requires -RunAsAdministrator

$User = "B-PC\Bert"
$Targets = @(
    "F:\User Data\Documents"
    "F:\User Data\Git"
    "F:\User Data\Music"
    "F:\User Data\Pictures"
    "F:\User Data\Video's"
)

$NewACL = New-Object System.Security.AccessControl.DirectorySecurity
$NewACL.SetAccessRuleProtection($true, $false) # Disable inheritance
$NewACL.SetOwner([System.Security.Principal.NTAccount]$User)

# WARN; This is powershell so don't try to do anything clever because this shit is full of footguns
$Inheritance = ([System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit)
@(
    (New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList "NT AUTHORITY\SYSTEM", "FullControl", $Inheritance, 0, "Allow")
    (New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList "BUILTIN\Administrators", "FullControl", $Inheritance, 0, "Allow")
    (New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $User, "FullControl", $Inheritance, 0, "Allow")
) | Foreach-Object {$NewACL.AddAccessRule($_)}

$Targets | Foreach-Object {Set-ACL -Path $_ -AclObject $NewACL}

# NOTE; Inheritance is expected to take over for all sub-items, but this will not update the OWNER!
$SubDirACL = New-Object System.Security.AccessControl.DirectorySecurity
$SubDirACL.SetAccessRuleProtection($false, $true) # ENABLE inheritance
$SubDirACL.SetOwner([System.Security.Principal.NTAccount]$User)

$Targets | `
    Foreach-Object {Get-ChildItem -Path $_ -Recurse -Directory} | `
    Foreach-Object {Set-ACL -Path $_.FullName -AclObject $SubDirACL}
