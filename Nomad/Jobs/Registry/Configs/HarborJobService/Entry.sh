#!/bin/sh

set -e

cp /local/CA.pem /etc/harbor/ssl/ca.pem

/harbor/install_cert.sh

exec /harbor/harbor_jobservice -c /local/Harbor/Config.yaml