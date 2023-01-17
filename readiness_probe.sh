#!/bin/bash
MAIN_FILE="/var/lib/clamav/main.cvd"
if [[ -e ${MAIN_FILE} ]]
then
    echo "ready"
    exit 0
else
    echo "not ready"
    exit 1
fi