#Requires -RunAsAdministrator

# Disables hibernation, removing hiberfil.sys, freeing ~50% of RAM in disk space
POWERCFG /HIBERNATE OFF

Get-Service sshd | Set-Service -StartupType Disabled
Get-Service ssh-agent | Set-Service -StartupType Automatic
