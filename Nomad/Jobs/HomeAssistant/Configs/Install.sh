#!/bin/sh

echo "Starting Server"

FINISH_FILE="/config/.done"

if [ ! -f "$${FINISH_FILE}" ]; then

cd /tmp

git clone https://github.com/KristianFJones/hass.home1.kristianjones.dev.git /tmp/hass-config

mv /tmp/hass-config/Config/* /config/

mv /local/secrets.yaml /config/secrets.yaml

touch $${FINISH_FILE}

exit 0

else

echo "Already done"

exit 0

fi