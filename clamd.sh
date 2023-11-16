#!/bin/sh

ACTION=$1

# This is used in the kubernetes deployment readinessProbe
probe_function(){
  clamdscan "${0}"
}


case "$ACTION" in
  probe)
    probe_function
    ;;
  *)
  echo "Usage: $0 [probe]"
esac
