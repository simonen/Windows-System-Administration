$domain = "WSAA.LAB"
$local_user = "USERNAME"
$password = ConvertTo-SecureString -AsPlainText "PASSWORD" -force
$lc = New-Object System.Management.Automation.PSCredential($local_user, $password)

New-LocalUser `
-Name saladin `
-FullName "FULL NAME" `
-Description "DESCRIPTION" `
-PasswordNeverExpires `
-AccountNeverExpires `
-Password $password `
-Verbose

Get-LocalUser -Name saladin | Add-LocalGroupMember -Group "Administrators"

#Allow Ping
Write-Host "### Allow PING through the Firewall ###" -ForegroundColor Cyan
Set-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)" -Profile any -IcmpType 0,3,8,11 -enabled True

#Allow RDP
Write-Host "### Allowing Remote Desktop Access ###" -ForegroundColor Cyan
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Install AD DS + DNS

Write-Host "Installing AD DS + DNS" -ForegroundColor Cyan

Invoke-Command -ScriptBlock { Install-WindowsFeature AD-Domain-Services, DNS -IncludeManagementTools }
Invoke-Command -ScriptBlock { Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "WinThreshold" `
-DomainName $args[0] `
-ForestMode "WinThreshold" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true `
-SafeModeAdministratorPassword $args[1] } -ArgumentList $domain, $password
