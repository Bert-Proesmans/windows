param (
    [string]$action = ""
)

function Enable-RDP {
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Proesmans" -Name "SkipRDPClearOnBoot" -Value $true -ErrorAction Stop

    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0 -ErrorAction Stop
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction Stop
    Write-Host "Enabled RDP"
}

function Disable-RDP {
    $flag = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Proesmans" -Name "SkipRDPClearOnBoot" -ErrorAction SilentlyContinue
    if ($flag) {
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Proesmans" -Name "SkipRDPClearOnBoot"
        Write-Host "RDP was not disabled because skip-flag is set"
        return
    }

    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 1 -ErrorAction Stop
    Disable-NetFirewallRule -DisplayGroup "Remote Desktop" -ErrorAction Stop
    Stop-Service -Name "TermService" -ErrorAction Stop
    Write-Host "Disabled RDP"
}

$scriptBlock = {
    if ($action -eq "enable") {
        Enable-RDP
        # I tried messing around with service restarts and right order of resource garbage collection but couldn't get RDP to consistently
        # work within the same boot session..
        Restart-Computer -Force
    }
    elseif ($action -eq "disable") {
        Disable-RDP
    }
    else {
        Write-Output "Usage: enable | disable"
    }
}

$logName = "Application"
$source = "RDPControlScript"

if (-not [System.Diagnostics.EventLog]::SourceExists($source)) {
    New-EventLog -LogName $logName -Source $source
}

if (-not (Test-Path "HKLM:\SOFTWARE\Proesmans")) {
    New-Item -Path "HKLM:\SOFTWARE\Proesmans" -Force | Out-Null
}

# capture output and errors together
$combinedOutput = ""
try {
    $result = & $scriptBlock *>&1
    $combinedOutput = $result | Out-String
}
catch {
    $combinedOutput += "`n[Terminating Error] " + $_.Exception.Message
}

# log result
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$message = "Timestamp: $timestamp`n$combinedOutput"

Write-EventLog -LogName $logName -Source $source -EventId 1003 -EntryType Information -Message $message