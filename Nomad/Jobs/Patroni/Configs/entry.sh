#!/bin/sh

chown postgres /dev/watchdog

su postgres

exec /usr/local/bin/patroni /local/Patroni.yaml