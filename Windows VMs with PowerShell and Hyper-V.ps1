$SourceVHD = 'D:\HV_VMs\WS2019DE_template\Virtual Hard Disks\WS2019_template.vhdx'
$TargetFolder = 'D:\HV_VMs'

# Local credentials
$Password = ConvertTo-SecureString -AsPlainText "Power123" -Force
$LocalUser = "Administrator"
$LC = New-Object System.Management.Automation.PSCredential($LocalUser, $Password)

# Domain credentials
$Domain = "WSAA.LAB"
$DomainUser = "$Domain\Administrator"
$DC = New-Object System.Management.Automation.PSCredential($DomainUser, $Password)

# VM Names
$VM1 = 'WSAA-M2-VM-DC'
$VM2 = 'WSAA-M2-VM-S1'
$VM3 = 'WSAA-M2-VM-S2'
$VMNAME = @($VM1, $VM2, $VM3)

foreach ($item in $VMNAME) {
New-Item -ItemType Directory -Name $item -Path $TargetFolder | ForEach-Object
{ Copy-Item -Path $SourceVHD -Destination $TargetFolder\$item\$item-OS.vhdx }
}

# VM1 DC
New-VM -Name $VM1 -MemoryStartupBytes 3072mb -Generation 2 -SwitchName "NAT vSwitch" -VHDPath $TargetFolder\$VM1\$VM1-OS.vhdx | Set-VMProcessor -Count 2  Set-VMMemory $VM1 -DynamicMemoryEnabled $false 

# VM2 S1
New-VM -Name $VM2 -MemoryStartupBytes 3072mb -Generation 2 -SwitchName "NAT vSwitch" -VHDPath $TargetFolder\$VM2\$VM2-OS.vhdx | Set-VMProcessor -Count 2  Set-VMMemory $VM2 -DynamicMemoryEnabled $false

# VM3
New-VM -Name $VM3 -MemoryStartupBytes 3072mb -Generation 2 -SwitchName "NAT vSwitch" -VHDPath $TargetFolder\$VM3\$VM3-OS.vhdx | Set-VMProcessor -Count 2  Set-VMMemory $VM3 -DynamicMemoryEnabled $false 

#Start VMs
Start-VM -Name $VM1, $VM2, $VM3

pause

# Change OS name and Time Zone
Invoke-Command -VMName $VM1 -Credential $LC -ScriptBlock { Set-TimeZone -name "FLE Standard Time" ; Rename-Computer -NewName DC -Restart  }
Invoke-Command -VMName $VM2 -Credential $LC -ScriptBlock { Set-TimeZone -name "FLE Standard Time" ; Rename-Computer -NewName SERVER1 -Restart  }
Invoke-Command -VMName $VM3 -Credential $LC -ScriptBlock { Set-TimeZone -name "FLE Standard Time" ; Rename-Computer -NewName SERVER2 -Restart  }

# Set network settings
Invoke-Command -VMName $VM1 -Credential $LC -ScriptBlock { New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "192.168.99.2" -PrefixLength 24 -DefaultGateway 192.168.99.1 }
Invoke-Command -VMName $VM2 -Credential $LC -ScriptBlock { New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "192.168.99.101" -PrefixLength 24 -DefaultGateway 192.168.99.1 ; Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.99.2 }
Invoke-Command -VMName $VM3 -Credential $LC -ScriptBlock { New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "192.168.99.102" -PrefixLength 24 -DefaultGateway 192.168.99.1 ; Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 192.168.99.2 }

# Install AD DS + DNS on the DC
Invoke-Command -VMName $VM1 -Credential $LC -ScriptBlock { Install-WindowsFeature AD-Domain-Services, DNS -IncludeManagementTools }
Invoke-Command -VMName $VM1 -Credential $LC -ScriptBlock { Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "WinThreshold" -DomainName $args[0] -ForestMode "WinThreshold" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false -SysvolPath "C:\Windows\SYSVOL" -Force:$true -SafeModeAdministratorPassword $args[1] } -ArgumentList $Domain, $Password

# Wait for the AD to be setup
pause

# Join other machines to the domain
Invoke-Command -VMName $VM2, $VM3 -Credential $LC -ScriptBlock { Add-Computer -DomainName $args[0] -Credential $args[1] -Restart } -ArgumentList $Domain, $DC

# Create additional user with administrative privileges
Invoke-Command -VMName $VM1 -Credential $DC -ScriptBlock { New-ADUser -Name "Admin User" -AccountPassword $args[0] -DisplayName "Admin User" -Enabled $true -GivenName Admin -Surname User -UserPrincipalName admin.user@wsaa.lab -SamAccountName admin.user ; Add-ADGroupMember "Domain Admins" admin.user } -ArgumentList $Password

# Create additional user with no administrative privileges
Invoke-Command -VMName $VM1 -Credential $DC -ScriptBlock { New-ADUser -Name "Regular User" -AccountPassword $args[0] -DisplayName "Regular User" -Enabled $true -GivenName Regular -Surname User -UserPrincipalName regular.user@wsaa.lab -SamAccountName regular.user } -ArgumentList $Password

# Add second NIC for storage to S1, S2
Add-VMNetworkAdapter -VMName $VM2, $VM3 -Name "Storage NIC" -SwitchName "vStorage"

# Add third NIC for cluster communication to both HV machines
Add-VMNetworkAdapter -VMName $VM2, $VM3 -Name "Private NIC" -SwitchName "vPrivate"

# Add fourth NIC for cluster communication to both HV machines
Add-VMNetworkAdapter -VMName $VM2, $VM3 -Name "Public NIC" -SwitchName "NAT vSwitch"

# Set the IP address for the second NICs
Invoke-Command -VMName $VM2 -Credential $DC -ScriptBlock { Rename-NetAdapter -Name "Ethernet 2" -NewName "Storage" ; New-NetIPAddress -InterfaceAlias "Storage" -IPAddress "192.168.97.3" -PrefixLength 24 }
Invoke-Command -VMName $VM3 -Credential $DC -ScriptBlock { Rename-NetAdapter -Name "Ethernet 2" -NewName "Storage" ; New-NetIPAddress -InterfaceAlias "Storage" -IPAddress "192.168.97.21" -PrefixLength 24 }

# Set the IP address for the third NICs
Invoke-Command -VMName $VM2 -Credential $DC -ScriptBlock { Rename-NetAdapter -Name "Ethernet 3" -NewName "Private" ; New-NetIPAddress -InterfaceAlias "Private" -IPAddress "192.168.98.21" -PrefixLength 24 }
Invoke-Command -VMName $VM3 -Credential $DC -ScriptBlock { Rename-NetAdapter -Name "Ethernet 3" -NewName "Private" ; New-NetIPAddress -InterfaceAlias "Private" -IPAddress "192.168.98.22" -PrefixLength 24 }