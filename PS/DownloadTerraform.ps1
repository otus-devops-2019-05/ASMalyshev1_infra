Param(
[string]$Version = "last" #0.11.1
)

    IF ($Version -eq "last"){
    $uri = "https://www.terraform.io/downloads.html"
    } ELSE {
    $uri = "https://releases.hashicorp.com/terraform/$Version"
    }

$IW = Invoke-WebRequest -Uri $uri -Method Get
$TerraformDownloadUrl = $IW.Links.href|Where-Object{$_ -like '*terraform_*_windows_amd64.zip'}|Select-Object -First 1 -Unique
IF (!($TerraformDownloadUrl -match "https")){
$TerraformDownloadUrl = [regex]::Match($uri,"https:\/\/.[\w.+]+").Value + $TerraformDownloadUrl
}

Invoke-WebRequest -Uri $TerraformDownloadUrl -Method Get -OutFile .\terraform.zip
    IF (Test-Path .\terraform.zip){
        try{
        Expand-Archive -Path .\terraform.zip -DestinationPath "$env:windir\System32" -Force
        Remove-Item .\terraform.zip -Force
        Write-Host "Ok: Expand-Archive terraform.zip" -ForegroundColor Green
        } catch {
        Write-Host "Error: Expand-Archive terraform.zip" -ForegroundColor Red
        }
    } ELSE {
    Write-Host "Error: DownLoad $TerraformDownloadUrl" -ForegroundColor Red
    }

#Проверить установку Terraform можно командой:
terraform -v
