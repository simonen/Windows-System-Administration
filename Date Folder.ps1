Write-Host "###################################################"
Write-Host "#CREATE DATED FOLDERS IN EACH /RENDER/CGI0X FOLDER#" -ForegroundColor Cyan
Write-Host "###################################################"
Write-Host

$projNum = Read-Host "ENTER PROJECT NUMBER"
Write-Host
$RENDER = Get-ChildItem E:\$projNum*\RENDER
$date = (Get-Date).ToString("yyyy.MM.dd")

$cgiFolders = Get-ChildItem -Filter CGI* -Directory -Path $RENDER

foreach ($_ in $cgiFolders.Fullname)
{

New-Item -ItemType Directory -Path $_\$date -Verbose

}

pause