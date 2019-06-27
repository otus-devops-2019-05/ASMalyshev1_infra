Clear-Host
Set-Location $PSScriptRoot

$VpnFolder = 'VPN'

IF(!(Test-Path -Path .\$VpnFolder)){
New-Item -Path .\ -Name $VpnFolder -ItemType Directory -Force
}

Get-ChildItem -Path .\|Where-Object {$_.Extension -eq '.ovpn' -or $_.name -eq 'setupvpn.sh'}|Move-Item -Destination .\$VpnFolder -Force