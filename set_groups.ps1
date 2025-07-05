#Requires -RunAsAdministrator

$User = "Bert" # CHANGEME; Your username
$Targets = @( # CHANGEME; The (admin) groups you want to be a part of (see windows documentation)
    # REF; https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/understand-security-groups#default-active-directory-security-groups
    
    "Network Configuration Operators" # Allows the user to reconfigure network settings on network adapters (but not enable/disable them)
    
    "Hyper-V Administrators" # Allows the user to manage virtual machines and virtual networks, also manage virtual machine state

    "Remote Desktop Users" # Allows the user to connect over Windows Remote Desktop (requires separate activation)
)

# The username must be resolved at the local computer scope. AKA to setup the user in an ACL rule we have to transform
# the username reference to "<computername>\<username>"" eg mycomputer\myuser
$ComputerName = (Get-CimInstance -ClassName Win32_ComputerSystem).Name

$Targets | `
    Foreach-Object { & net localgroup "$_" "$ComputerName\$User" /add }
