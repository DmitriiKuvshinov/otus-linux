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

## Задание 1. X IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
### Как работает: скрипт перемещает текущий лог-файл в директорию со скриптом, парсит файл, выводит на экран результат+логирует результат. Перемещенный лог-файл будет пересоздан

Как проверить: запустить скрипт 1.sh

## Задание 2. Y запрашиваемых адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
### Как работает: механизм из первого задания. 

Как проверить: запустить скрипт 2.sh

## Задание 3. Все ошибки c момента последнего запуска
### Как работает: 
 - получим коды ошибок веб-сервера: wget http://allerrorcodes.ru/http-2/
 - пропарсим файлик index.html: cat index.html | grep col-code | sed -e 's/[^0-9]//g'
 - удаляем все статусы до 400
 Как работает: используется механизм из предыдущих заданий, только грепаем файлик с ошибками. И если находится статус, то пишем фул-лайн в отдельный файлик

 Как проверить: запустить скрипт 3.sh

## Задание 4. Список всех кодов возврата с указанием их кол-ва с момента последнего запуска
### Как работает: механизм из первого задания. 

Как проверить: запустить скрипт 4.sh

