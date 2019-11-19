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
