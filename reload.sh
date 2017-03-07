#!/bin/sh

NGINX_CONFIG="/etc/nginx/conf.d/"

#start nginx
nginx

while inotifywait -q -e create,delete,modify,attrib $NGINX_CONFIG; do
  nginx -t
  if [ $? -eq 0 ]
        then
          echo "Reloading Nginx Configuration"
          nginx -s reload
  fi
done
