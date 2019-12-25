# Home work 1. Packer&Vagrant
## Что было сделано
  - установка packer, vagrant
  - установить vagrant plugin install vagrant-vbguest
  - клонирование репозитория, запуск ВМ в VirtualBox с помощью vagrant
  - запуск ВМ с centos 7. Ручное обновление ядра и загрузчика.
  - Сборка образа ВМ, используя packer и конфиг-файл centos.json. Создание box-файла. Проверка через vagrant
  - выгружен box на vagrant cloud
## Как проверить
  На Vagrant cloud вылит образ [https://app.vagrantup.com/kuvshinov/boxes/centos-7-5]
  Чтобы его запустить необходимо выполнить: 
  ```
  создать тестовую директорию и перейти в нее
  vagrant init kuvshinov/centos-7-5
  vagrant up
  vagrant ssh
  sudo uname -r
  ```
# Home work 2. MDADM
## Что было сделано
 - добавить в Vagrantfile еще дисков
 - собрать R0/R5/R10 на выбор
 - прописать собраннýй рейд в конф, чтобы рейд собирался при загрузке
 - сломать/починить raid
 - создать GPT раздел и 5 партиций и смонтировать их на диск.
 - написан bash скрипт добавления RAID массива, его разметка и добавление 5 разделом с монтированием в /raid/partN

## Как проверить
 - Произвести git-clone. Перейти в директорию репозитория
 - Выполнить vagrant halt && vagrant destroy чтобы остановить и удалить возможно запущенные ВМ
 - выполнить vagrant up, vagrant ssh, cat /proc/mdstat && lsblk
 - ломаем RAID. Фейлим вручную диск: mdadm /dev/md0 --fail /dev/sdb. Проверяем: cat /proc/mdstat. Отвалился первый юнит.
 - чиним RAID. Удаляем сфеленный диск из RAID: mdadm /dev/md0 --remove /dev/sde. Добавляем обратно: mdadm /dev/md0 --add /dev/sdb. Проверяем cat /proc/mdstat

Также, командой mdadm --add /dev/md0 /dev/sdf Можно добавить hot spare диск в массив и при фейле /dev/sdb массив будет восстановлен автоматически.

## mdadm.sh
  Скрипт прописан в Vagrantfile в разделе SHELL, что в свою очередь выполнится при билде ВМ и подключит к ВМ поднятый RAID

# Home work 3. LVM

## Что было сделано
 - Расширение LVM
 - Уменьшение LV
 - LVM Snapshot
 - LVM Mirroring

## Как проверить
 Лог процедур находится тут [https://github.com/DmitriiKuvshinov/otus-linux/blob/homework-3/log/log.md]

# Home work 4. Boot

## Что было сделано
 - Попасть в систему без пароля. Способ 1: добавлāем init=/bin/sh и нажимаем сtrl-x для загрузки в систему (Примечание: необходимо удалить все после объявления ядра системы)
 - Попасть в систему без пароля. Способ 2: добавлāем rd.break и нажимаем сtrl-x для загрузки в систему (Примечание: необходимо удалить все после объявления ядра системы)
 - Попасть в систему без пароля. Способ 3: добавлāем rw init=/sysroot/binsh и нажимаем сtrl-x для загрузки в систему (Примечание: необходимо удалить все после объявления ядра системы)
 - Переименована VolumeGroup
 - Добавлен модуль в initrd. ![Скрин](https://github.com/DmitriiKuvshinov/otus-linux/blob/homework-4/screenshots/Screenshot%202019-11-19%20at%2012.56.01.png)

 # Home work 5. Инициализация системы. Systemd и SysV. 

 ## Что было сделано
  ### Написатþ сервис
    Делаем конфиг файл
    ```
    nano /etc/sysconfig/watchlog
    WORD="HEAD"
    LOG=/var/log/watchlog.log
    ```
    Заменил ALERT на HEAD, т.к. в качестве примера возьму аксес лог nginx
    Создаем скрипт
    ```
  #!/bin/bash
  WORD=$1
  LOG=$2
  DATE=`date`
  logger "$DATE: i'm a live"
  if grep $WORD $LOG &> /dev/null
    then
    logger "$DATE: I found word, Master!"
    else
    exit 0
  fi
    ```
    Создаем юниты таймера и службы мониторинга лога
    ```
    nano /etc/systemd/system/watchlog.timer

  [Unit]
    Description=Run watchlog script every 30 second
  [Timer]
    # Run every 30 second
    OnCalendar=*:*:0/30
    Unit=watchlog.service
  [Install]
    WantedBy=multi-user.target

    nano /etc/sysconfig/watchlog.service

  [Unit]
    Description=My watchlog service
  [Service]
    Type=oneshot
    EnvironmentFile=/etc/sysconfig/watchdog
    ExecStart=/opt/watchlog.sh $WORD $LOG
    ```
Запускаем юнит 
```
systemctl start watchdog.timet
```
Получаем ![Скрин](https://github.com/DmitriiKuvshinov/otus-linux/blob/homework-5/screenshots/Screenshot%202019-11-21%20at%2012.14.12.png)
 ### httpd

Установим 
```
yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y
```
Изменяем конфиг, создаем юнит. Запускаемся и проверям
```
[root@otuslinux ~]# systemctl status spawn-fcgi
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
   Active: active (running) since Чт 2019-11-21 09:17:08 UTC; 5s ago
 Main PID: 3946 (php-cgi)
   CGroup: /system.slice/spawn-fcgi.service
           ├─3946 /usr/bin/php-cgi
           ├─3947 /usr/bin/php-cgi
           ├─3948 /usr/bin/php-cgi
           ├─3949 /usr/bin/php-cgi
           ├─3950 /usr/bin/php-cgi
           ├─3951 /usr/bin/php-cgi
           ├─3952 /usr/bin/php-cgi
           ├─3953 /usr/bin/php-cgi
           ├─3954 /usr/bin/php-cgi
           ├─3955 /usr/bin/php-cgi
           ├─3956 /usr/bin/php-cgi
           ├─3957 /usr/bin/php-cgi
           ├─3958 /usr/bin/php-cgi
           ├─3959 /usr/bin/php-cgi
           ├─3960 /usr/bin/php-cgi
           ├─3961 /usr/bin/php-cgi
           ├─3962 /usr/bin/php-cgi
           ├─3963 /usr/bin/php-cgi
           ├─3964 /usr/bin/php-cgi
           ├─3965 /usr/bin/php-cgi
           ├─3966 /usr/bin/php-cgi
           ├─3967 /usr/bin/php-cgi
           ├─3968 /usr/bin/php-cgi
           ├─3969 /usr/bin/php-cgi
           ├─3970 /usr/bin/php-cgi
           ├─3971 /usr/bin/php-cgi
           ├─3972 /usr/bin/php-cgi
           ├─3973 /usr/bin/php-cgi
           ├─3974 /usr/bin/php-cgi
           ├─3975 /usr/bin/php-cgi
           ├─3976 /usr/bin/php-cgi
           ├─3977 /usr/bin/php-cgi
           └─3978 /usr/bin/php-cgi

ноя 21 09:17:08 otuslinux systemd[1]: Started Spawn-fcgi startup service by Otus.
ноя 21 09:17:08 otuslinux systemd[1]: Starting Spawn-fcgi startup service by Otus...
```
Запустим 2 юнита httpd. Создаем конфиги в /etc/sysconfig и /etc/httpd/conf
Копируем юнит и изменим параметр EnvironmentFile=/etc/sysconfig/httpd-%I
```
cp /usr/lib/systemd/system/httpd.service /etc/systemd/system/httpd@.service
```
Стартуем
```
[root@otuslinux conf]£ systemctl start httpd@first
[root@otuslinux conf]£ systemctl start httpd@second
[root@otuslinux conf]£ ss -tnulp | grep httpd
tcp    LISTEN     0      128      :::8080                 :::*                   users:(("httpd",pid=3886,fd=4),("httpd",pid=3885,fd=4),("httpd",pid=3884,fd=4),("httpd",pid=3883,fd=4),("httpd",pid=3882,fd=4),("httpd",pid=3881,fd=4),("httpd",pid=3880,fd=4))
tcp    LISTEN     0      128      :::80                   :::*                   users:(("httpd",pid=3873,fd=4),("httpd",pid=3872,fd=4),("httpd",pid=3871,fd=4),("httpd",pid=3870,fd=4),("httpd",pid=3869,fd=4),("httpd",pid=3868,fd=4),("httpd",pid=3867,fd=4))
[root@otuslinux conf]£ 
```

# Home Work 6.  Скрипты

Файл с логами из личного кабинета находится тут [https://github.com/DmitriiKuvshinov/otus-linux/tree/homework-6/log]
Скрипты с выполнением заданий тут [https://github.com/DmitriiKuvshinov/otus-linux/tree/homework-6/scripts]

## Задание 1. X IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
### Как работает: 
скрипт перемещает текущий лог-файл в директорию со скриптом, парсит файл, выводит на экран результат+логирует результат. Перемещенный лог-файл будет пересоздан


## Задание 2. Y запрашиваемых адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
### Как работает: 
механизм из первого задания, только меняем фильры


## Задание 3. Все ошибки c момента последнего запуска
### Как работает: 
 - получим коды ошибок веб-сервера: wget http://allerrorcodes.ru/http-2/
 - пропарсим файлик index.html: cat index.html | grep col-code | sed -e 's/[^0-9]//g'
 - удаляем все статусы до 400


## Задание 4. Список всех кодов возврата с указанием их кол-ва с момента последнего запуска
### Как работает: 
механизм из первого задания, только меняем фильтры

Отправка на почта функцией sendamil. Лог писем смотрим тут: /var/mail/root
Блокировка от мультизапуска: срздаем lock файл и при каждом запуске скрипта проверяем его наличие

# Home work 7. RPM пакеты

## Что было сделано
Создан bash скрипт, который устанавливает необходимый (измененный) софт при инициализации ВМ

## Как проверить

Запустить vagrant up. Зайти в ВМ, выболнить sudo systemctl start nginx && systemctl status nginx

## *
Подготовим Docker файл
Заранее был подготовлен rpm пакет (из предыдущего задания) и установим его в контейнер при билде
Как проверить:
docker run -it kuvshinov/crm /bin/bash
/usr/sbin/nginx
lsof -i

(!HubDocker)[https://hub.docker.com/repository/docker/kuvshinov/rpm]

# Home work 8. Управление процессами

## Что было сделано: написать свою реализацию ps ax используя анализ /proc

ps ax выводиит 5 параметров: PID, TTY, State, CPU Time, Command
Забираем все эти параметры в цикле из /proc/{stat,status.cmdline}
Сложности возникли с CPU Time, поскольку в proc указывается велечина в процессорных тактах

## Как проверить
запустить скрипт: scripts/ps/1.sh

# Homw work 9. Docker
## Ответы
Образ - RO шаблон для создания контейнера. Создается и изменяться через Dockerfile (или берется из dockerhub).
Контейнер - создается из шаблона образа. Контейнер можно вертеть как хочешь
В контейнере можно собрать ядро, можно скомпилировать любое другое приложение, так же можно собирать пакеты.

## Что было сделано
Написан  Dockerfile, в котором происходит загрузка образа, копирование кастомной странички index.html в рут директорию веб-сервера

## Как проверить
Выполнить команду: docker run -d -p 100:80 kuvshinov/hw9
Открыть в браузере ссылку: http://localhost:100

## *

Написан docker-compose файлик, который поднимает nginx+php-fpm из ранее подготовленных образов

## Как проверить:
Скачать директорию: https://github.com/DmitriiKuvshinov/otus-linux/tree/homework-9/docker/docker-nginx-php
Запустить docker-compose up -d
Перейти в браузере по ссылке: http://localhost

# Home Work 10. Ansible 

## Что было сделано
 [https://github.com/DmitriiKuvshinov/otus-linux/tree/homework-10/ansible]
Конфигурируем ansible: inventory файл содержит информацию о хостах и способе подклчюения к ним
templates - шаблоны конфигураций
playbooks - ямль файлы с задачами для выполнения при помощи ansible

Для работы был взят стенд из личного кабинета с 2-мя хостами
Запускаем ansible-playbook с командой --limit (т.к. в плейбуках казаны все хосты)
Например: ansible-playbook playbooks/nginx.yml --limit host1
После делаем curl запрос: curl http://localhost:8080

## Как проверить
В директории ansible выполнить vagrant up
После выполнить: ansible-playbook playbooks/nginx.yml --limit host1

 ## *
 Inventory используем из прошлого задания
 Для организации хранения ролей применим ansible-galaxy. В директории roles выполним ansible-galaxy init nginx
 После выполнения команды будет создана иерархия папок
 ```
 minint-jtgafr6:roles dmitrii$ tree nginx/
nginx/
├── README.md
├── defaults
│   └── main.yml
├── files
├── handlers
│   └── main.yml
├── meta
│   └── main.yml
├── tasks
│   └── main.yml
├── templates
├── tests
│   ├── inventory
│   └── test.yml
└── vars
    └── main.yml
 ```

 Кратко:
 defaults - содержит перечень дефолтных настроек роли. В нашем случае - порт
 tasks - содержит задания по установке nginx и копированию файла конфигурации
 handlers - содержит команды для перезапуска/перезагрузки сервиса
 templates - содержит конфиг для nginx

 Как проверить.
 Убиваем тестовый стенд и поднимаем чистый. Выполняем ansible-playbook nginx_role.yml --check (для проверки синтаксиса). ansible-playbook nginx_role.yml - для применения изменений
 Проверяем: curl http://192.168.11.151:8080
 ```
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <title>Welcome to CentOS</title>
  <style rel="stylesheet" type="text/css"> 
...
```
 # Home Work 11. Мониторинг и алертинг

 ## Что было сделано:
 На текущей инфраструктуре уже установлена и настроена связка zabbix + grafana. Zabbix включает в себя дополнительные шаблоны и проверки (SNMP мониторинг уровня тонера в картриджах, опрос SSL сертификатов сайтов на дату окончания с отчетами, и другие проверки).

 ## Как проверить:
 В папке screenshots размещены 2 скрина: zabbix и grafana. При необходимости могу дополнить

# Home Work 12. PAM
* Какие UID создались у пользователей? - 1001, 1002
[root@otuslinux ~]# cat /etc/passwd | grep user
rpcuser:x:29:29:RPC Service User:/var/lib/nfs:/sbin/nologin
user1:x:1001:1001::/home/user1:/bin/bash
user2:x:1002:1002::/home/user2:/bin/bash

-m, --create-home, Create the user's home directory
-s, --shell SHELL, The name of the user's login shell
Аналогом можно использовать adduser без дополнительных ключей

## Создаем группу и добавляем туда пользователей
[root@otuslinux ~]# id user1
uid=1001(user1) gid=1001(user1) groups=1001(user1),1003(admins)
[root@otuslinux ~]# id user2
uid=1002(user2) gid=1002(user2) groups=1002(user2),1003(admins)
* Через usermod сделайте группу admins основной для  user1
```
[root@otuslinux ~]# usermod -g admins user1
[root@otuslinux ~]# id user1
uid=1001(user1) gid=1003(admins) groups=1003(admins)
```

## Создать каталог от рута и дать права группе admins туда писать
* что означают права 770 ? - разрешения на чтение, запись и выполнение, предоставленные как обычному пользователю, так и владельцу группы файла.
* проверьте с какой группой создались файлы от каждого пользователя. Как думаете - почему? - потому что команда touch выполнялась от имени другого пользователя.
```
[root@otuslinux upload]# ll
total 0
-rw-r--r--. 1 user1 admins 0 дек 25 09:42 user1
-rw-r--r--. 1 user2 user2  0 дек 25 09:42 user2
```

## Создать пользователя user3 и дать ему права писать в /opt/uploads
```
[root@otuslinux upload]# getfacl /opt/upload
getfacl: Removing leading '/' from absolute path names
# file: opt/upload
# owner: root
# group: admins
user::rwx
user:user3:rwx
group::rwx
mask::rwx
other::---
[root@otuslinux upload]# sudo -u user3 touch user3
[root@otuslinux upload]# ll
total 0
-rw-r--r--. 1 user1 admins 0 дек 25 09:42 user1
-rw-r--r--. 1 user2 user2  0 дек 25 09:42 user2
-rw-r--r--. 1 user3 user3  0 дек 25 09:47 user3
```

## Установить GUID флаг на директорию /opt/uploads
```
[root@otuslinux upload]# sudo -u user3 touch user3_1
[root@otuslinux upload]# ls -la
total 0
drwxrws---+ 2 root  admins 60 дек 25 09:48 .
drwxr-xr-x. 4 root  root   53 дек 25 09:40 ..
-rw-r--r--. 1 user1 admins  0 дек 25 09:42 user1
-rw-r--r--. 1 user2 user2   0 дек 25 09:42 user2
-rw-r--r--. 1 user3 user3   0 дек 25 09:47 user3
-rw-r--r--. 1 user3 admins  0 дек 25 09:48 user3_1
```
chmod g+s устанавливает идентификатор группы (setgid) в текущем каталоге

## Установить  SUID  флаг на выполняемый файл
```
[root@otuslinux upload]# sudo -u user3 cat /etc/shadow 
cat: /etc/shadow: Permission denied       
[root@otuslinux upload]# chmod u+s /bin/cat
[root@otuslinux upload]# sudo -u user3 cat /etc/shadow 
root:$1$QDyPlph/$oaAX/xNRf3aiW3l27NIUA/::0:99999:7:::
bin:*:17834:0:99999:7:::
daemon:*:17834:0:99999:7:::
adm:*:17834:0:99999:7:::
lp:*:17834:0:99999:7:::
sync:*:17834:0:99999:7:::
shutdown:*:17834:0:99999:7:::
halt:*:17834:0:99999:7:::
mail:*:17834:0:99999:7:::
operator:*:17834:0:99999:7:::
games:*:17834:0:99999:7:::
ftp:*:17834:0:99999:7:::
nobody:*:17834:0:99999:7:::
systemd-network:!!:18048::::::
dbus:!!:18048::::::
polkitd:!!:18048::::::
rpc:!!:18048:0:99999:7:::
rpcuser:!!:18048::::::
nfsnobody:!!:18048::::::
sshd:!!:18048::::::
postfix:!!:18048::::::
chrony:!!:18048::::::
vagrant:$1$C93uBBDg$pqzqtS3a9llsERlv..YKs1::0:99999:7:::
vboxadd:!!:18255::::::
user1:!!:18255:0:99999:7:::
user2:!!:18255:0:99999:7:::
user3:!!:18255:0:99999:7:::
```
Если SUID бит установлен на файл и пользователь выполнил его. Процесс будет иметь те же права что и владелец файла.

##  Сменить владельца  /opt/uploads  на user3 и добавить sticky bit
* Объясните почему user3 смог удалить файл, который ему не принадлежит - user3 является владельцем директории. делаю что хочу
* Создайте теперь файл от user1 и удалите его пользователем user1 - удалит. user1, создал, может и удалить.
* Объясните результат. Фокус с user2  не пройдет, поскольку он не является ни владельцем директории, ни создателем файла.

## Записи в sudoers
* почему у вас не получилось? - необходимо ввести пароль для user3. Т.к. он не является члоеном группы sudo
* добавьте запись в /etc/sudoers.d/admins разрешающий группе admins любые команды с вводом пароля - %admins ALL=(ALL) ALL

## Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников

nano /etc/security/time.conf
login ; * ; !admins ; SaSu0000-2400 - запрещаем login для всех пользователей кроме группы admins (!admins) логин в выходные дник (SaSu0000-2400)

Добваляем в /etc/pam.d/login в конце:
account    required     pam_time.so