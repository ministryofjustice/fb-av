#!/bin/sh

ACTION=$1

# This is used in the kubernetes deployment readinessProbe
probe_function(){
  clamdscan "${0}"

  if [ $? -eq 0 ]; then
    echo 'Clamdscan probe OK'
  else
    echo 'Clamdscan probe unsuccessful'
    exit 1
  fi
}


case "$ACTION" in
  probe)
    probe_function
    ;;
  *)
  echo "Usage: $0 [probe]"
esac
