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
1. Create new admin user account for everyday use
1. Logon to new user
1. Relocate user libraries to other persisted disk
1. Run all scripts as necessary (see .ps1 scripts)
1. Plug network in
1. Proceed to install and configure
1. Take away admin rights for new user

## Contents

| Filename | Description |
| --- | --- |
| emergency.ps1 | Windows stuff, like edition switching activation, re-arming etc
| set_acl.ps1 | Update the value of variable `$User` and the target paths. The script will update the access records residing on a separate disk/partition for the user post-install a new system.
| set_groups.ps1 | Update the value of variable `$User` and the target groups. The script will add the user to each group. This is allows the non-administrator user to perform certain activities like Hyper-V VM management, and/or configure network settings.
| winget_install.ps1 | Install software through winget to quickly get setup. The installers will elevate themselves.<br/>The script needs to run as the current user, or as a separate administrator user with manual installs of the per-user programs (see script content).
| wau_whitelist.txt | Whitelisted apps that automatically update through the WingetAutoAupdate tool.
| \*lightweight\* | Smaller list of applications that have more broad usage. Useful for low-tech family members.
| firefox\*.css | Files to fix Firefox' UI to accommodate my tabs setup.

# Misc

## Noise suppression

* https://sourceforge.net/projects/equalizerapo/files/1.3/
* https://github.com/werman/noise-suppression-for-voice
