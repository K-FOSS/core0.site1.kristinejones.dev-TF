#!/bin/sh
echo "HelloWorld"

mkdir -p /var/lib/stork-agent/certs

/usr/sbin/stork-agent register --server-url http://StorkServer:8080  --agent-address $HOSTNAME:8080


/usr/sbin/keactrl start -c /local/keactrl.conf

echo "Starking Stork Agent"

/usr/sbin/stork-agent start --server-url http://StorkServer:8080  --agent-address $HOSTNAME:8080 --prometheus-kea-exporter-port {{ env "NOMAD_PORT_metrics" }}

exec watch -n 5 /usr/sbin/keactrl status