$fqdn = ([System.Net.Dns]::GetHostByName($env:computerName)).hostname
$fdomain = $fqdn.Split(".", 2)[1]
$fdomain

$Password = ConvertTo-SecureString -AsPlainText "PASSWORD" -Force
$DomainUser = "$fdomain\wsadmin"
$DC = New-Object System.Management.Automation.PSCredential($DomainUser, $Password)

set-location "C:\Users\wsadmin\Desktop"

Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -NoProfile -File "C:\Users\wsadmin\Desktop\kerb-only.ps1"' -Credential $DC
Start-Process PowerShell -ArgumentList '-ExecutionPolicy Bypass -NoProfile -File "C:\Users\wsadmin\Desktop\ssl.ps1"' -Verb RunAs
