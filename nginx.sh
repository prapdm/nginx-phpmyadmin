#!/bin/sh

NGINX_CONFIG="/etc/nginx/conf.d/"
DIRECTORY="/usr/share/webapps/phpmyadmin"

#start nginx
nginx


#install phpmyadmin
mkdir /usr/share/webapps
if [ ! -d "$DIRECTORY" ]; then
tar zxvf phpmyadmin.tar.gz
mv /phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages /phpmyadmin
mv /phpmyadmin /usr/share/webapps
rm phpmyadmin.tar.gz -r
addgroup -g 82 -S www-data
adduser -u 82 -S -D -G www-data  -s /sbin/nologin www-data
chown -R www-data:www-data /usr/share/webapps/phpmyadmin/
rm -rf /usr/share/webapps/phpmyadmin/js/jquery/src/ /usr/share/webapps/phpmyadmin/js/openlayers/src/ /usr/share/webapps/phpmyadmin/setup/ /usr/share/webapps/phpmyadmin/examples/ /usr/share/webapps/phpmyadmin/test/
rm -rf /usr/share/webapps/phpmyadmin/po/ /usr/share/webapps/phpmyadmin/templates/test/ /usr/share/webapps/phpmyadmin/phpunit.xml.* /usr/share/webapps/phpmyadmin/build.xml
rm -rf /usr/share/webapps/phpmyadmin/composer.json /usr/share/webapps/phpmyadmin/RELEASE-DATE-$PHPMYADMIN_VERSION
mv /usr/share/webapps/phpmyadmin/config.sample.inc.php /usr/share/webapps/phpmyadmin/config.inc.php
sed -i "s/$cfg['Servers'][$i]['host'] = 'localhost';/$cfg['Servers'][$i]['host'] = 'mariadb';/" /usr/share/webapps/phpmyadmin/config.inc.php
sed -i "s/$cfg['blowfish_secret'] = '';/$cfg['blowfish_secret'] = 'sdffds9832492387kjhsdf';/" /usr/share/webapps/phpmyadmin/config.inc.php
echo "$cfg['Servers'][$i]['user'] = 'root';" >> /usr/share/webapps/phpmyadmin/config.inc.php
echo "$cfg['Servers'][$i]['password'] = getenv(\"MYSQL_ROOT_PASSWORD\");" >>/usr/share/webapps/phpmyadmin/config.inc.php
chmod 644 /usr/share/webapps/phpmyadmin/config.inc.php
fi

while inotifywait -q -e create,delete,modify,attrib $NGINX_CONFIG; do
  nginx -t
  if [ $? -eq 0 ]
        then
          echo "Reloading Nginx Configuration"
          nginx -s reload
          if [ $? != 0 ]
                then
                nginx
                fi
  fi
done
