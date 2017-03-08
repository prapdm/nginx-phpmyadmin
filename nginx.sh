#!/bin/sh

NGINX_CONFIG="/etc/nginx/conf.d/"
DIRECTORY="/usr/share/webapps/phpmyadmin/"

#start nginx
nginx


#install phpmyadmin
if [ ! -d "$DIRECTORY" ]; then
mkdir /usr/share/webapps
tar zxvf phpmyadmin.tar.gz
mv /phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages /phpmyadmin
mv /phpmyadmin /usr/share/webapps
rm phpmyadmin.tar.gz -r
chown -R www-data:www-data /usr/share/webapps/phpmyadmin/
rm -rf /usr/share/webapps/phpmyadmin/js/jquery/src/ /usr/share/webapps/phpmyadmin/js/openlayers/src/ /usr/share/webapps/phpmyadmin/setup/ /usr/share/webapps/phpmyadmin/examples/ /usr/share/webapps/phpmyadmin/test/
rm -rf /usr/share/webapps/phpmyadmin/po/ /usr/share/webapps/phpmyadmin/templates/test/ /usr/share/webapps/phpmyadmin/phpunit.xml.* /usr/share/webapps/phpmyadmin/build.xml
rm -rf /usr/share/webapps/phpmyadmin/composer.json /usr/share/webapps/phpmyadmin/RELEASE-DATE-$PHPMYADMIN_VERSION
mv /usr/share/webapps/phpmyadmin/config.sample.inc.php /usr/share/webapps/phpmyadmin/config.inc.php
mkdir /usr/share/webapps/tmp
echo "\$i = 1;" >/usr/share/webapps/phpmyadmin/config.inc.php
echo "\$cfg['Servers'][\$i]['auth_type'] = 'http'; " >>/usr/share/webapps/phpmyadmin/config.inc.php
echo "\$cfg['Servers'][\$i]['host'] = 'mariadb';" >>/usr/share/webapps/phpmyadmin/config.inc.php
echo "\$cfg['Servers'][\$i]['connect_type'] = 'tcp';" >>/usr/share/webapps/phpmyadmin/config.inc.php
echo "\$cfg['Servers'][\$i]['compress'] = false;" >>/usr/share/webapps/phpmyadmin/config.inc.php
echo "\$cfg['Servers'][\$i]['AllowNoPassword'] = false;" >>/usr/share/webapps/phpmyadmin/config.inc.php
echo "\$cfg['Servers'][\$i]['AllowRoot'] = true;" >>/usr/share/webapps/phpmyadmin/config.inc.php
echo "\$cfg['UploadDir'] = '/usr/share/webapps/tmp';" >>/usr/share/webapps/phpmyadmin/config.inc.php
echo "\$cfg['SaveDir'] = '/usr/share/webapps/tmp';" >>/usr/share/webapps/phpmyadmin/config.inc.php
find /usr/share/ -type d -exec chmod 755 {} \;
find /usr/share/webapps/ -type f -exec chmod 640 {} \;
chmod 644 /usr/share/webapps/phpmyadmin/config.inc.php
fi

#reload nginx when config changed
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
