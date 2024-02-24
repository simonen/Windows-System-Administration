Configuration M8
{

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc

    ForEach($Node in $AllNodes)
    {
        Node $Node.NodeName
        {
           ForEach($Feature in $Node.WindowsFeatures)
           {
                WindowsFeature $Feature
                {
                    Name = $Feature
                    Ensure = "Present"
                }
            
            }    

        }
    }

    Node localhost
    {
          
           File index
       {
            DestinationPath = "C:\WSAA-M8\index.html"

            Contents = "<h1>SMB SHARE WORKS</h1>"
            Ensure = "Present"
       }

       SmbShare NewShare
       {
            Name = "Web"
            Path = "C:\WSAA-M8\"
            ReadAccess = @("Everyone","WSAA\HV1$", "WSAA\HV2$")
            Ensure = "Present"
       }

   } 
        ForEach($Node in $AllNodes)
        {
            Node $Node.NodeName
            {
              File CopyIndex
              {
                DestinationPath = "C:\inetpub\wwwroot\index.html"
                Type = "File"
                SourcePath = "\\DC\Web\index.html"
                Ensure = "Present"
              }

            }
        }
}