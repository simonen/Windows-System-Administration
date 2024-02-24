Import-Csv .\ilos.csv | ForEach-Object {

    #ping $_.ip
    Write-Host $_.ip

}