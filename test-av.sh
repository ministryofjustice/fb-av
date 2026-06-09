#!/usr/bin/env bash

echo "checking config"
CLAMD_CONF="test.clamd.container.conf"

if [[ ! -f "$CLAMD_CONF" ]]; then
    echo "Config missing"
    exit 1
fi

while read -r key value; do
    [[ -z "$key" ]] && continue
    var_name=$(echo "$key" | tr '[:lower:]' '[:upper:]')
    declare "$var_name"="$value"
done < "$CLAMD_CONF"

echo "--------------------------------------------------------------------------"
echo ""

echo "check clamav is running in docker"
TIMEOUT=2
RESPONSE=$(echo PING | nc -w "$TIMEOUT" "$TCPADDR" "$TCPSOCKET")
if [[ "$RESPONSE" == "PONG" ]]; then
    echo "OK: ClamAV is alive (PONG)"
    echo "--------------------------------------------------------------------------"
    echo ""
else
    echo "Uh oh... No PONG. Try running docker compose up"
    echo "--------------------------------------------------------------------------"
    echo ""
    exit 1
fi

echo "Streaming test file payload..."
output=$(clamdscan --stream --config-file="test.clamd.container.conf" README.md)
echo "$output"
echo ""
echo "--------------------------------------------------------------------------"
echo ""
# EICAR payload (in memory, no file)
EICAR='X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
echo "Streaming EICAR test payload..."
output=$(printf "%s" "$EICAR" | clamdscan --stream -c "$CLAMD_CONF" - 2>&1)
echo "$output"
