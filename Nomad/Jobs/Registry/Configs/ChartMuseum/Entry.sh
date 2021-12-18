#!/bin/sh
set -e

echo "Starting sutff"

mkdir -p /etc/harbor/ssl
cp /local/CA.pem /etc/harbor/ssl/ca.crt

/home/chart/install_cert.sh

exec su -p -c "/home/chart/chartm" chart