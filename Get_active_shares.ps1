$servers = get-content c:\temp\servers.txt
$cred = get-credential 
get-wmiobject Win32_Share -computer $servers -credential $cred | select __server,name,description,path | export-csv c:\temp\sharereport.csv -notype