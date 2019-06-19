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
self.assertEqual(1, 1)
```