FROM nginx:stable-alpine

MAINTAINER avenus.pl

RUN \
apk update && apk upgrade && apk --no-cache add inotify-tools  &&  apk --update add --no-cache  --virtual .build-dependencies wget

ENV PHPMYADMIN_VERSION=4.6.6
ENV MYSQL_ROOT_PASSWORD=my-secret-pw22

VOLUME ["/usr/share/"]

RUN \
#Install phpmyadmin
wget --no-check-certificate https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz -O phpmyadmin.tar.gz && \
tar zxvf phpmyadmin.tar.gz && \
mkdir /usr/share/webapps && \
mv /phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages /phpmyadmin && \
mv /phpmyadmin /usr/share/webapps && \
rm phpmyadmin.tar.gz -r && \
addgroup -g 82 -S www-data && \
adduser -u 82 -S -D -G www-data  -s /sbin/nologin www-data && \
chown -R www-data:www-data /usr/share/webapps/phpmyadmin/ && \
echo "Delete Build pkgs" && \
apk del .build-dependencies && \
rm -rf /var/cache/apk/* && \
rm -rf /tmp/* && \
rm -rf /src  && \
rm -rf /usr/share/webapps/phpmyadmin/js/jquery/src/ /usr/share/webapps/phpmyadmin/js/openlayers/src/ /usr/share/webapps/phpmyadmin/setup/ /usr/share/webapps/phpmyadmin/examples/ /usr/share/webapps/phpmyadmin/test/ &&\
rm -rf /usr/share/webapps/phpmyadmin/po/ /usr/share/webapps/phpmyadmin/templates/test/ /usr/share/webapps/phpmyadmin/phpunit.xml.* /usr/share/webapps/phpmyadmin/build.xml  &&\
rm -rf /usr/share/webapps/phpmyadmin/composer.json /usr/share/webapps/phpmyadmin/RELEASE-DATE-$PHPMYADMIN_VERSION && \ 
mv /usr/share/webapps/phpmyadmin/config.sample.inc.php /usr/share/webapps/phpmyadmin/config.inc.php && \
sed -i "s/$cfg['Servers'][$i]['host'] = 'localhost';/$cfg['Servers'][$i]['host'] = 'mariadb';/" /usr/share/webapps/phpmyadmin/config.inc.php && \
sed -i "s/$cfg['blowfish_secret'] = '';/$cfg['blowfish_secret'] = 'sdffds9832492387kjhsdf';/" /usr/share/webapps/phpmyadmin/config.inc.php && \
echo "$cfg['Servers'][$i]['user'] = 'root';" >> /usr/share/webapps/phpmyadmin/config.inc.php && \
echo "$cfg['Servers'][$i]['password'] = getenv(\"MYSQL_ROOT_PASSWORD\");" >>/usr/share/webapps/phpmyadmin/config.inc.php && \
chmod 644 /usr/share/webapps/phpmyadmin/config.inc.php

#automatic reloading when config changed
COPY nginx.sh /root/nginx.sh
RUN chmod +x /root/nginx.sh 




CMD ["/root/nginx.sh"]
