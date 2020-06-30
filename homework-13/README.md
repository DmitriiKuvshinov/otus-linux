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
mkdir -p /home/borg/backup/hourly/{1..12}
```
Приступаем к выполнению ДЗ:
## full backup 1 раз в час
Пишем скрипт:
```
#!/bin/bash
# Получаем день
date=$(date +%d) 
# Получаем час
time=$(date +%H)
# Получаем месяц
m=$(date +%-m)
# Получаем месяц -1
m1=$(date '+%-m' --date='-1 month')
# Получаем месяц -2
m2=$(date '+%-m' --date='-2 month')
borg init -e none borg@server:backup/hourly/"$m"/ 2> /var/log/borg/"$date.$time".log
borg delete borg@server:backup/hourly/"$m"/::"full-etc-$date-$time" 2>> /var/log/borg/"$date.$time".log
borg create --stats borg@server:backup/hourly/"$m/"::"full-etc-$date-$time" /etc 2>> /var/log/borg/"$date.$time".log
if [[ $date -eq 28 ]]; then
	borg prune -v --show-rc --list borg@server:backup/hourly/$m1 --keep-last=1 2>> /var/log/borg/"$date.$time".log
	borg prune -v --show-rc --list borg@server:backup/hourly/$m2 --keep-last=1 2>> /var/log/borg/"$date.$time".log
	echo "prune"	
fi
```
Создадим cron-job

```
* */1 * * * root  /root/backup.sh > /dev/null 2>&1
```

Для теста создадим файл в директории /etc/123. Сделаем бэкап. Удалим файл и пробуем восстановить
Смотри бэкапы: 
```
[root@client etc]# borg list borg@server:backup/hourly/6
full-etc-30-17                       Tue, 2020-06-30 17:46:25 [2d4bf6f01c5dbf235157f4124633507c52a20703ae17cc3acd234b97164f468f]
```
Создадим директорию для монтирования и приступаем:
```
mkdir -p /mnt/backup
borg mount borg@server:backup/hourly/6::full-etc-30-17 /mnt/backup/
```
Копируем из бэкапа нужный файл:
```
cp /mnt/backup/etc/123 /etc/
```
Отмонтируем:
```
borg umount /mnt/backup/
```
Вуаля. готово