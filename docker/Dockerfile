FROM centos:7
COPY ./scripts/nginx.sh /nginx.sh
RUN chmod 0777 /nginx.sh
COPY ./scripts/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
RUN yum localinstall -y /nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
CMD ["/nginx.sh"]