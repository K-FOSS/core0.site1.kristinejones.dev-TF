#!/bin/sh

chown -R 1000:1000 /usr/share/opensearch/config/TLS

yum install -y sudo util-linux

exec sudo su -p -c "/usr/share/opensearch/opensearch-docker-entrypoint.sh" opensearch

