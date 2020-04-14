# VPN
## Как запуститься
### Задание 1
1. Выполнить vagrant up. Поднимется стенд с 2 ВМ (client+server). Выполнить vagrant ssh-config и сверить настройки с inventory файлом.
3. Выполнять ansible-playbook server.yml - настроится VPN сервер
4. Выполнить ansible-playbook client.yml - настроится client VPN
5. Запустить на ВМ server: iperf3 -s
6. Запустить на ВМ cleint: iperf3 -c 10.10.10.1 -t 40 -i 5

Резлутаты: при использовании tun интерфейса скорость передачи данных значительно выше, посльку работа tun основана на сетевой модели OSI, tap - канальный. Из-за того, что tun оперирует только маршрутизацией, а не кадрами Ethernet, то кол-во передаваемых пакетов за единицу времени увеличивается. (скриншоты замеров в директории)

### Задание 2
1. Выполнить vagrant up server. Поднимется стенд с 1 ВМ (server). Выполнить vagrant ssh-config и сверить настройки с inventory файлом.
2. Выполнять ansible-playbook ras-server.yml - выполнится настройка сервера 
3. Зайти на server и выполнить скрипт: /vagrant/ras.sh из под рута
4. Копируем файлы (запускаем команды с хост машины. не забыть поправить пути до приватных ключей):
```
scp -P 2222 -i /Users/dmitrii/Documents/otus/otus-linux/homework-19/.vagrant/machines/server/virtualbox/private_key vagrant@127.0.0.1:/tmp/ca.crt ras/
scp -P 2222 -i /Users/dmitrii/Documents/otus/otus-linux/homework-19/.vagrant/machines/server/virtualbox/private_key vagrant@127.0.0.1:/tmp/client.crt ras/
scp -P 2222 -i /Users/dmitrii/Documents/otus/otus-linux/homework-19/.vagrant/machines/server/virtualbox/private_key vagrant@127.0.0.1:/tmp/client.key ras/
```
5. Поднимем клиента: vagrant up client
6. Настроим client: ansible-playbook ras-client.yml
7. Подключаемся к клиенту: vagrant ssh client
8. Запускаем: openvpn --config /vagrant/ras-client.conf &
9. Проверяем: ping 10.10.10.1

win =)