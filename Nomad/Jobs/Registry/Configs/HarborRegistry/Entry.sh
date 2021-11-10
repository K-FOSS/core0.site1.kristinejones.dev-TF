#!/bin/sh



set -e

echo "Starting sutff"

mkdir -p /etc/harbor/ssl
cp /local/CA.pem /etc/harbor/ssl/ca.crt

/home/harbor/install_cert.sh

echo "HelloWorld"

exec su -p -c "/usr/bin/registry_DO_NOT_USE_GC serve /local/HarborRegistry/Config.yaml" harbor