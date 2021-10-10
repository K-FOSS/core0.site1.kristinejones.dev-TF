#!/bin/sh

echo "Starting Server"

FINISH_FILE="/data/.done"

rm -rf $${FINISH_FILE}

if [ ! -f "$${FINISH_FILE}" ]; then

wget -O - ${HOOK_URL} | tar zxf - -C /data

touch $${FINISH_FILE}

exit 0

else

echo "Already done"

exit 0

fi

