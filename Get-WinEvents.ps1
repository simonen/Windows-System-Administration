###### Computer Restart / PowerOff / Shutdown Event 1074
Get-WinEvent -filterhash @{Logname = 'system';ID=1074} -MaxEvents 1000 |
Select-Object @{Name="Computername";Expression = {$_.machinename}},
@{Name="UserName";Expression = { ($_.properties[-1]).value}}, TimeCreated,
@{Name="Category";Expression = {$_.properties[4].value}}

##### Computer Restart ID 1074
Get-WinEvent -filterhash @{Logname = 'system';ID=1074} -MaxEvents 1000 |
Select-Object @{Name="Computername";Expression = {$_.machinename}},
@{Name="UserName";Expression = {$_.UserId.translate([System.Security.Principal.NTAccount]).value}}, TimeCreated


##### Computer Restart ID 1074 (SID)

Get-EventLog -log system -newest 1000 |
Where-Object {$_.eventid -eq '1074'}  |
Format-Table machinename, username, timegenerated -autosize
######

### Successful RDP Logins - ID 1149

$properties = @(
@{n='TimeStamp';e={$_.TimeCreated}}
@{n='ID' ;e={$_.Id}}
@{n='LocalUser';e={$_.properties[0].value}}
#@{n='Task' ;e={$_.TaskDisplayName}}
@{n='Network Address';e={$_.properties[2].value}}
@{n='Domain' ;e={$_.properties[1].value}}
#@{n='Message';e={$_.message}}  
)
#$FormatEnumerationLimit=-1
$rep = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational'; ID=1149} -MaxEvents 10 | Select-Object -Property $properties
$rep


##############


###### Export to HTML
$htmlParams = @{
  Title = "Event Log: corptest-ad-05 logon history"
  Body = Get-Date
  PreContent = "<P>Generated by: Simeon Nedkov</P>"
  PostContent = "."
}
....
....
ConvertTo-Html @htmlParams | Out-File ...


#### Failed Logon attempts


$Date= Get-date     
 
$DC= "Domain Controller name" 
 
$Report= "C:\ADreport.html" 
 
$HTML=@" 
<title>Event Logs Report</title>
 
BODY{background-color :#FFFFF} 
TABLE{Border-width:thin;border-style: solid;border-color:Black;border-collapse: collapse;} 
TH{border-width: 1px;padding: 1px;border-style: solid;border-color: black;background-color: ThreeDShadow} 
TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color: Transparent} 
 
"@ 
 
$eventsDC= Get-Eventlog security -Computer $DC -InstanceId 4625 -After (Get-Date).AddDays(-7) | 
   Select TimeGenerated,ReplacementStrings | 
   % { 
     New-Object PSObject -Property @{ 
      Source_Computer = $_.ReplacementStrings[13] 
      UserName = $_.ReplacementStrings[5] 
      IP_Address = $_.ReplacementStrings[19] 
      Date = $_.TimeGenerated 
    } 
   } 
    
  $eventsDC | ConvertTo-Html -Property Source_Computer,UserName,IP_Address,Date -head $HTML -body "Gernerated On $Date"| 
     Out-File $Report -Append 

### Failed Logon attempts ID 4625
$properties = @(
@{n='TimeStamp';e={$_.TimeCreated}}
@{n='ID' ;e={$_.Id}}
@{n='LocalUser';e={$_.properties[13].value}}
#@{n='Task' ;e={$_.TaskDisplayName}}
@{n='Network Address';e={$_.properties[19].value}}
@{n='Auth Package' ;e={$_.properties[12].value}}
#@{n='Message';e={$_.message | select -First 1}}  
)
$FormatEnumerationLimit=-1
$rep = Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4625} -MaxEvents 1 | Select-Object -Property $properties

select-string -Path $input_path -Pattern $regex -AllMatches |  Write-Output

$rep | Export-Csv -Path C:\FailedLogons.csv


##### Windows Logon ID7001 / Logoff ID7002
$logs = get-eventlog system -source Microsoft-Windows-Winlogon -After (Get-Date).AddDays(-7);
$res = @(); ForEach ($log in $logs) {if($log.instanceid -eq 7001) {$type = "Logon"} Elseif ($log.instanceid -eq 7002){$type="Logoff"} Else {Continue} $res += New-Object PSObject -Property @{Time = $log.TimeWritten; "Event" = $type; User = (New-Object System.Security.Principal.SecurityIdentifier $Log.ReplacementStrings[1]).Translate([System.Security.Principal.NTAccount])}};
$res
