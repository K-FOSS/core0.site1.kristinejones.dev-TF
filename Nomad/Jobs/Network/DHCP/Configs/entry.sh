#!/bin/sh
echo "HelloWorld"

/usr/sbin/keactrl start -c /local/keactrl.conf

echo "Starking Stork Agent"

exec tail -f /dev/null