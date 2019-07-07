# 8. Практика Infrastructure as a Code (IaC). Домашнее задание
#https://ru.hexlet.io/blog/posts/terraform-bazovoe-ispolzovanie

Clear-Host
Set-Location $PSScriptRoot
$Location = (Get-Location).Path

$infra = "infra-244306"
$sshKeysPath = "C:\\Users\\asmalyshev\\.ssh\\appuser.pub"

# Создаем новую ветку в нашем инфраструктурномрепозитории для выполнения данного ДЗ. Т.к. это первое задание, посвященое работе с Terraform, то ветку назовем "terraform-1"
# Создаем новую ветку "terraform-1"
git branch terraform-1
# Переходим в ветку "terraform-1"
git checkout terraform-1

# Удалить ключи пользователя appuser из метаданных проекта.
#gcloud compute instances add-metadata reddit-app --metadata-from-file ssh-keys="C:\Users\asmalyshev\.ssh\appuser.pub"

Function DownloadTerraform {
$IW = Invoke-WebRequest -Uri 'https://www.terraform.io/downloads.html' -Method Get
$TerraformDownloadUrl = $IW.Links.href|Where-Object{$_ -like '*terraform_*_windows_amd64.zip'}|Select-Object -First 1 -Unique
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
}
IF (!(Test-Path "$env:windir\System32\terraform.exe")){
DownloadTerraform
}

#Проверить установку Terraform можно командой:
terraform -v

#Создать директорию terraform внутри проекта infra.
$TerraformRootFolder = "terraform"
IF(Test-Path -Path .\$TerraformRootFolder){
terraform destroy -auto-approve=true

Remove-Item -Path .\$TerraformRootFolder -Force -Recurse
New-Item -Path .\ -Name $TerraformRootFolder -ItemType Directory -Force

#gcloud compute instances create reddit-app --boot-disk-size=10GB  --image-family ubuntu-1604-lts  --image-project=ubuntu-os-cloud  --machine-type=g1-small  --tags puma-server  --restart-on-failure
gcloud compute instances list
#gcloud compute zones list
gcloud compute instances delete reddit-app --quiet --zone europe-west1-b
} ELSE {
New-Item -Path .\ -Name $TerraformRootFolder -ItemType Directory -Force
}

<#
Внутри директории terraform создать пустой файл: main.tf
Это будет главный конфигурационный файл в этом задании, который будет содержать декларативное описание нашей инфраструктуры.
#>
$maintf = 'main.tf'
IF(!(Test-Path -Path .\$TerraformRootFolder\$maintf)){
New-Item -Path .\ -Name $TerraformRootFolder\$maintf -ItemType File -Force
}

#В корне репозитория создать файл .gitignore с содержимым указанным в https://raw.githubusercontent.com/express42/otus-snippets/master/hw-08/.gitignore.example
IF(!(Test-Path -Path .\.gitignore)){
Invoke-WebRequest -Uri https://raw.githubusercontent.com/express42/otus-snippets/master/hw-08/.gitignore.example -Method Get -OutFile .\.gitignore
}

#Первый делом определим секцию Provider в файле main.tf, которая позволит Terraform управлять ресурсами GCP через APIвызовы
@"
terraform {
  # Версия terraform
  # required_version = "0.11.11" #OTUS
  required_version = ">=0.11.11"
  }
  
  provider "google" {
  # Версияпровайдера
  # version = "2.0.0" #OTUS
  version = "~> 2.5"

  # ID проекта
  project = "$infra" # Пишем свой индификатор группы в GCP

  region = "europe-west-1"
}
"@.Split(13).Trim(10)|Out-File -FilePath .\$TerraformRootFolder\$maintf -Encoding utf8 -Force

<#
Провайдеры Terraform являются загружаемыми модулями, начиная с версии 0.10.
Для того чтобы загрузить провайдер и начать его использовать выполните следующую команду в директории terraform:
#>
$Location = (Get-Location).Path
Set-Location .\$TerraformRootFolder
terraform init
Set-Location $Location

<#
Terraform предоставляет широкий набор примитивов(resources) для управления ресурсами различных сервисов GCP.
Полный список предоставляемых terraform'ом ресурсов для работы с GCP можно посмотреть слева на https://www.terraform.io/docs/providers/google/index.html.
Чтобы запустить VM при помощи terraform, нам нужно воспользоваться ресурсом https://www.terraform.io/docs/providers/google/r/compute_instance.html, который позволяет управлять инстансами VM.
 #>
