#!/bin/sh

cat /local/TLS/RegistryCA.pem >> /etc/ssl/certs/ca-certificates.crt
cat secrets/TLS/CA.pem >> /etc/ssl/certs/ca-certificates.crt

exec /scripts/entrypoint.sh /bin/sh -c /scripts/process-wrapper