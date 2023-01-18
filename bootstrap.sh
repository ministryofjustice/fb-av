#!/bin/bash
# bootstrap clam av service and clam av database updater shell script
# copied from https://github.com/mko-x/docker-clamav

set -m
MAIN_FILE="/var/lib/clamav/main.cvd"
# start clam service itself and the updater in background as daemon
freshclam -d &
echo -e "waiting for clam to update..."
until [[ -e ${MAIN_FILE} ]]
do
    :
done
echo -e "starting clamd..."
clamd &

# start clamav update checker
ruby clamav_check.rb &

# recognize PIDs
pidlist=`jobs -p`

# initialize latest result var
latest_exit=0

# define shutdown helper
function shutdown() {
    trap "" SIGINT

    for single in $pidlist; do
        if ! kill -0 $single 2>/dev/null; then
            wait $single
            latest_exit=$?
        fi
    done

    kill $pidlist 2>/dev/null
}

# run shutdown
trap shutdown SIGINT
wait -n

# return received result
exit $latest_exit