@"
resource "google_compute_instance" "app" {
    name         = "reddit-app"
    machine_type = "g1-small"
    zone         = "europe-west1-b"
    tags = ["reddit-app"]

    #Blocks of type "metadata" are not expected here.
    #https://github.com/terraform-providers/terraform-provider-google/issues/3858
    #Error: "metadata {" | Ok: "metadata = {" 

    metadata = {
        # путь до публичного ключа
        ssh-keys = "appuser:$('${file("' + $sshKeysPath + '")}"')
        #file("C:\\Users\\asmalyshev\\.ssh\\appuser.pub")}"
    }

    # определение загрузочного диска
    boot_disk {
        initialize_params {
	      image = "reddit-base"
	    }
}
# определение сетевого интерфейса
    network_interface {
     # сеть, к которой присоединить данный интерфейс  
     network = "default"
     # использовать ephemeral IP длядоступа из Интернет
     access_config {}
	}
}
"@.Split(13).Trim(10)|Out-File -FilePath .\$TerraformRootFolder\$maintf -Encoding utf8 -Force -Append

<#
Перед тем как дать команду terraform'у применить изменения,хорошей практикой является предварительно посмотреть,
какие изменения terraform собирается произвести относительно состояния известных ему ресурсов (tfstate файл),
и проверить, что мы действительно хотим сделать именно эти  изменения.
Выполните команду планирования изменений в директории terraform
#>

$Location = (Get-Location).Path
Set-Location .\$TerraformRootFolder
terraform  plan

#Для того чтобы запустить инстанс   VM, описание характеристик которого мы описали в конфигурационном файлеmain.tf, используем команду:
terraform apply -auto-approve=true
<#
Начиная с версии 0.11 terraform apply запрашивает дополнительное подтверждение при выполнении.
Необходимо добавить -auto-approve=true для отключения этого.
#>
<#
Результатом выполнения команды также будет создани ефайла terraform.tfstate в директории terraform.
Terraform хранит в этом файле состояние управляемых им ресурсов.
Загляните в этот файл и найдите внешний IP адрес созданного инстанса.
#>
terraform show | Select-String -Pattern "nat_ip"
Set-Location $Location

$nat_ip_line = (Select-String -Path .\$TerraformRootFolder\terraform.tfstate -Pattern '"nat_ip":').Line
$nat_ip = [regex]::Match($nat_ip_line,"(\d).+[0-9]").Value
<#
SSH connection problem with “Host key verification failed…
https://askubuntu.com/questions/45679/ssh-connection-problem-with-host-key-verification-failed-error
#>
ssh-keygen -R $nat_ip 
#Зная внешний IP адрес, попробуем подключиться к инстансупо  SSH,  как  мы  делали до этого в предыдущих ДЗ, используя следующую команду:
"ssh -i ~/.ssh/appuser appuser@$nat_ip"

<#
Чтобы не мешать выходные переменные с основной конфигурацией наших ресурсов, создадим их в отдельном файле, который  назовем outputs.tf.
Помним, что название файла может быть любым, т.к. terraform загружает все файлы в текущей директории, имеющие расширение *.tf.
#>
$outputstf = 'outputs.tf'
IF(!(Test-Path -Path .\$TerraformRootFolder\$outputstf)){
New-Item -Path .\ -Name $TerraformRootFolder\$outputstf -ItemType File -Force
}

@'
output "app_external_ip" {
  value = "${google_compute_instance.app.network_interface.0.access_config.0.assigned_nat_ip}"
}
'@.Split(13).Trim(10)|Out-File -FilePath .\$TerraformRootFolder\$outputstf -Encoding utf8 -Force

$Location = (Get-Location).Path
Set-Location .\$TerraformRootFolder
terraform refresh
terraform output
terraform output app_external_ip
Set-Location $Location

@'
resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"
  # Название сети, в которой действует правило 
  network = "default"
  # Какой доступ разрешить 
  allow {
      protocol = "tcp"
      ports = ["9292"]  
  }  
  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]
  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["reddit-app"]
}
'@.Split(13).Trim(10)|Out-File -FilePath .\$TerraformRootFolder\$maintf -Encoding utf8 -Force -Append

$Location = (Get-Location).Path
Set-Location .\$TerraformRootFolder
terraform plan
terraform apply -auto-approve=true
Set-Location $Location

<#
$VpnFolder = 'VPN'

IF(!(Test-Path -Path .\$VpnFolder)){
New-Item -Path .\ -Name $VpnFolder -ItemType Directory -Force
}

Get-ChildItem -Path .\|Where-Object {$_.Extension -eq '.ovpn' -or $_.name -eq 'setupvpn.sh'}|Move-Item -Destination .\$VpnFolder -Force
#>