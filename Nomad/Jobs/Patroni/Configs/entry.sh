#!/bin/sh

chown postgres /dev/watchdog

exec su postgres --command /usr/local/bin/patroni /local/Patroni.yaml