$product = (Get-ComputerInfo).windowsproductname
write-host "Your OS is: $product"
$is_tableau = $false

if ($product -match "Windows Server 2019 Standard")
{
    #Activate Windows Server 2019 using Volume License Key
    Write-Host "Activating $product..." -ForegroundColor Cyan
    #slmgr.vbs /ipk <ACTIVATION_KEY>
    $answer = Read-Host "Tableau Server Instance? Type 'y' if true"
    $os = "2k19"

    if ($answer -match "y")
    {
        $tableau = $true
        $is_tableau
        Write-Host "### Allow Port 443 and 8850 for TSM administration ###" -ForegroundColor Cyan
        #New-NetFirewallRule -DisplayName 'HTTPS-Inbound-TSM-Administration' -Profile @('Domain', 'Private') -Direction Inbound -Action Allow -Protocol TCP -LocalPort @('8850', '443') -Verbose
        Write-Host "### Installing drivers..." -ForegroundColor Cyan
    }
}
elseif ($product -match "Windows 10*")
{
    Write-Host "Activating $product..." -ForegroundColor Cyan
    #slmgr.vbs /ipk XXXXX-XXXXX-XXXXX-XXXXX-XXXXX
    $os = "w10"
}

$license = (Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | where { $_.PartialProductKey }).LicenseStatus# | select Description, LicenseStatus
if ($license -eq 1)
{
    Write-Host "Windows successfully activated" -ForegroundColor Cyan
}


New-PSDrive -Name X -PSProvider FileSystem -Root \\10.106.0.10\smb_storage -Credential sadmin -Verbose
#Copy the drivers to C:\Temp
Copy-Item -Path 'X:\software\Firefox Setup 103.0.2.msi' -Destination C:\Temp -Verbose
Invoke-CimMethod -ClassName Win32_Product -MethodName Install -Arguments @{PackageLocation='C:\Temp\Firefox Setup 103.0.2.msi'} -Verbose
#Install the drivers for the qemu
Get-ChildItem "\\10.106.0.10\smb_storage\software\vioserial\$os\amd64" -Recurse -Filter "*.inf"# | 
#ForEach-Object { PNPUtil.exe /add-driver $_.FullName /install }

Invoke-Command -ScriptBlock {New-Item -Name "1" -ItemType File -Path C:\Temp ; Restart-Computer -Force ; New-Item -Name "2" -ItemType Directory -Path C:\Temp}