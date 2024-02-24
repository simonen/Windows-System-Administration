#Join the Machine to AD
$domain = Read-Host -Prompt "Enter domain name"
$domainUser = "$domain\DOMAIN_USER"
$DC = New-Object System.Management.Automation.PSCredential($domainUser, $Password)
$Password = ConvertTo-SecureString -AsPlainText "PASSWORD" -Force

$fdomain = $domain.Split(".")
$list = @()

$fdomain | ForEach-Object {
    $list += "DC=$_"
    }

$a = $list -join ","
$ou = "OU=WSUS-BG,OU=WSUS,$a"

Add-Computer -DomainName $domain -OUPath $ou -DomainCredential $DC -Restart