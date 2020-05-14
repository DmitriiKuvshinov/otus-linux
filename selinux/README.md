# SELINUX
## Как запустить
Выполнить vagrant up. Будет поднят стенд с необходимым софтом.
## Задание 1
### setsebool
Конфиг nginx настроен на порт 9081. Перезапуск демона валится с ошибкой.
Выполним:
```
setsebool -P nis_enabled 1
```
SELINUX применит необходимые правила. Перезапускаем службу. Работает
```
[root@otuslinux conf.d]# netstat -nlp | grep nginx
tcp        0      0 0.0.0.0:9081            0.0.0.0:*               LISTEN      20063/nginx: master 
```
омагад. работает.
### добавление нестандартного порта в имеющийся тип
Проверим порты, доступные для http 
```
semanage port -l
```
Добавим наш порт
```
semanage port -a -t http_port_t -p tcp 9081
```
омагад. работает.
### формирование и установка модуля SELinux
Читаем лог неудачного запуска
```
audit2allow -M httpd_add --debug < /var/log/audit/audit.log
```
Включим модуль
```
semodule -i httpd_add.pp
```
омагад. работает.