# ASMalyshev1_infra
ASMalyshev1 Infra repository

## Основы Git.Домашнее задание
В данном домашнем задании было сделано:
- Добавлен функционал использования Pull Request Template
- Интеграция Slack с github
- Интеграция Репозитория и Slack с travis

### Использование Pull Request Template
Pull Request Template - это технология github для шаблонизироания Pull Request'а (PR).
Для его использования, необходимо в корне проекта создать папку `.github`, в которую поместить шаблон с именем `PULL_REQUEST_TEMPLATE.md`

### Интеграция Slack с github
Для интеграции slack с github Для начала необходимо добавить приложение github в slack. [Инструкция](https://get.slack.help/hc/en-us/articles/232289568-GitHub-for-Slack)
Далее, создать канал в собственном WorkSpace (asmalyshev.slack.com) d slack (мой канал: #aleksey_malyshev), после чего выполнить команаду:
```git bash
    /github subscribe Otus-DevOps-2019-05/ASMalyshev1_infra commits:all
```
### Интеграция репозитория и slack с travis
Для использования travis, необходимо в корень репозитория добавить файл `.travis.yml`, в котором описать инструкции по запуску сборки travis.
Для интеграции со slack необходимо добавить в slack приложение Travis CI, выбрать канал для уведомлений и сгенерировать токен.
Для обеспечения безопасности, данный токен необходимо зашифровать. Это можно сделать с помощью утилиты travis.
Инструкция по интеграции со slack (для Windows 10 1903):
1. Качаем ruby для Windows https://rubyinstaller.org/downloads/
2. Открываем консоль Ruby и вводим комманду для установки Travis:

```ruby cmd
gem install travis
```

3. Необходимо авторизоваться через github на сайте [travis](https://travis-ci.com)
4. Авторизуемся чезер утилиту travis

```cmd
travis login --com
```

5. Теперь зашифруем токен с помощью утилиты travis. Мы должны находиться в папке с нашим репозиторием и в нем должен присутствовать файл `.travis.yml`

```shell
cd ~\GitHub\ASMalyshev1_infra
travis encrypt "devops-team-otus:<ваш_токен>#aleksey_malyshev" \
--add notifications.slack.rooms --com
```

13. travis автоматически добавит в файл `.travis.yml` шифрованый токен для уведомлений в slack. Остается только закоммитить изменения в файле.

### Самостоятельная работа (Добиться устпешного билда)
В файле `play-travis/test.py` была допущена ошибка в 6 строке.

```python
self.assertEqual(1 + 1, 1)
```
Эта функция всегда будет возвращать false по скольку, проверяем равнество 2-х чисел. В данном случае 2 != 1.
Необходимо исправить эту строку приведя её к виду:

```python
self.assertEqual(1 + 1, 2)
```

### Знакомство с облачной инфраструктурой. Google Cloud Platform
1. Регистрируемся на Google Cloud Platform https://cloud.google.com/free/
2. Создаем проект infra
3. Переходим в раздел Compute Engine -> Метаданные -> SSH-Ключи -> "Добавить SSH-ключи"
4. Генерируем SSH ключи в Git Bash

$ ssh-keygen -t rsa -f ~/.ssh/appuser -C appuser -P ""
Generating public/private rsa key pair.
Created directory '/c/Users/asmalyshev/.ssh'.
Your identification has been saved in /c/Users/asmalyshev/.ssh/appuser.
Your public key has been saved in /c/Users/asmalyshev/.ssh/appuser.pub.
The key fingerprint is:
SHA256:jV5LPDeDFUnV8WQrPKoR3reCAVPFUhf+KxfwPp67xOc appuser
The key's randomart image is:
+---[RSA 3072]----+
|         .++o=oo+|
|        .. .=. o+|
|       o .. .* ..|
|        ++oo. *  |
|        S+Bo+. + |
|       . o=+.o+ o|
|        .o.. o B.|
|            . =.+|
|               =E|
+----[SHA256]-----+

5. переходим в папку C:\Users\asmalyshev\.ssh\ и открываем файл appuser.pub
6. Копируем содержимое и сохраняем на открытой ранее страницы (пункт 3.)
7. Переходим в раздел "Экземпляры ВМ" и нажимаем создать

	Вбиваем имя хоста: bastion
	Зона: europe*
	Тип машины: микромашина
	Загрузочный диск: Ubuntu 16.04 LTS
	Оснавная сеть: default
	Внешний IP: Создать адрес
	Название адреса: bastion

8. Проверяем подключение к нашей VM Bastion по SSH ключу

```git bash
$ ssh -i ~/.ssh/appuser appuser@35.228.30.234
The authenticity of host '35.228.30.234 (35.228.30.234)' can't be established.
ECDSA key fingerprint is SHA256:jirOIo+e5xoFlOkUHerc5L/OtRnJpWthcLNbECtakF0.
Are you sure you want to continue connecting (yes/no/[fingerprint])? Y
Please type 'yes', 'no' or the fingerprint: yes
Warning: Permanently added '35.228.30.234' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 16.04.6 LTS (GNU/Linux 4.15.0-1034-gcp x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

0 packages can be updated.
0 updates are security updates.



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.
```

9. Повторяем создание VM (пункт 7), но без внешней сети

	Вбиваем имя хоста: someinternalhost
	Зона: europe*
	Тип машины: микромашина
	Загрузочный диск: Ubuntu 16.04 LTS
	Оснавная сеть: default
	Внешний IP: нет
	
10. Подключаемся к bastion и с него пробуем попасть на someinternalhost

```git bash
$ ssh -i ~/.ssh/appuser appuser@35.228.30.234

$ ssh -i ~/.ssh/appuser appuser@10.166.0.3
Warning: Identity file /home/appuser/.ssh/appuser not accessible: No such file or directory.
The authenticity of host '10.166.0.3 (10.166.0.3)' can't be established.
ECDSA key fingerprint is SHA256:mygN8QGdR/6+OAXsmaQHmOWELmFuo9umY+4HTWtNCfs.
Are you sure you want to continue connecting (yes/no)? yes
Please type 'yes' or 'no': yes
Warning: Permanently added '10.166.0.3' (ECDSA) to the list of known hosts.
Permission denied (publickey).
appuser@bastion:~$

ssh-add -L
Could not open a connection to your authentication agent.

# Windows 10:

# start the ssh-agent in the background
ssh-agent -s
# Agent pid 1312

# start the ssh-agent in the background
eval $(ssh-agent -s)
# Agent pid 1312

ssh-add ~/.ssh/appuser
ssh -i ~/.ssh/appuser -A appuser@35.228.30.234
ssh -i ~/.ssh/appuser appuser@10.166.0.3
appuser@someinternalhost:~$ hostname
someinternalhost

```

bastion_IP = 35.228.30.234
someinternalhost_IP = 10.166.0.3
bastion_dns = bastion.asmalyshev.ru


    Подключение в одну команду из консоли Два способа реализации: 
	
	1 Способ прыжком с доступного хоста на изолированный: ssh -J bastion_IP someinternalhost_IP попадаем через наш внешний хост 35.228.30.234 на изолированный хост 10.166.0.3
    2 Способ подключения к изолированному инстансу через тунель: ssh -tA work@bastion_IP ssh work@someinternalhost_IP используем тунелирование -t для доступа к хосту в изолированной подсети через доступный хост с маршрутизированным IP

ssh -tA work@35.228.30.234 ssh work@10.166.0.3

$ ssh -i ~/.ssh/appuser -tA appuser@35.228.30.234 ssh appuser@10.166.0.3

Для подключения по алиасу можно добавить запись /etc/hosts на сервере bastion 10.166.0.3 someinternalhost

## 6 Основные сервисы Google Cloud Platform (GCP).Домашнее задание

1. Создайть новую ветку "cloud-testapp" в D:\GitHub\ASMalyshev1_infra

2. Перенесите файлы .ovpn и setupvpn.sh, созданные в прошлом ДЗ в директорию D:\GitHub\ASMalyshev1_infra\VPN

``` PS
Clear-Host
Set-Location $PSScriptRoot

$VpnFolder = 'VPN'

IF(!(Test-Path -Path .\$VpnFolder)){
New-Item -Path .\ -Name $VpnFolder -ItemType Directory -Force
}

Get-ChildItem -Path .\|Where-Object {$_.Extension -eq '.ovpn' -or $_.name -eq 'setupvpn.sh'}|Move-Item -Destination .\$VpnFolder -Force
```

3. Добавьте созданные в ходе работы скрипты в эту ветку ("cloud-testapp") в корень репозитория (.\);
Добавить информацию о ДЗ в README.md и вписать данные для подключения в следующем формате(важно для автоматической проверки ДЗ),не удаляя предыдущую:

testapp_IP = 35.228.8.62
testapp_port = 9292

#Проверка ДЗ

Создать Pull Request для ветки мастер, добавить "Labels" GCP и cloud-testapp к нему.

1. Устанавливаем Google Cloud SDK
```
https://cloud.google.com/sdk/docs/#install_the_latest_cloud_sdk_version
```
gcloud auth list

``` PS
Clear-Host

[array]$IW = Invoke-WebRequest -Uri https://gist.githubusercontent.com/Nklya/5bc429c6ca9adce1f7898e7228788fe5/raw/01f9e4a1bf00b4c8a37ca6046e3e4d4721a3316a/gcloud -Method Get

(-split $IW.Content) -replace "\\" -join " "

```
# Создаем VM "reddit-app"
```
gcloud compute instances create reddit-app --boot-disk-size=10GB  --image-family ubuntu-1604-lts  --image-project=ubuntu-os-cloud  --machine-type=g1-small  --tags puma-server  --restart-on-failure
```
# Добавляем SSH ключ
```
gcloud compute instances add-metadata reddit-app --metadata-from-file ssh-keys="C:\Users\asmalyshev\.ssh\appuser.pub"
```
# Подключаемся к VM "reddit-app"
```
ssh -i ~/.ssh/appuser appuser@35.228.8.62
```
#Обновляем APT, устанавливаем Ruby и Bundler:
```
sudo apt update
sudo apt install -y ruby-full ruby-bundler build-essential

ruby -v
ruby 2.3.1p112 (2016-04-26) [x86_64-linux-gnu]

bundler -v
Bundler version 1.11.2
```
#Устанавливаем MongoDB
```
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
sudo bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
```
#Обновим индекс доступных пакетов и установим нужный пакет
```
sudo apt update
sudo apt install -y mongodb-org
```
#Устанавливаем MongoDB
```
sudo systemctl start mongod
sudo systemctl enable mongod
```
#Проверяем работу MongoDB
```
sudo systemctl status mongod
```
```
Created symlink from /etc/systemd/system/multi-user.target.wants/mongod.service to /lib/systemd/system/mongod.service.
appuser@reddit-app:~$ sudo systemctl status mongod
● mongod.service - High-performance, schema-free document-oriented database
   Loaded: loaded (/lib/systemd/system/mongod.service; enabled; vendor preset: e
   Active: active (running) since Tue 2019-06-25 19:08:45 UTC; 1min 3s ago
     Docs: https://docs.mongodb.org/manual
 Main PID: 8977 (mongod)
   CGroup: /system.slice/mongod.service
           └─8977 /usr/bin/mongod --quiet --config /etc/mongod.conf

Jun 25 19:08:45 reddit-app systemd[1]: Started High-performance, schema-free doc
```

#Деплойп риложения
```
git clone -b monolith https://github.com/express42/reddit.git
```
#Переходим в директорию проекта и устанавливаем зависимости приложения
```
cd reddit && bundle install
```
#Запускаем сервер приложения в папке проект
```
puma -d
```
#Проверьте, что сервер запустился и на каком порту он слушает
```
ps aux | grep puma
```
```
appuser   9698  0.7  1.5 515380 26776 ?        Sl   19:12   0:00 puma 3.10.0 (tcp://0.0.0.0:9292) [reddit]
appuser   9712  0.0  0.0  12944  1012 pts/0    S+   19:13   0:00 grep --color=auto puma
```
