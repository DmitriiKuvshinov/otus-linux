# PostgresSQL 

## Стенд
master - 192.168.50.10
slave - 192.168.50.11
backup - 192.168.50.12

vagrant up поднимает стенд и настраивает инфраструктуру.

## Репликация
Проверим работу ремпликации:

```
[root@slave log]# sudo -u postgres psql
psql (10.13)
Type "help" for help.

postgres=# SELECT now()-pg_last_xact_replay_timestamp();
    ?column?     
-----------------
 00:10:54.945087
(1 row)
```
## Резервное копирование
Проверим работу: 
```
[root@backup barman.d]# barman check db3
Server db3:
	WAL archive: FAILED (please make sure WAL shipping is setup)
	PostgreSQL: OK
	superuser or standard user with backup privileges: OK
	PostgreSQL streaming: OK
	wal_level: OK
	replication slot: OK
	directories: OK
	retention policy settings: OK
	backup maximum age: OK (no last_backup_maximum_age provided)
	compression settings: OK
	failed backups: OK (there are 0 failed backups)
	minimum redundancy requirements: OK (have 0 backups, expected at least 0)
	pg_basebackup: OK
	pg_basebackup compatible: OK
	pg_basebackup supports tablespaces mapping: OK
	systemid coherence: OK (no system Id stored on disk)
	pg_receivexlog: OK
	pg_receivexlog compatible: OK
	receive-wal running: OK
	archiver errors: OK
```