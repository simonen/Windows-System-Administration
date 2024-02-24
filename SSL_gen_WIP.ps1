$Password = ConvertTo-SecureString -AsPlainText "PASSWORD" -Force
$LocalUser = "USERNAME"
$LC = New-Object System.Management.Automation.PSCredential($LocalUser, $Password)

$hostname = $env:COMPUTERNAME
$fqdn = ([System.Net.Dns]::GetHostByName($env:computerName)).hostname
$ip = (Get-NetIPAddress -AddressFamily IPv4 -PrefixLength 22).ipaddress

$lookupTable = @{
    'hostname' = $hostname.ToUpper()
    'fqdn' = $fqdn.ToUpper()
    'ipv4' = $ip

}

New-PSDrive -Name G -PSProvider FileSystem -Root "\\PATH" -Credential $LC
$original_file = 'G:\ext_template.cfg'
$destination_file =  'c:\temp\ext.cfg'

New-Item -Path C:\ -ItemType Directory -Name OpenSSL -Verbose
Copy-Item -Path "G:\openssl.cnf" -Destination C:\Openssl -Verbose
Copy-Item -Path "g:\*" -Destination c:\Temp -Recurse
Copy-Item -Path "G:\XXX.csr" -Destination C:\Temp -Verbose
Copy-Item -Path "G:\interCA.crt" -Destination C:\Temp -Verbose
Copy-Item -Path "G:\interCA.key" -Destination C:\Temp -Verbose
Copy-Item -Path "G:\XXX.key" -Destination C:\Temp -Verbose

Get-Content -Path $original_file | ForEach-Object {
    $line = $_

    $lookupTable.GetEnumerator() | ForEach-Object {
        if ($line -match $_.Key)
        {
            $line = $line -replace $_.Key, $_.Value
        }
    }

   $line
} | Set-Content -Path $destination_file

Get-Content $destination_file

Import-Certificate -FilePath C:\Temp\XXX_CA.der -CertStoreLocation Cert:\LocalMachine\AuthRoot -Verbose
Import-Certificate -FilePath C:\Temp\XXX_InterCA.der -CertStoreLocation Cert:\LocalMachine\AuthRoot -Verbose

set-location C:\Temp\OpenSSL\bin
.\openssl x509 -req -in 'C:\Temp\XXX.csr' -CA "C:\Temp\interCA.crt" -CAkey "C:\Temp\interCA.key" -out "C:\Users\saladin\Desktop\$hostname.XXX.crt" -days 1000 -sha256 -extfile "C:\Temp\ext.cfg" -extensions san_reqext
