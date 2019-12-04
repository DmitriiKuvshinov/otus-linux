FROM centos:7
COPY ./scripts/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
RUN yum install -y lsof
RUN yum localinstall -y /nginx-1.14.1-1.el7_4.ngx.x86_64.rpm