#!/bin/sh

cat /local/TLS/RegistryCA.pem

exec /scripts/entrypoint.sh /bin/sh -c /scripts/process-wrapper