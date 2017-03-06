FROM nginx:stable-alpine

MAINTAINER avenus.pl

RUN \
apk update && apk upgrade && apk --update add --no-cache  --virtual .build-dependencies wget

ENV PHPMYADMIN_VERSION=4.6.6
ENV restart=0

RUN \
#reload nginx by ENV
(crontab -l 2>/dev/null; echo "*/1 * * * * source /root/nginx.sh") | crontab - && \
echo -e "#!/bin/sh \n if [ \$restart = 1 ]; then \n nginx -s reload \n  echo \"Nginx reloaded\" \n export restart=0 \n   fi" > /root/nginx.sh && \
chmod +x /root/nginx.sh && \
#Install phpmyadmin
wget --no-check-certificate https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz -O phpmyadmin.tar.gz && \
tar zxvf phpmyadmin.tar.gz && \
mkdir -p /usr/share/webapps/phpmyadmin && \
mv phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages /usr/share/webapps/phpmyadmin && \
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
rm -rf /usr/share/webapps/phpmyadmin/composer.json /usr/share/webapps/phpmyadmin/RELEASE-DATE-$PHPMYADMIN_VERSION  
#sed -i "s@define('CONFIG_DIR'.*@define('CONFIG_DIR', '/etc/phpmyadmin/');@" /usr/phpmyadmin/libraries/vendor_config.php



