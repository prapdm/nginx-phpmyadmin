FROM nginx:stable-alpine

MAINTAINER avenus.pl

RUN \
apk update && apk upgrade && apk --no-cache add inotify-tools  &&  apk --update add --no-cache  --virtual .build-dependencies wget

ENV MYSQL_ROOT_PASSWORD=my-secret-pw22
ENV PHPMYADMIN_VERSION=4.6.6


RUN \
wget --no-check-certificate https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz -O phpmyadmin.tar.gz  && \
echo "Delete Build pkgs" && \
apk del .build-dependencies && \
rm -rf /var/cache/apk/* && \
rm -rf /tmp/* && \
rm -rf /src  

#automatic reloading when config changed
COPY nginx.sh /root/nginx.sh
RUN chmod +x /root/nginx.sh 

VOLUME ["/usr/share/"]

CMD ["/root/nginx.sh"]
