# Get Specific AD Computer by name, show IP Address
Get-ADComputer -Filter 'Name -eq "HOSTNAME"' -Properties ipv4address
# Get all AD Computers with matching IP addresses
Get-ADComputer -Filter * -Properties ipv4address | Where-Object {$_.Ipv4Address -match "^10.50.1.*"}
# Remove a specific AD Computer
Get-ADComputer -Filter 'Name -eq "HOSTNAME"' -Properties ipv4address | Remove-ADComputer -Confirm:$false
# Get a specific DNS Record by IP Address
Get-DnsServerResourceRecord -ZoneName "ZONE" -RRType A | Where-Object {$_.RecordData.IPv4Address -eq "IP_ADDR"} | ft -AutoSize
# Filter out specific set of IP addresses. 10.106.1.*
Get-DnsServerResourceRecord -ZoneName 'ZONE' -RRType A -ComputerName DNS_SERVER_HOSTNAME | Where-Object {$_.RecordData.Ipv4Address -match "^IP.*"} | ft -AutoSize
Get-DnsServerResourceRecord -ZoneName "ZONE" -RRType A -name "HOSTNAME"
Remove-DnsServerResourceRecord -ZoneName "ZONE" -RRType A -name "HOSTNAME" -Confirm:$false

#Remove computer from AD. Executed Locally
Remove-Computer -UnjoinDomainCredential DOMAIN\ADMIN_USER  -PassThru -Force -WorkgroupName "WORKGROUP"