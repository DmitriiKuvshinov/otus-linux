# InnoDB кластер в докере

## Как запустить
В директории выполнить docker-compose up -d
Дождаться поднятия стенда

## Как проверить
Выполнить docker ps -a
```
CONTAINER ID        IMAGE                        COMMAND             CREATED             STATUS                    PORTS                                                                                         NAMES
f0e16097dc1d        neumayer/mysql-shell-batch   "/run.sh mysqlsh"   13 seconds ago      Up 11 seconds                                                                                                           innodb_mysql-shell_1
74e716897f69        mattalord/innodb-cluster     "/entrypoint.sh "   15 minutes ago      Up 15 minutes (healthy)   0.0.0.0:6446-6447->6446-6447/tcp, 0.0.0.0:6606->6606/tcp, 33060/tcp, 0.0.0.0:3307->3306/tcp   innodb_router_1
1db03e08743a        mattalord/innodb-cluster     "/entrypoint.sh "   19 minutes ago      Up 19 minutes (healthy)   3306/tcp, 6446-6447/tcp, 6606/tcp, 33060/tcp                                                  innodb_mysql-2_1
b1be48124bda        mattalord/innodb-cluster     "/entrypoint.sh "   19 minutes ago      Up 19 minutes (healthy)   3306/tcp, 6446-6447/tcp, 6606/tcp, 33060/tcp                                                  innodb_mysql-3_1
d5412cd890d6        mattalord/innodb-cluster     "/entrypoint.sh "   19 minutes ago      Up 19 minutes (healthy)   3306/tcp, 6446-6447/tcp, 6606/tcp, 33060/tcp                                                  innodb_mysql-1_1
```
Подключиться к innodb_mysql-shell_1 и выполнить:

```
bash-4.2# shell.connect('innodb_router_1:6446','root')^C
bash-4.2# mysql
mysqlprovision  mysqlsh         
bash-4.2# mysqlsh
MySQL Shell 1.0.11

Copyright (c) 2016, 2017, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type '\help' or '\?' for help; '\quit' to exit.

Currently in JavaScript mode. Use \sql to switch to SQL mode and execute queries.
mysql-js> shell.connect('innodb_router_1:6446','root')
Creating a Session to 'root@innodb_router_1:6446'
Your MySQL connection id is 118
No default schema selected; type \use <schema> to set one.
mysql-js> dba.getCluster().status()
{
    "clusterName": "testcluster", 
    "defaultReplicaSet": {
        "name": "default", 
        "primary": "mysql-1:3306", 
        "status": "OK", 
        "statusText": "Cluster is ONLINE and can tolerate up to ONE failure.", 
        "topology": {
            "mysql-1:3306": {
                "address": "mysql-1:3306", 
                "mode": "R/W", 
                "readReplicas": {}, 
                "role": "HA", 
                "status": "ONLINE"
            }, 
            "mysql-2:3306": {
                "address": "mysql-2:3306", 
                "mode": "R/O", 
                "readReplicas": {}, 
                "role": "HA", 
                "status": "ONLINE"
            }, 
            "mysql-3:3306": {
                "address": "mysql-3:3306", 
                "mode": "R/O", 
                "readReplicas": {}, 
                "role": "HA", 
                "status": "ONLINE"
            }
        }
    }
}
mysql-js> 
```