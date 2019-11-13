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

