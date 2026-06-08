#!/usr/bin/env bash

CLAMD_CONF="test.clamd.container.conf"
echo "--------------------------------------------------------------------------"
echo ""
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
