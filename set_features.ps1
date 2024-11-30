#Requires -RunAsAdministrator

try {
    Enable-WindowsOptionalFeature -FeatureName 'Microsoft-Hyper-V' -All -Online
    Enable-WindowsOptionalFeature -FeatureName 'Containers-DisposableClientVM' -All -Online
} catch {
    Write-Error "Problem enabling optional features: $_"
    Write-Error 'Exiting..'
    exit 1
}

Write-Host "Optional features enabled, you should restart the computer"
