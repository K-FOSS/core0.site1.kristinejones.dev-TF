#!/bin/sh

cp /local/Harbor/NGINX.conf  /etc/nginx/nginx.conf

exec nginx -g daemon off;