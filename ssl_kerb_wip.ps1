# KERBEROS
$fqdn = ([System.Net.Dns]::GetHostByName($env:computerName)).hostname
$fqdn
$hostname = $env:COMPUTERNAME
$hostname
$fdomain = $fqdn.Split(".", 2)[1]
$fdomain
$domain = $fqdn.Split(".")[1]
$domain
$spn = "tabkloud"

setspn -s "HTTP/$hostname".ToUpper() $domain\$spn
setspn -s "HTTP/$fqdn".ToUpper() $domain\$spn

ktpass -princ "HTTP/$fqdn@$fdomain" -pass "PASSWORD" -mapOp set +DumpSalt -ptype KRB5_NT_PRINCIPAL -crypto AES256-SHA1 -out "C:\Users\saladin\Desktop\$hostname.keytab" -target "VERTEX-DC.WSA.LAB"
