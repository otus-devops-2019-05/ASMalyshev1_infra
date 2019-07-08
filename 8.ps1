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
}
IF (!(Test-Path "$env:windir\System32\terraform.exe")){
#DownloadTerraform -Version "0.11.11"
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
gcloud compute instances delete reddit-app --zone europe-west1-b --quiet
gcloud compute firewall-rules delete allow-puma-default --quiet
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
$maintfHead=@"
terraform {
  # Версия terraform
  #required_version = "0.11.11" #OTUS
  required_version = ">=0.11.11"
  }
  
  provider "google" {
  # Версия провайдера
  # version = "2.0.0" #OTUS
  version = "~> 2.5"

  # ID проекта
  project = "$infra" # Пишем свой индификатор группы в GCP
  region = "europe-west-1"
}
"@.Split(13).Trim(10)
$maintfHead|Out-File -FilePath .\$TerraformRootFolder\$maintf -Encoding utf8 -Force

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
  value = "${google_compute_instance.app.*.network_interface.0.access_config.0.nat_ip}"
}
'@.Split(13).Trim(10)|Out-File -FilePath .\$TerraformRootFolder\$outputstf -Encoding utf8 -Force

$Location = (Get-Location).Path
Set-Location .\$TerraformRootFolder
terraform refresh
terraform output
terraform output app_external_ip
Set-Location $Location

$maintfPuma=@'
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
'@.Split(13).Trim(10)
$maintfPuma|Out-File -FilePath .\$TerraformRootFolder\$maintf -Encoding utf8 -Force -Append

$Location = (Get-Location).Path
Set-Location .\$TerraformRootFolder
terraform plan
terraform apply -auto-approve=true
Set-Location $Location

### puma.service

<#
Создадим директорию files внутри директории terraform и создадим внутри нее файл puma.service с содержимым, указанным по ссылке:
https://raw.githubusercontent.com/express42/otus-snippets/master/hw-08/puma.service
#>
$pumaService = 'puma.service'
IF(!(Test-Path -Path .\$TerraformRootFolder\files\$pumaService)){
New-Item -Path .\ -Name $TerraformRootFolder\files\$pumaService -ItemType File -Force
Invoke-WebRequest -Uri https://raw.githubusercontent.com/express42/otus-snippets/master/hw-08/puma.service -Method Get -OutFile $TerraformRootFolder\files\$pumaService
}

#В корне репозитория создать файл .gitignore с содержимым указанным в https://raw.githubusercontent.com/express42/otus-snippets/master/hw-08/.gitignore.example
IF(!(Test-Path -Path .\.gitignore)){
Invoke-WebRequest -Uri https://raw.githubusercontent.com/express42/otus-snippets/master/hw-08/.gitignore.example -Method Get -OutFile .\.gitignore
}

### deploy.sh

$deploySh = 'deploy.sh'
IF(!(Test-Path -Path .\$TerraformRootFolder\files\$deploySh)){
New-Item -Path .\ -Name $TerraformRootFolder\files\$deploySh -ItemType File -Force
Invoke-WebRequest -Uri https://raw.githubusercontent.com/express42/otus-snippets/master/hw-08/deploy.sh -Method Get -OutFile $TerraformRootFolder\files\$deploySh
}

#$main.tf
@'
terraform {
  # версия terraform
  #required_version = ">=0.11.11"
  required_version = "~> 0.11.7"
}

provider "google" {
  # Версия провайдера
  version = "~> 2.5"

  # id проекта
  project = "${var.project}"

  region = "${var.region}"
}

resource "google_compute_instance" "app" {
  name         = "reddit-app-${count.index + 1}"
  machine_type = "g1-small"
  zone         = "${var.zone}"
  tags         = ["reddit-app"]
  count = "${var.instance_count}"

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "${var.disk_image}"
    }
  }

  # определение сетевого интерфейса
  network_interface {
    # сеть, к которой присоединить данный интерфейс
    network = "default"

    # использовать ephemeral IP для доступа из Интернет
    access_config {}
  }

  #Blocks of type "metadata" are not expected here.
  #https://github.com/terraform-providers/terraform-provider-google/issues/3858
  #Error: "metadata {" | Ok: "metadata = {" 

  metadata = {
    # Путь до публичного ключа
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  # Подключение провиженоров к ВМ
  connection {
    type  = "ssh"
    user  = "appuser"
    agent = false

'@.Split(13).Trim(10)|Out-File -FilePath .\$TerraformRootFolder\$maintf -Encoding utf8 -Force
@"
    host = "$nat_ip"
"@.Split(13).Trim(10)|Out-File -FilePath .\$TerraformRootFolder\$maintf -Encoding utf8 -Force -Append
@'
    # путь до приватного ключа
    private_key = "${file("C:\\Users\\asmalyshev\\.ssh\\appuser")}"
  }

  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"

  # Название сети, в которой действует правило
  network = "default"

  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  # Каким адресам разрешать доступ
  source_ranges = ["0.0.0.0/0"]

  # Правило применения для инстансов с перечисленными тегами
  target_tags = ["reddit-app"]
}

