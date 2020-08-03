# PSQL Репликация и бэкап

## Как запустить
Выполнить vagrant up 

## Как проверить
Выполнить 

```
vagrant ssh backup
sudo -i
barman receive-wal --create-slot db3

vagrant ssh master
sudo -i
sudo -u postgres psql
select * from pg_switch_wal();

[root@backup .ssh]# barman switch-xlog --force --archive db3
No switch performed because server 'db3' is a standby.
Waiting for a WAL file from server 'db3' to be archived (max: 30 seconds)
db3: pg_receivewal: finished segment at 0/7000000 (timeline 1)
Processing xlog segments from streaming for db3
	000000010000000000000006
```
