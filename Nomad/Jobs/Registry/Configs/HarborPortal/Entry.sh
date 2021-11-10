#!/bin/sh

echo "HelloWorld"

mkdir -p /var/log/nginx

chown nginx:nginx /var/log/nginx

cp /local/Harbor/NGINX.conf  /etc/nginx/nginx.conf

exec su -p -c "/usr/sbin/nginx -g 'daemon off;'" nginx