$msg = "Do you want to repeate operation? [Y/N]"

do {

$usrfirstName = (Read-Host -Prompt "Enter your first name: ")
$usrlastName  = (Read-Host -Prompt "Enter your last name: " )
$pass      = (Read-Host -Prompt "Enter your password: ")
New-ADUser -Name "$usrfirstName $usrlastName" -SamAccountName $usrfirstName"."$usrlastName -AccountPassword (ConvertTo-SecureString -AsPlainText $pass -force)
New-Item -Name $usrfirstName"."$usrlastName -ItemType Directory -Path "C:\Shared\"
cd "c:\shared\$usrfirstName.$usrlastName"
$response = Read-Host -Prompt $msg

} until ($response -eq 'n')