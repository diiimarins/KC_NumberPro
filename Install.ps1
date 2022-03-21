$scopedPath = $env:ProgramFiles
$scopedChildPath = "\WindowsPowerShell\Modules"

$Destination = Join-Path -Path $scopedPath -ChildPath $scopedChildPath

$Path = "$($PSScriptRoot)\KC.NumberPro\"
Copy-Item -Destination $Destination -Path $Path -Recurse -Force -Verbose
