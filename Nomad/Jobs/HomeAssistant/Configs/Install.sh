#!/bin/sh

apk add --no-cache git rsync

echo "Starting Server"

FINISH_FILE="/config/.done"

git clone https://github.com/KristianFJones/hass.home1.kristianjones.dev.git /tmp/hass-config

if [ ! -f "$${FINISH_FILE}" ]; then

cd /tmp



mv /tmp/hass-config/Config/* /config/

mv /local/secrets.yaml /config/secrets.yaml

touch $${FINISH_FILE}

exit 0

else

rsync -av /tmp/hass-config/Config/ /config/

echo "Already done"

exit 0

fi