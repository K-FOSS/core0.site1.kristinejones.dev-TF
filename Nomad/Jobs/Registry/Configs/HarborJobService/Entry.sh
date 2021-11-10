#!/bin/sh

set -e

mkdir -p /etc/harbor/ssl
cp /local/CA.pem /etc/harbor/ssl/ca.crt

/harbor/install_cert.sh

exec su -p -c "/harbor/harbor_jobservice -c /local/Harbor/Config.yaml" harbor