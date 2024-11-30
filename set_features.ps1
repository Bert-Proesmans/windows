#Requires -RunAsAdministrator

try {
    Enable-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Hyper-V' -All
    Enable-WindowsOptionalFeature -Online -FeatureName 'Containers-DisposableClientVM'
} catch {
    Write-Error "Problem enabling optional features: $_"
    Write-Error 'Exiting..'
    exit 1
}

Write-Host "Optional features enabled, you should restart the computer"
