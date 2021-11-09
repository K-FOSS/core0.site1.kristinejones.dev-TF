#!/bin/sh

set -e

mkdir -p /etc/harbor/ssl
cp /local/CA.pem /etc/harbor/ssl/ca.pem

/harbor/install_cert.sh

exec /harbor/harbor_jobservice -c /local/Harbor/Config.yaml