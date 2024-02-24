# Get windows licensing information
$slmgr = cscript.exe C:\Windows\system32\slmgr.vbs /dlv
Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | where { $_.PartialProductKey } | select Description, LicenseStatus, ID
#Deactivate Windows Using Activation ID key
slmgr /upk <“activation id”>
# Get Windows OS and Version information
systeminfo | findstr /B /C:"OS Name" /B /C:"OS Version"
#Local Credentials
$Password = ConvertTo-SecureString -AsPlainText "PASSWORD" -Force
$LocalUser = "USERNAME"
$LC = New-Object System.Management.Automation.PSCredential($LocalUser, $Password)