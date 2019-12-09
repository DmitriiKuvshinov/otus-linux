#!/bin/bash

sudo wget -P /root https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
sudo rpm -i /root/nginx-1.14.1-1.el7_4.ngx.src.rpm
sudo wget -P /root https://www.openssl.org/source/latest.tar.gz
sudo tar -xvf /root/latest.tar.gz -C /root/
sudo cp /vagrant/repo/nginx/nginx.spec  /root/rpmbuild/SPECS/nginx.spec
sudo yum-builddep /root/rpmbuild/SPECS/nginx.spec
sudo rpmbuild --clean -bb /root/rpmbuild/SPECS/nginx.spec
sudo yum localinstall -y /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
sudo mkdir -p /repo
sudo cp /root/rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /repo/
sudo chown -R nginx:nginx /repo
sudo createrepo /repo
sudo setenforce 0
sudo cat <<EOF > /etc/nginx/conf.d/default.conf
server {
    listen       80;
    server_name  localhost;

    #charset koi8-r;
    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /repo;
        index  index.html index.htm;
        autoindex on;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF