#!/bin/sh

echo "Starting Server"

FINISH_FILE="/data/.done"

if [ -f "$${FINISH_FILE}" ]; then

echo "${HookFile}" | tar zxf -C /data -

touch $${FINISH_FILE}

exit 0

else

echo "Already done"

exit 0

fi

