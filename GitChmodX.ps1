Clear-Host
Set-Location $PSScriptRoot

"& git ls-files --stage"
"======================="
& git ls-files --stage

Get-ChildItem -Filter *.sh|foreach {git update-index --chmod=+x $_.FullName}

'& git ls-files --stage|Select-String -Pattern "^100755"'
"======================="
& git ls-files --stage|Select-String -Pattern "^100755"
"======================="
