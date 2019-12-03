FROM ubuntu:16.04
RUN apt-get update && apt install curl gnupg2 ca-certificates lsb-release
COPY scripts/nginx.sh /nginx.sh
RUN chmod 0777 /nginx.sh
CMD ["/nginx.sh"]
