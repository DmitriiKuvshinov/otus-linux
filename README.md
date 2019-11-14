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
 • добавить в Vagrantfile еще дисков
 • собрать R0/R5/R10 на выбор
 • прописать собраннýй рейд в конф, чтобы рейд собирался при загрузке
 • сломать/починить raid
 • создать GPT раздел и 5 партиций и смонтировать их на диск.
 • написан bash скрипт добавления RAID массива, его разметка и добавление 5 разделом с монтированием в /raid/partN

## Как проверить
 • Произвести git-clone. Перейти в директорию репозитория
 • Выполнить vagrant halt && vagrant destroy чтобы остановить и удалить возможно запущенные ВМ
 • выполнить vagrant up, vagrant ssh, cat /proc/mdstat && lsblk

## mdadm.sh
  Скрипт прописан в Vagrantfile в разделе SHELL, что в свою очередь выполнится при билде ВМ и подключит к ВМ поднятый RAID

