#Requires -RunAsAdministrator

$User = "B-PC\Bert"
$Targets = @(
    "Network Configuration Operators"
    "Hyper-V Administrators"
)

$Targets | `
    Foreach-Object { & net localgroup "$_" "$User" /add }
