# Windows
> Currently at Windows 11

Repository with automation to get productive ASAP on Windows.

## Windows install

Manual steps.

1. Create installer with Rufus
    1. Automatically create local admin account
    1. Bypass TPM requirement
1. Unplug network
1. Launch installer
1. Give entire SSD to install, let it rip
1. Get into the system
1. Set password for local admin account
1. Create new basic user account for everyday use
1. Logon to new basic user
1. Relocate user libraries to other persisted disk
1. Plug network in
1. Proceed to install and configure

## Contents

| Filename | Description |
| --- | --- |
| set_acl.ps1 | Update the value of variable `$User` and the target paths. The script will update the access records residing on a seperate disk/partition for the user post-install a new system.
| winget_install.ps1 | Install software through winget to quickly get setup. The installers will elevate themselves. The script needs to run as the new user!
| wau_whitelist.txt | Whitelisted apps that automatically update through the WingetAutoAupdate tool.
