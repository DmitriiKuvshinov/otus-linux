# Филтрация трафика
## Как запуститься
1. Выполнить vagrant up. Поднимется стенд с 4 ВМ. Для inetRouter2 дополнительно пробрасывается порт 8080 средствами virtualbox
2. Поправить inventory файл (изменить порты и путь до ключей)
3. Выполнить ansible-playbook nginx.yml - плейбук установит nginx на centralServer
4. Выполнить ansible-playbook iptables-apply.yml - плейбук применит необходимы правила iptables для knock порт

## Как проверить
1. запустить на centralRouter knock.sh скрипт. сделать telnet на 22 порт. подождать 30 секунд. повторить команду telnet
2. 