resource "google_compute_project_metadata" "many_keys" {
  project = "${var.project}"
  metadata = {
    ssh-keys = "appuser2:${file(var.public_key_path)} \nappuser3:${file(var.public_key_path)}"
  }
}
'@.Split(13).Trim(10)|Out-File -FilePath .\$TerraformRootFolder\$maintf -Encoding utf8 -Force -Append
#outputs.tf
@'
output "app_external_ip" {
  value = "${google_compute_instance.app.*.network_interface.0.access_config.0.nat_ip}"
}
'@.Split(13).Trim(10)|Out-File -FilePath .\$TerraformRootFolder\$outputstf -Encoding utf8 -Force
#terraform.tfvars.example
$terraformtfvars=@"
project = "$infra"
public_key_path = "$sshKeysPath"
privat_key_path = "$($sshKeysPath.Replace(".pub",""))"
disk_image = "reddit-base"
region = "europe-west1"
zone = "europe-west1-b"
count = "1"
"@.Split(13).Trim(10)
$terraformtfvars|Out-File -FilePath .\$TerraformRootFolder\terraform.tfvars -Encoding utf8 -Force
$terraformtfvars|Out-File -FilePath .\$TerraformRootFolder\terraform.tfvars.example -Encoding utf8 -Force
#variables.tf
$variablestf="variables.tf"
@'
# Terraform variables
variable "project" {
  type        = "string"
  description = "Project ID"
}

variable "region" {
  type        = "string"
  description = "region"
  default     = "europe-west1"
}

variable "zone" {
  type        = "string"
  description = "region zone"
  default     = "europe-west1-b"
}

variable "public_key_path" {
  type        = "string"
  description = "Path to thee public key used for ssh access"
}

variable "privat_key_path" {
  type        = "string"
  description = "Path to privat key used for provisioner connection"
}

variable "disk_image" {
  type        = "string"
  description = "Disk image"
}

variable "instance_count" {
  type = "string"
  description = "Count instances"
  default = "1"
}
'@.Split(13).Trim(10)|Out-File -FilePath .\$TerraformRootFolder\$variablestf -Encoding utf8 -Force
Get-ChildItem .\$TerraformRootFolder -Filter *.tf|foreach {terraform fmt $_.FullName}

$Location = (Get-Location).Path
Set-Location .\$TerraformRootFolder
terraform taint google_compute_instance.app
terraform destroy -auto-approve=true
terraform plan
terraform apply -auto-approve=true

return
### main.tf
$maintfHead|Out-File -FilePath $TerraformRootFolder\$maintf -Force -Encoding utf8
$maintfIW=(Invoke-WebRequest -Uri https://raw.githubusercontent.com/express42/otus-snippets/master/hw-08/part_of_main.tf -Method Get).Content
$maintfIW|Out-File -FilePath $TerraformRootFolder\$maintf -Append -Force -Encoding utf8
$line = (Select-String -Path $TerraformRootFolder\$maintf -Pattern "/.ssh/").LineNumber|foreach {$_ - 1}
[array]$GMmaintf = Get-Content -Path $TerraformRootFolder\$maintf -Encoding UTF8
Remove-Item -Path $TerraformRootFolder\$maintf -Force

$a=0
for ($i=0;$i -lt $GMmaintf.Count;$i++){

    IF ($GMmaintf[$i] -match "metadata"){
    '#Blocks of type "metadata" are not expected here.'|Out-File -FilePath $TerraformRootFolder\$maintf -Append -Force -Encoding utf8
    '#https://github.com/terraform-providers/terraform-provider-google/issues/3858'|Out-File -FilePath $TerraformRootFolder\$maintf -Append -Force -Encoding utf8
    '#Error: "metadata {" | Ok: "metadata = {"'|Out-File -FilePath $TerraformRootFolder\$maintf -Append -Force -Encoding utf8
    ''|Out-File -FilePath $TerraformRootFolder\$maintf -Append -Force -Encoding utf8
    "  metadata = {"|Out-File -FilePath $TerraformRootFolder\$maintf -Append -Force -Encoding utf8
    
    } ELSEIF ($i -eq $line[$a]){
            IF ($GMmaintf[$i] -like "~/.ssh/appuser.pub"){
                $GMmaintf[$i] -replace "~/.ssh/appuser.pub",$sshKeysPath|Out-File -FilePath $TerraformRootFolder\$maintf -Append -Force -Encoding utf8
            } ELSE {
                $GMmaintf[$i] -replace "~/.ssh/appuser",$sshKeysPath.Replace(".pub","")|Out-File -FilePath $TerraformRootFolder\$maintf -Append -Force -Encoding utf8
            }
        #ssh-keys = "appuser:$('${file("' + $sshKeysPath + '")}"')
        #[regex]::Match($nat_ip_line,"(\d).+[0-9]").Value
        $a++
        } ELSE {
        $GMmaintf[$i]|Out-File -FilePath $TerraformRootFolder\$maintf -Append -Force -Encoding utf8
    }
}

$maintfPuma|Out-File -FilePath $TerraformRootFolder\$maintf -Append -Force -Encoding utf8

<#
Проверяем работу провижинеров
Так как провижинеры по умолчанию запускаются сразу послесоздания ресурса (могут еще запускаться после его удаления),
чтобы проверить их работу нам нужно удалить ресурс VM и создать его снова.
Terraform предлагает команду taint, которая позволяет пометить ресурс, который terraform должен пересоздать, приследующем запуске terraform apply
#>
$Location = (Get-Location).Path
Set-Location .\$TerraformRootFolder
terraform taint google_compute_instance.app
terraform plan
Get-ChildItem -Filter *.tf|foreach {terraform fmt $_.FullName}
#terraform apply -auto-approve=true
#Set-Location $Location


<#
$VpnFolder = 'VPN'

IF(!(Test-Path -Path .\$VpnFolder)){
New-Item -Path .\ -Name $VpnFolder -ItemType Directory -Force
}

Get-ChildItem -Path .\|Where-Object {$_.Extension -eq '.ovpn' -or $_.name -eq 'setupvpn.sh'}|Move-Item -Destination .\$VpnFolder -Force
#>