# Vagrant DNS Lab

## Стартуем

vagrant up

## Проверяем

### client

WEB1, WEB2

```
[root@client ~]# nslookup web1
Server:		192.168.50.10
Address:	192.168.50.10#53

Name:	web1.dns.lab
Address: 192.168.50.15

[root@client ~]# nslookup web2
Server:		192.168.50.10
Address:	192.168.50.10#53

Name:	web2.dns.lab
Address: 192.168.50.16
```

WWW.NEWDNS.LAB
```
[root@client ~]# nslookup www.newdns.lab ns01
Server:		ns01
Address:	192.168.50.10#53

Name:	www.newdns.lab
Address: 192.168.50.16
Name:	www.newdns.lab
Address: 192.168.50.15

[root@client ~]# nslookup www.newdns.lab ns02
Server:		ns02
Address:	192.168.50.11#53

Name:	www.newdns.lab
Address: 192.168.50.16
Name:	www.newdns.lab
Address: 192.168.50.15
```
### client2
WEB1, WEB2
```
[root@client2 ~]# nslookup web1
Server:		192.168.50.10
Address:	192.168.50.10#53

Name:	web1.dns.lab
Address: 192.168.50.15

[root@client2 ~]# nslookup web2
Server:		192.168.50.10
Address:	192.168.50.10#53

Name:	web2.dns.lab
Address: 192.168.50.16
```
WWW.NEWDNS.LAB
```
[root@client2 ~]# nslookup www.newdns.lab ns01
Server:		ns01
Address:	192.168.50.10#53

** server can't find www.newdns.lab: NXDOMAIN

[root@client2 ~]# nslookup www.newdns.lab ns02
Server:		ns02
Address:	192.168.50.11#53

** server can't find www.newdns.lab: NXDOMAIN
```