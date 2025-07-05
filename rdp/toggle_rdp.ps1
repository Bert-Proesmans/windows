param (
    [string]$action = ""
)

function Enable-RDP {
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
}

function Disable-RDP {
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 1
    Disable-NetFirewallRule -DisplayGroup "Remote Desktop"
}

if ($action -eq "enable") {
    Enable-RDP
}
elseif ($action -eq "disable") {
    Disable-RDP
}
else {
    Write-Output "Usage: enable | disable"
}
