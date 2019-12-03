#!/bin/bash

wget http://mirror.linux-ia64.org/apache/httpd/httpd-2.4.41.tar.gz
wget http://us.mirrors.quenda.co/apache//apr/apr-1.7.0.tar.gz
wget http://us.mirrors.quenda.co/apache//apr/apr-util-1.6.1.tar.gz

tar -xvf httpd-2.4.41.tar.gz
tar -xvf apr-1.7.0.tar.gz 
tar -xvf apr-util-1.6.1.tar.gz
mv apr-1.7.0/ httpd-2.4.41/srclib/apr
mv apr-util-1.6.1 httpd-2.4.41/srclib/apr-util
rm -rf *.gz

cd httpd-2.4.41
./configure --enable-layout=RedHat --prefix=/usr --enable-expires --enable-headers --enable-rewrite --enable-cache --enable-mem-cache --enable-speling --enable-usertrack --enable-module=so --enable-unique_id --enable-logio --enable-ssl=shared --with-ssl=/usr --enable-proxy=shared --with-included-apr
make && make install

cp ~/vagrant/repo/apache/httpd.conf /etc/httpd/conf/
/usr/apache/sbin/httpd

cp ~/vagrant/repo/apache/httpd.spec ~/httpd-2.4.41/
cd ~/
tar -cvf httpd-2.4.41.tar httpd-2.4.41/
bzip2 -z httpd-2.4.41.tar
cp httpd-2.4.41.tar.bz2 ~/rpmbuild/SOURCES/
