Param(
    [ValidateSet(2,3)][int]$Version = "2"
)

$uri = "https://www.python.org/downloads/windows/"

$IW = Invoke-WebRequest -Uri $uri -Method Get

IF ($Version -eq 2){
    $PythonDownloadUrl = ($IW.Links|Where-Object{$_ -like '*Latest*'}).href|Select-Object -Last 1 -Unique
} ELSEIF ($Version -eq 3) {
    $PythonDownloadUrl = ($IW.Links|Where-Object{$_ -like '*Latest*'}).href|Select-Object -First 1 -Unique
}

IF (!($PythonDownloadUrl -match "https")){
$uriPython = [regex]::Match($uri,"https:\/\/.[\w.+]+").Value + $PythonDownloadUrl
}

$IW = Invoke-WebRequest -Uri $uriPython -Method Get
$PythonDownloadUrl = ($IW.Links|Where-Object{$_ -like '*Windows*64*MSI*'}|Select-Object -Last 1 -Unique).href

$PythonMSIFileName = 'python.msi'
Invoke-WebRequest -Uri $PythonDownloadUrl -Method Get -OutFile .\$PythonMSIFileName
    IF (Test-Path .\$PythonMSIFileName){
        try{
            #https://www.python.org/download/releases/2.4/msi/
            Start-Process msiexec.exe -ArgumentList "/i", "$((Get-Location).Path)\$PythonMSIFileName",  "/passive", "/norestart", "ADDLOCAL=ALL" -Wait
            & python --version
            Remove-Item .\$PythonMSIFileName -Force
            #https://otus.ru/nest/post/662/
            #https://pip.pypa.io/en/stable/installing/
            $GetPip = 'get-pip.py'
            Invoke-WebRequest -Uri "https://bootstrap.pypa.io/$GetPip" -OutFile .\$GetPip
            Start-Process python -ArgumentList ".\$GetPip" -Wait -NoNewWindow
            Remove-Item .\$GetPip -Force
            Write-Host "Ok: $PythonMSIFileName install" -ForegroundColor Green
        } catch {
            Write-Host "Error: $PythonMSIFileName no install" -ForegroundColor Red
        }
    } ELSE {
        Write-Host "Error: DownLoad $PythonDownloadUrl" -ForegroundColor Red
    }
