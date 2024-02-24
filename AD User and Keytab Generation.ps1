Write-Host "############## AD User and Kerberos Keytab Generation Script ##############"

$user = Read-host "Enter a User Name"
$disp_name = Read-Host "Enter a Display Name"
$principal = Read-host 'Enter a principal Name'
$domain = 'DOMAIN'
$fdomain = 'DOMAIN_FQDN'
$fdomain_upper = $fdomain.ToUpper()

New-ADUser -Name $user -DisplayName $disp_name -UserPrincipalName "$user@$fdomain" -Type User -Path "OU=saas,DC=,DC=,DC=,DC=" -AccountPassword (ConvertTo-SecureString -AsPlainText "PASSWORD" -Force) -Enabled $true -PasswordNeverExpires $true -CannotChangePassword $true
Set-ADUser -Identity $user -KerberosEncryptionType AES128,AES256

setspn -s "HTTP/$principal".ToUpper() $domain\$user
setspn -s "HTTP/$principal.$fdomain".ToUpper() $domain\$user

ktpass -princ "HTTP/$principal.$fdomain@$fdomain_upper" -crypto AES256-SHA1 -mapuser $domain\$user -mapOp set +DumpSalt -pass "PASSWORD" -out "c:\Temp\$principal.keytab" -ptype KRB5_NT_PRINCIPAL

Get-ADUser -Identity r -Properties ServicePrincipalNames