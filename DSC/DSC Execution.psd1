Install the SMBShare Resource 

PS:> Install-Module -Name ComputerManagementDsc

PS:> . ./M8.ps1
PS:> M8 -ConfigurationData ./Nodes.psd1
PS:> Start-DscConfiguration -Path .\M8 -Verbose -Wait -force