#!/bin/sh

mkdir -p /etc/harbor/ssl

cp /local/CA.pem /etc/harbor/ssl/ca.crt
/harbor/install_cert.sh

exec /harbor/harbor_core