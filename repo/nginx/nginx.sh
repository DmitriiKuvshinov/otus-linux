#!/bin/bash

sudo wget -P /root https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
sudo rpm -i /root/nginx-1.14.1-1.el7_4.ngx.src.rpm
sudo wget -P /root https://www.openssl.org/source/latest.tar.gz
sudo tar -xvf /root/latest.tar.gz -C /root/
sudo cp /vagrant/repo/nginx/nginx.spec  /root/rpmbuild/SPECS/nginx.spec
sudo yum-builddep /root/rpmbuild/SPECS/nginx.spec
sudo rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec
sudo yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm