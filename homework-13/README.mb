## Создадим инфраструктуру через Vagrantfile
Поднимаем 2 машины: клиент и сервер

## Borg

Скачиваем бинарник и складываем его в /usr/bin и даем права на выполнение
```
wget https://github.com/borgbackup/borg/releases/download/1.1.10/borg-linux64 -O /usr/bin/borg
chmod +x /usr/bin/borg
```
Пропишем в hosts адреса ВМ для клиента и сервера. На сервере создадим директории:
```
mkdir -p /home/borg/backup/full/
mkdir -p /home/borg/backup/10min/
mkdir -p /home/borg/backup/30min/
```
Приступаем к выполнению ДЗ:
## full backup 1 раз в день
Пишем скрипт:
```
#!/bin/bash

borg init -e none borg@server:backup/full/$(date +%A)

borg delete borg@server:backup/full/$(date +%A)/::"full-etc"

borg create --stats borg@server:backup/full/$(date +%A)/::"full-etc" /etc
```
 Ротация архивов происходит по дням недели

Архивы каждые 10 и 30 минут делаем аналогичным образом:
```
#!/bin/bash

date=$(date +"%H:%M-%m-%d-%Y")

borg init -e none borg@server:backup/$1min

borg prune -v --show-rc --list borg@server:backup/$1min --keep-last=12

borg create --stats borg@server:backup/$1min::"$1min-etc-$date" /etc
```
Запуск скрипта делаем с параметром (30 или 10 минут, в зависимости что нужно). Например: inc.sh 10 или inc.sh 30

Создадим cron-job

```
*/10 * * * * root/root/inc.sh 10 > /dev/null 2>&1
*/30 * * * * root /root/inc.sh 30 > /dev/null 2>&1
0 1 * * *    root /root/full.sh 30 > /dev/null 2>&1
```

Для теста оставил последние 2 бэкапа. 
```
[root@client ~]# borg list borg@server:backup/full/Friday
full-etc                             Fri, 2020-01-24 01:00:17 [ce2b1387997ecf8d5c1a7b2353a1b42fb7b7342e57d1edefe415a595195f0beb]

[root@client ~]# borg list borg@server:backup/10min
10min-etc-06:10-01-24-2020           Fri, 2020-01-24 06:10:07 [fd7968a88ad281e80191c80e664e16611b5ff2139dedb2594aa4dd02e70b7b55]
10min-etc-06:20-01-24-2020           Fri, 2020-01-24 06:20:07 [fb0ee4d9729a456d7cfc374ff6cb98437787241646926340f245a29a01d640d2]
10min-etc-06:30-01-24-2020           Fri, 2020-01-24 06:30:13 [432fac1448306470a7bff4158d4a5420baf9a25ef263b398636aca9dc9c4307d]

[root@client ~]# borg list borg@server:backup/30min
30min-etc-05:30-01-24-2020           Fri, 2020-01-24 05:30:12 [b89db32dbd19cad2a0305750450d6c5ba0044f94a0bcc14bd0571a4426ace7da]
30min-etc-06:00-01-24-2020           Fri, 2020-01-24 06:00:13 [7446ef09a5e57ccfd858e7d3e96353eb8d4f800030699cce6cc49edc3194913e]
30min-etc-06:30-01-24-2020           Fri, 2020-01-24 06:30:13 [ed3f5927de15e17a73d516291b2c593411ff4a96709baf1d5142aca44c2ac246]
```