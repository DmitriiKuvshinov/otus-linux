#!/bin/bash
yum localinstall -y /nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
/usr/sbin/nginx -s reload