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

## Задание 2
Запускаем стенд. Попадаем на клиента, выполняем команду. Получаем ServFail
Идем на сервер (ns01).
Смотри лог:
```
Jun 30 11:53:03 localhost named[31048]: /etc/named/dynamic/named.ddns.lab.view1.jnl: create: permission denied
Jun 30 11:53:03 localhost named[31048]: client @0x7fa15c03c3e0 192.168.50.15#33250/key zonetransfer.key: view view1: updating zone 'ddns.lab/IN': error: journal open failed: unexpected error
Jun 30 11:53:06 localhost dbus[1320]: [system] Activating service name='org.fedoraproject.Setroubleshootd' (using servicehelper)
Jun 30 11:53:06 localhost dbus[1320]: [system] Successfully activated service 'org.fedoraproject.Setroubleshootd'
Jun 30 11:53:07 localhost setroubleshoot: SELinux is preventing isc-worker0000 from create access on the file named.ddns.lab.view1.jnl. For complete SELinux messages run: sealert -l 7b9a621c-4416-4d12-8ac1-f40d61cb3303
Jun 30 11:53:07 localhost python: SELinux is preventing isc-worker0000 from create access on the file named.ddns.lab.view1.jnl.#012#012*****  Plugin catchall_labels (83.8 confidence) suggests   *******************#012#012If you want to allow isc-worker0000 to have create access on the named.ddns.lab.view1.jnl file#012Then you need to change the label on named.ddns.lab.view1.jnl#012Do#012# semanage fcontext -a -t FILE_TYPE 'named.ddns.lab.view1.jnl'#012where FILE_TYPE is one of the following: dnssec_trigger_var_run_t, ipa_var_lib_t, krb5_host_rcache_t, krb5_keytab_t, named_cache_t, named_log_t, named_tmp_t, named_var_run_t, named_zone_t.#012Then execute:#012restorecon -v 'named.ddns.lab.view1.jnl'#012#012#012*****  Plugin catchall (17.1 confidence) suggests   **************************#012#012If you believe that isc-worker0000 should be allowed create access on the named.ddns.lab.view1.jnl file by default.#012Then you should report this as a bug.#012You can generate a local policy module to allow this access.#012Do#012allow this access for now by executing:#012# ausearch -c 'isc-worker0000' --raw | audit2allow -M my-iscworker0000#012# semodule -i my-iscworker0000.pp#012
```
Интересует строчка: "/etc/named/dynamic/named.ddns.lab.view1.jnl"
Чтобы решить эту проблему необходимо разрешить модулу named_t писать в etc. Поскольку не лучшая практика, делаем:
1. Перенесем все конфиги и файлы работы named из /etc в /etc/named
2. Изменим файл конфигурации named.conf
3. Поправим запуск демона
4. Измменим: "/etc/named/dynamic/named.ddns.lab.view1.jnl" на "/var/named/dynamic/named.ddns.lab.view1.jnl", скопировав содержимое папки "/etc/named/dynamic"
5. Выполним systemctl daemon-reload && systemctl restart named.service

Проверям:
На клиента выполняем команды:
```
[vagrant@client ~]$ nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone ddns.lab
> update add www.ddns.lab. 60 A 192.168.50.15
> send
```
Отправилось.
Проверяем:
```
[vagrant@client ~]$ nslookup www.ddns.lab 192.168.50.10
Server:		192.168.50.10
Address:	192.168.50.10#53

Name:	www.ddns.lab
Address: 192.168.50.15
```