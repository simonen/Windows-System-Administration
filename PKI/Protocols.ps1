# Check the currently enabled TLS protocol

# Define the Schannel Protocols registry path
$protocolsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"

# Get all configured protocols
$protocols = Get-ChildItem -Path $protocolsPath

# Loop through each protocol and check if it's enabled
foreach ($protocol in $protocols) {
    $protocolName = $protocol.PSChildName
    Write-Host "Protocol: $protocolName"

    # Check Client configuration
    $clientPath = "$($protocol.PSPath)\Client"
    if (Test-Path $clientPath) {
        $clientEnabled = (Get-ItemProperty -Path $clientPath).Enabled
        Write-Host "  Client Enabled: $clientEnabled"
    }

    # Check Server configuration
    $serverPath = "$($protocol.PSPath)\Server"
    if (Test-Path $serverPath) {
        $serverEnabled = (Get-ItemProperty -Path $serverPath).Enabled
        Write-Host "  Server Enabled: $serverEnabled"
    }

    Write-Host "------------------------"
}