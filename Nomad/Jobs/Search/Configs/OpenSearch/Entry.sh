#!/bin/sh

chown -R 1000:1000 /usr/share/opensearch/config/TLS

exec su -p -c "/usr/share/opensearch/opensearch-docker-entrypoint.sh" opensearch

