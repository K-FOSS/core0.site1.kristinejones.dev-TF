#!/bin/sh

echo "HelloWorld"

mkdir -p /etc/harbor/ssl

cp /local/CA.pem /etc/harbor/ssl/ca.crt

ls -lah /etc/harbor/ssl

/harbor/install_cert.sh

exec su harbor --command "/harbor/harbor_core"