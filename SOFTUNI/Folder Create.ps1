param ($ProjectStart, $ProjectEnd, $PhaseStart, $PhaseEnd)


$ProjectStart..$ProjectEnd | ForEach-Object { New-Item -Name "Project$_" -Path "C:\Project" -ItemType Directory }

$folders = Get-ChildItem "C:\Project"

foreach ($folder in $folders) {

    $PhaseStart,$PhaseEnd | ForEach-Object { New-Item -Name "Phase$_" -Path $folder.FullName -ItemType Directory }

}
