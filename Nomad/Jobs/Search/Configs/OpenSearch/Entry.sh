#!/bin/sh

chown -R 1000:1000 /usr/share/opensearch/config/TLS
chmod 0700 /usr/share/opensearch/config/TLS /usr/share/opensearch/config/TLS/Coordinator /usr/share/opensearch/config/TLS/Data /usr/share/opensearch/config/TLS/Ingest /usr/share/opensearch/config/TLS/Master  

yum install -y util-linux

exec su -p -c "/usr/share/opensearch/opensearch-docker-entrypoint.sh" opensearch

