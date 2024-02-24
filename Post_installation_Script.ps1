Write-Host "##################################################################"
Write-Host "############# Windows Post Installation Configuration ############"
Write-Host "##################################################################"

### Sysprepping (if using cloned VHDs)

#set-location C:\Windows\System32\sysprep 
#sysprep.exe /generalize /shutdown /oobe
#Reset WSUS ID

##Write-Verbose "Resetting WSUS ID"
#net stop wuauserv
#reg.exe delete HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate /v SusClientId /f
#net start wuauserv
#wuauclt.exe /resetauthorization /detectnow 
$VLAN = Read-Host -Prompt 'VLAN 106 or VLAN 107? '
$LAST = Read-Host -Prompt 'Enter the last octet of the IP Address: 1-254 '
$IP = "10.$VLAN.1.$LAST"
$SUBNET = 22 # This means subnet mask = 255.255.252.0
$GATEWAY = "10.$VLAN.0.1"
$DNS = "10.$VLAN.0.251"
$IPType = "ipv4"

# Retrieve the network adapter that you want to configure
$adapter = Get-NetAdapter | ? {$_.Status -eq "up"}

# Remove any existing IP, gateway from our ipv4 adapter
If (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
    $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
}

If (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
    $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
}

 # Configure the IP address and default gateway
$adapter | New-NetIPAddress `
    -AddressFamily $IPType `
    -IPAddress $IP `
    -PrefixLength $SUBNET `
    -DefaultGateway $GATEWAY

# Configure the DNS client server IP addresses
$adapter | Set-DnsClientServerAddress -ServerAddresses $DNS

Write-Host "### Setting Time Zone ### -ForegroundColor Cyan"
Set-TimeZone -Name "FLE Standard Time"
Get-TimeZone

$supp_pass = ConvertTo-SecureString -AsPlainText "PASSWORD" -force
$sala_pass = ConvertTo-SecureString -AsPlainText "PASSWORD" -force
Write-Host "### Create a New Unprivileged user ###" -ForegroundColor Cyan
New-LocalUser -Name support -FullName "Regular User" -Description "Remote Desktop User" -Password $supp_pass -PasswordNeverExpires -AccountNeverExpires -Verbose
Get-LocalUser -Name support | Add-LocalGroupMember -Group "Remote Desktop Users" -Verbose
Get-LocalUser -Name support | Add-LocalGroupMember -Group "Users" -Verbose
New-LocalUser -Name saladin -FullName "FULL_NAME" -Password $sala_pass -Description "DESCRIPTION" -PasswordNeverExpires -AccountNeverExpires -Verbose
Get-LocalUser -Name saladin | Add-LocalGroupMember -Group "Administrators"

#Allow Ping
Write-Host "### Allow PING through the Firewall ###" -ForegroundColor Cyan
Set-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)" -Profile any -IcmpType 0,3,8,11 -enabled True
#Write-Host "### Allow Port 443 and 8850 for TSM administration ###" -ForegroundColor Cyan
#New-NetFirewallRule -DisplayName 'HTTPS-Inbound-TSM-Administration' -Profile @('Domain', 'Private') -Direction Inbound -Action Allow -Protocol TCP -LocalPort @('8850', '443', '80')

#Allow RDP
Write-Host "### Allowing Remote Desktop Access ###" -ForegroundColor Cyan
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Turn "Hide extensions for known types" off
Write-Host "### Showing file extensions in the explorer ###" -ForegroundColor Cyan
Set-Location HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
Set-ItemProperty . HideFileExt "0"
Get-ItemProperty . HideFileExt
Set-Location -Path C:\

$StoragePassword = ConvertTo-SecureString -AsPlainText "PASSWORD" -Force
$StorageUser = "USERNAME"
$SC = New-Object System.Management.Automation.PSCredential($StorageUser, $StoragePassword)

#Install Firefox
Write-Host "### Install Firefox, checkmk agent and qemu guest agent ###" -ForegroundColor Cyan
New-Item -Name Temp -ItemType Directory -Path C:\
New-PSDrive -Name X -PSProvider FileSystem -Root \\IP_ADDR\smb_storage\software -Credential $SC
#Copy-Item -Path 'X:\Firefox Setup 103.0.2.msi' -Destination C:\Temp -Verbose
Copy-Item -Path 'X:\GoogleChromeEnterpriseBundle64\Installers\GoogleChromeStandaloneEnterprise64.msi' -Destination C:\Temp -Verbose
Copy-Item -Path 'X:\check_mk_agent.msi' -Destination C:\Temp -Verbose
Copy-Item -Path 'X:\qemu-ga-x86_64.msi' -Destination C:\Temp -Verbose
# Install software
#Invoke-CimMethod -ClassName Win32_Product -MethodName Install -Arguments @{PackageLocation='C:\Temp\Firefox Setup 103.0.2.msi'} -Verbose
Invoke-CimMethod -ClassName Win32_Product -MethodName Install -Arguments @{PackageLocation='C:\Temp\GoogleChromeStandaloneEnterprise64.msi'} -Verbose
Invoke-CimMethod -ClassName Win32_Product -MethodName Install -Arguments @{PackageLocation='C:\Temp\check_mk_agent.msi'} -Verbose
Invoke-CimMethod -ClassName Win32_Product -MethodName Install -Arguments @{PackageLocation='C:\Temp\qemu-ga-x86_64.msi'} -Verbose

Start-Sleep -Seconds 2

# CheckMK windows license plugin
Copy-Item -Path 'X:\win_license.bat' -Destination C:\ProgramData\checkmk\agent\plugins -Verbose
Copy-Item -Path 'X:\windows_updates.vbs' -Destination C:\ProgramData\checkmk\agent\plugins -Verbose

#Install the drivers for the qemu
Get-ChildItem "\\10.106.0.10\smb_storage\software\vioserial\2k19\amd64" -Recurse -Filter "*.inf" |
ForEach-Object { PNPUtil.exe /add-driver $_.FullName /install }

#Change Computer Name
$pcname = Read-Host -Prompt 'Enter The New PC Name'
Rename-Computer -NewName $pcname -Restart

# Increase the winrm memory for shell execution
#get-Item -Path WSMan:\localhost\Shell\MaxMemoryPerShellMB  # this is the max mem in MB
#Set-Item -Path WSMan:\localhost\Shell\MaxMemoryPerShellMB -Value 2048  # this is the max mem in MB
#Restart-Service -Name WinRM
