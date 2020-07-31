# SMB

## Как запустить
Выполнить vagrant up

## Как проверить

vagrant ssh client

[root@client ~]# cat /etc/fstab 

```

#
# /etc/fstab
# Created by anaconda on Sat Jun  1 17:13:31 2019
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
UUID=8ac075e3-1124-4bb6-bef7-a6811bf8b870 /                       xfs     defaults        0 0
/swapfile none swap defaults 0 0
192.168.50.10:/mnt/storage /mnt/nfs-share nfs noauto,x-systemd.automount,x-systemd.device-timeout=10,timeo=14 0 0


[root@client ~]# touch /mnt/nfs-share/upload/file-today-now
[root@client ~]# ls -la /mnt/nfs-share/upload/
total 0
drwxrwxr-x. 2 vagrant vagrant 28 Jul 18 18:18 .
drwxr-xr-x. 3 vagrant vagrant 20 Jul 18 18:15 ..
-rw-r--r--. 1 root    root     0 Jul 18 18:18 file-today-now
```
vagrant ssh client
```
[root@server ~]# ls -l /mnt/storage/upload/
total 0
-rw-r--r--. 1 root root 0 Jul 18 18:18 file-today-now

[root@server ~]# firewall-cmd --state
running
```

Проверим порты, на которых сервер принимает соединения
```
[root@server ~]# rpcinfo -p localhost | grep nfs
    100003    3   tcp   2049  nfs
    100227    3   tcp   2049  nfs_acl
    100003    3   udp   2049  nfs
    100227    3   udp   2049  nfs_acl
```
Проверяем:
```
[root@client ~]# mount | grep 192
192.168.50.10:/mnt/storage on /mnt/nfs-share type nfs (rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,proto=udp,timeo=11,retrans=3,sec=sys,mountaddr=192.168.50.10,mountvers=3,mountport=20048,mountproto=udp,local_lock=none,addr=192.168.50.10)
```