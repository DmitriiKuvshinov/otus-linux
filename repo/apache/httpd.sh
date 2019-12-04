#!/bin/bash

sudo wget -P /root/ http://mirror.linux-ia64.org/apache//httpd/httpd-2.4.41.tar.bz2
sudo wget -P /root/ http://mirror.linux-ia64.org/apache//apr/apr-1.7.0.tar.bz2
sudo wget -P /root http://mirror.linux-ia64.org/apache//apr/apr-util-1.6.1.tar.bz2
sudo rpmbuild -ts /root/apr-1.7.0.tar.bz2 
sudo rpm -i /root/rpmbuild/SRPMS/apr-1.7.0-1.src.rpm
sudo yum-builddep -y /root/rpmbuild/SPECS/apr.spec
sudo rpmbuild -bb /root/rpmbuild/SPECS/apr.spec
sudo yum install -y /root/rpmbuild/RPMS/x86_64/apr-1.7.0-1.x86_64.rpm
sudo yum install -y /root/rpmbuild/RPMS/x86_64/apr-devel-1.7.0-1.x86_64.rpm
sudo rpmbuild -ts apr-util-1.6.1.tar.bz2
sudo rpm -i /root/rpmbuild/SRPMS/apr-util-1.6.1-1.src.rpm
sudo yum install -y -q epel-release
sudo yum-builddep -y /root/rpmbuild/SPECS/apr-util.spec
sudo rpmbuild -bb /root/rpmbuild/SPECS/apr-util.spec


#sudo tar -xvf /root/httpd-2.4.41.tar.gz -C /root/
#sudo tar -xvf /root/apr-1.7.0.tar.gz  -C /root/
#sudo tar -xvf /root/apr-util-1.6.1.tar.gz -C /root/
#sudo mv /root/apr-1.7.0/ /root/httpd-2.4.41/srclib/apr
#sudo mv /root/apr-util-1.6.1 /root/httpd-2.4.41/srclib/apr-util
#sudo cp /vagrant/repo/apache/httpd.spec /root/httpd-2.4.41/
#sudo cd /root/
#sudo tar -cvf /root/httpd-2.4.41.tar /root/httpd-2.4.41/
#sudo bzip2 -z /root/httpd-2.4.41.tar
#sudo mkdir -p ~/rpmbuild/{SOURCES,SPECS}
#sudo cp httpd-2.4.41.tar.bz2 ~/rpmbuild/SOURCES/

#sudo rm -rf *.gz

#sudo /root/httpd-2.4.41/configure --enable-layout=RPM --prefix=/usr/apache --enable-expires --enable-headers --enable-rewrite --enable-cache --enable-mem-cache --enable-speling --enable-usertrack --enable-module=so --enable-unique_id --enable-logio --enable-ssl=shared --with-ssl=/usr/apache --enable-proxy=shared --with-included-apr --libdir=%{_libdir} --sysconfdir=%{_sysconfdir}/httpd/conf --includedir=%{_includedir}/httpd --libexecdir=%{_libdir}/httpd/modules --datadir=%{contentdir} --with-installbuilddir=%{_libdir}/httpd/build --enable-mpms-shared=all --with-apr=%{_prefix} --with-apr-util=%{_prefix} --enable-suexec --with-suexec --with-suexec-caller=%{suexec_caller} --with-suexec-docroot=%{contentdir} --with-suexec-logfile=%{_localstatedir}/log/httpd/suexec.log --with-suexec-bin=%{_sbindir}/suexec --with-suexec-uidmin=500 --with-suexec-gidmin=100 --enable-pie --with-pcre --enable-mods-shared=all --enable-ssl --with-ssl --enable-bucketeer --enable-case-filter --enable-case-filter-in --disable-imagemap && make && make install
#sudo make && make install

#sudo cp /vagrant/repo/apache/httpd.conf /etc/httpd/conf/
#sudo /usr/apache/sbin/httpd

#sudo mkdir -p ~/rpmbuild
#sudo mkdir -p ~/rpmbuild/{SOURCES,SPECS}
#sudo cp /vagrant/repo/apache/httpd.spec /root/httpd-2.4.41/
#sudo cd /vagrant/repo/apache
#sudo tar -cvf httpd-2.4.41.tar httpd-2.4.41/
#sudo bzip2 -z httpd-2.4.41.tar
#sudo cp httpd-2.4.41.tar.bz2 ~/rpmbuild/SOURCES/