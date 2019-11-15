## Уменьшить том под / до 8G
xfsdump и lvm2 установлен при создании ВМ (прописан в  Vagrantfile)
```
[root@otuslinux ~]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   40G  0 disk 
└─sda1   8:1    0   40G  0 part /
sdb      8:16   0  9,8G  0 disk 
sdc      8:32   0  9,8G  0 disk 
sdd      8:48   0  2,5G  0 disk 
sde      8:64   0  2,5G  0 disk 
sdf      8:80   0  250M  0 disk 
sdg      8:96   0  250M  0 disk

[root@otuslinux ~]# pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
[root@otuslinux ~]# vgcreate vg_root /dev/sdb
  Volume group "vg_root" successfully created
[root@otuslinux ~]# lvcreate -n lv_root -l +100%FREE /dev/vg_root
  Logical volume "lv_root" created.
[root@otuslinux ~]# mkfs.xfs /dev/vg_root/lv_root
meta-data=/dev/vg_root/lv_root   isize=512    agcount=4, agsize=639744 blks
...
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@otuslinux ~]# mount /dev/vg_root/lv_root /mnt
```
Дампим рут
```
[root@otuslinux ~]#  xfsdump -J - /dev/sda1 | xfsrestore -J - /mnt
...
xfsrestore: Restore Status: SUCCESS

[root@otuslinux ~]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@otuslinux ~]#  chroot /mnt/
```
Обновим загрузчик и данные о рут-волюм
```
[root@otuslinux /]# grub2-mkconfig -o /boot/grub2/grub.cfg
[root@otuslinux /]# cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
```
Изменим /boot/grub2/grub.cfg. Параметр rd.lvm.lv отсутствует в этом файле. Ищем загрузку ОС. Меняем root dev UUID диска /dev/sda1 на UUID lvm раздела. Смотри его командой: lsblk -o +uuid,name
```
[root@otuslinux boot]# lsblk -o +uuid,name
```
Выходим из chroot, перезагружаемся. Проверяем
```
[root@otuslinux ~]# lsblk
NAME              MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                 8:0    0   40G  0 disk 
└─sda1              8:1    0   40G  0 part 
sdb                 8:16   0  9,8G  0 disk 
└─vg_root-lv_root 253:0    0  9,8G  0 lvm  /
sdc                 8:32   0  9,8G  0 disk 
sdd                 8:48   0  2,5G  0 disk 
sde                 8:64   0  2,5G  0 disk 
sdf                 8:80   0  250M  0 disk 
sdg                 8:96   0  250M  0 disk 
```
Рут в нужном месте. Приступаем к изменению раздела /dev/sda1. Посколько, /dev/sda1 поднят как партиция, то форматнем диск и создадим LVM
```
[root@otuslinux ~]# pvremove /dev/sda
  Device /dev/sda excluded by a filter.
 ```
 Оп...
```
[root@otuslinux ~]# fdisk /dev/sda1
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table
Building a new DOS disklabel with disk identifier 0x71bd512f.

Command (m for help): g
Building a new GPT disklabel (GUID: 7CD54927-63C6-431D-A62F-D30605C628B1)

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.

WARNING: Re-reading the partition table failed with error 22: Invalid argument.
The kernel still uses the old table. The new table will be used at
the next reboot or after you run partprobe(8) or kpartx(8)
Syncing disks.

[root@otuslinux ~]# fdisk /dev/sda
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Command (m for help): d
Selected partition 1
Partition 1 is deleted

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
[root@otuslinux ~]# pvremove /dev/sda1
[root@otuslinux ~]# lsblk
NAME              MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                 8:0    0   40G  0 disk 
sdb                 8:16   0  9,8G  0 disk 
└─vg_root-lv_root 253:0    0  9,8G  0 lvm  /
sdc                 8:32   0  9,8G  0 disk 
sdd                 8:48   0  2,5G  0 disk 
sde                 8:64   0  2,5G  0 disk 
sdf                 8:80   0  250M  0 disk 
sdg                 8:96   0  250M  0 disk 

```
Диск /dev/sda готов для дальнейших действий

```
[root@otuslinux ~]# vgcreate otus /dev/sda
[root@otuslinux ~]# lvcreate -L8G -n small otus
[root@otuslinux ~]# lsblk
NAME              MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                 8:0    0   40G  0 disk 
└─otus-small      253:1    0    8G  0 lvm  
sdb                 8:16   0  9,8G  0 disk 
└─vg_root-lv_root 253:0    0  9,8G  0 lvm  /
sdc                 8:32   0  9,8G  0 disk 
sdd                 8:48   0  2,5G  0 disk 
sde                 8:64   0  2,5G  0 disk 
sdf                 8:80   0  250M  0 disk 
sdg                 8:96   0  250M  0 disk 

[root@otuslinux ~]# mkfs.xfs /dev/otus/small 
[root@otuslinux ~]# mount /dev/otus/small /mnt
[root@otuslinux ~]# xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt
...
xfsrestore: Restore Status: SUCCESS

[root@otuslinux ~]#  for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@otuslinux ~]# chroot /mnt/
[root@otuslinux /]# grub2-mkconfig -o /boot/grub2/grub.cfg
[root@otuslinux /]# cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;
> s/.img//g"` --force; done
```
Обновим Grub. Однако, теперь тут необходимо изменить lvmid. Собираем его из VG UUID и LV UUID
```
[root@otuslinux boot]# vi /boot/grub2/grub.cfg
```
Зазеркалируем /var, заранее его почистив
```
[root@otuslinux boot]# pvcreate /dev/sdc /dev/sdd
[root@otuslinux boot]# vgcreate vg_var /dev/sd{c,d}
[root@otuslinux boot]# lvcreate -L1G -m1 -n lv_var vg_var
[root@otuslinux boot]# mkfs.ext4 /dev/vg_var/lv_var
[root@otuslinux boot]#  mount /dev/vg_var/lv_var /mnt
[root@otuslinux boot]# cp -aR /var/* /mnt/ # rsync -avHPSAX /var/ /mnt/
[root@otuslinux boot]# mkdir /tmp/oldvar && rm -rf /var/* 
[root@otuslinux boot]#  umount /mnt
[root@otuslinux boot]# mount /dev/vg_var/lv_var /var
[root@otuslinux var]# echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
