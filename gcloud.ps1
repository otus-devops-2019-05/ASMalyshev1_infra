Clear-Host

[array]$IW = Invoke-WebRequest -Uri https://gist.githubusercontent.com/Nklya/5bc429c6ca9adce1f7898e7228788fe5/raw/01f9e4a1bf00b4c8a37ca6046e3e4d4721a3316a/gcloud -Method Get

(-split $IW.Content) -replace "\\" -join " "
