@{
    AllNodes = @(
        @{ NodeName = "HV1" ; WindowsFeatures = @("web-server", "Web-Mgmt-Tools") },
        @{ NodeName = "HV2" ; WindowsFeatures = @("web-server", "Web-Mgmt-Tools") }
        )
 }