#!/bin/sh

echo "HelloWorld"

cp /local/Harbor/NGINX.conf  /etc/nginx/nginx.conf

exec su -p -c "nginx -g daemon off;" nginx