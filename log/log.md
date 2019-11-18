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
[root@otuslinux ~]#  xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
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
Изменим /boot/grub2/grub.cfg. Заменим rd.lvm.lv=VolGroup00/LogVol00 на rd.lvm.lv=vg_root/lv_root
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
[root@otuslinux ~]# lvremove /dev/VolGroup00/LogVol00
Do you really want to remove active logical volume VolGroup00/LogVol00? [y/n]: y
  Logical volume "LogVol00" successfully removed
[root@otuslinux ~]#  lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
WARNING: xfs signature detected on /dev/VolGroup00/LogVol00 at offset 0. Wipe it? [y/n]: y
  Wiping xfs signature on /dev/VolGroup00/LogVol00.
  Logical volume "LogVol00" created.
[root@otuslinux ~]# mkfs.xfs /dev/VolGroup00/LogVol00
meta-data=/dev/VolGroup00/LogVol00 isize=512    agcount=4, agsize=524288 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=2097152, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@otuslinux ~]# mount /dev/VolGroup00/LogVol00 /mnt 
[root@otuslinux ~]# xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt
...
xfsrestore: Restore Status: SUCCESS
[root@otuslinux ~]#  for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@otuslinux ~]# chroot /mnt/
[root@otuslinux /]# grub2-mkconfig -o /boot/grub2/grub.cfg
[root@otuslinux /]# cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;
> s/.img//g"` --force; done
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
```
Перезагружаемся и продолжаем
```
[root@otuslinux ~]# lsblk
NAME                     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                        8:0    0   40G  0 disk 
├─sda1                     8:1    0    1M  0 part 
├─sda2                     8:2    0    1G  0 part /boot
└─sda3                     8:3    0   39G  0 part 
  ├─VolGroup00-LogVol00  253:0    0    8G  0 lvm  /
  └─VolGroup00-LogVol01  253:1    0  1,5G  0 lvm  [SWAP]
sdb                        8:16   0  9,8G  0 disk 
└─vg_root-lv_root        253:7    0  9,8G  0 lvm  
sdc                        8:32   0  9,8G  0 disk 
├─vg_var-lv_var_rmeta_0  253:2    0    4M  0 lvm  
│ └─vg_var-lv_var        253:6    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_0 253:3    0  952M  0 lvm  
  └─vg_var-lv_var        253:6    0  952M  0 lvm  /var
sdd                        8:48   0  2,5G  0 disk 
├─vg_var-lv_var_rmeta_1  253:4    0    4M  0 lvm  
│ └─vg_var-lv_var        253:6    0  952M  0 lvm  /var
└─vg_var-lv_var_rimage_1 253:5    0  952M  0 lvm  
  └─vg_var-lv_var        253:6    0  952M  0 lvm  /var
sde                        8:64   0  2,5G  0 disk 
sdf                        8:80   0  250M  0 disk 
sdg                        8:96   0  250M  0 disk

[root@otuslinux ~]#  lvremove /dev/vg_root/lv_root
Do you really want to remove active logical volume vg_root/lv_root? [y/n]: н
  WARNING: Invalid input ''.
Do you really want to remove active logical volume vg_root/lv_root? [y/n]: y
  Logical volume "lv_root" successfully removed
[root@otuslinux ~]# vgremove /dev/vg_root
  Volume group "vg_root" successfully removed
[root@otuslinux ~]# pvremove /dev/sdb
  Labels on physical volume "/dev/sdb" successfully wiped.
[root@otuslinux ~]#  lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
  Logical volume "LogVol_Home" created.
[root@otuslinux ~]# mkfs.xfs /dev/VolGroup00/LogVol_Home
meta-data=/dev/VolGroup00/LogVol_Home isize=512    agcount=4, agsize=131072 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=524288, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@otuslinux ~]# mount /dev/VolGroup00/LogVol_Home /mnt/
[root@otuslinux ~]# cp -aR /home/* /mnt/ 
[root@otuslinux ~]# rm -rf /home/*
[root@otuslinux ~]# umount /mnt
[root@otuslinux ~]# mount /dev/VolGroup00/LogVol_Home /home/
[root@otuslinux ~]# echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
[root@otuslinux ~]# df -Th
Filesystem                         Type      Size  Used Avail Use% Mounted on
/dev/mapper/VolGroup00-LogVol00    xfs       8,0G  949M  7,1G  12% /
devtmpfs                           devtmpfs  488M     0  488M   0% /dev
tmpfs                              tmpfs     496M     0  496M   0% /dev/shm
tmpfs                              tmpfs     496M  6,7M  490M   2% /run
tmpfs                              tmpfs     496M     0  496M   0% /sys/fs/cgroup
/dev/sda2                          xfs      1014M   62M  953M   7% /boot
/dev/mapper/VolGroup00-LogVol_Home xfs       2,0G   33M  2,0G   2% /home
/dev/mapper/vg_var-lv_var          ext4      922M   77M  781M   9% /var
```
Сгенерируем файлы в /home/:
```
[root@otuslinux ~]# touch /home/file{1..20}
[root@otuslinux ~]#  lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
  Rounding up size to full physical extent 128,00 MiB
  Logical volume "home_snap" created.
[root@otuslinux ~]# rm -f /home/file{11..20}
[root@otuslinux ~]# umount -l /home
[root@otuslinux ~]# umount -f /home
[root@otuslinux ~]# umount /home
[root@otuslinux ~]# lvconvert --merge /dev/VolGroup00/home_snap
[root@otuslinux ~]# mount /home
[root@otuslinux ~]# ll /home/
total 0
-rw-r--r--. 1 root    root     0 ноя 18 09:26 file1
-rw-r--r--. 1 root    root     0 ноя 18 09:26 file10
-rw-r--r--. 1 root    root     0 ноя 18 09:26 file11
-rw-r--r--. 1 root    root     0 ноя 18 09:26 file12
-rw-r--r--. 1 root    root     0 ноя 18 09:26 file13
-rw-r--r--. 1 root    root     0 ноя 18 09:26 file14
-rw-r--r--. 1 root    root     0 ноя 18 09:26 file15
-rw-r--r--. 1 root    root     0 ноя 18 09:26 file16
-rw-r--r--. 1 root    root     0 ноя 18 09:26 file17
-rw-r--r--. 1 root    root     0 ноя 18 09:26 file18
-rw-r--r--. 1 root    root     0 ноя 18 09:26 file19
-rw-r--r--. 1 root    root     0 ноя 18 09:26 file2
-rw-r--r--. 1 root    root     0 ноя 18 09:26 file20
-rw-r--r--. 1 root    root     0 ноя 18 09:26 file3
-rw-r--r--. 1 root    root     0 ноя 18 09:26 file4
-rw-r--r--. 1 root    root     0 ноя 18 09:26 file5
-rw-r--r--. 1 root    root     0 ноя 18 09:26 file6
-rw-r--r--. 1 root    root     0 ноя 18 09:26 file7
-rw-r--r--. 1 root    root     0 ноя 18 09:26 file8
-rw-r--r--. 1 root    root     0 ноя 18 09:26 file9
drwx------. 3 vagrant vagrant 74 май 12  2018 vagrant
```
