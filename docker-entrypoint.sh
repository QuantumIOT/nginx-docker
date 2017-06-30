#!/bin/sh

set -e

# start script that checks if IPs list is changed
nohup /ips_check.sh &

status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start ips_check tool: $status"
  exit $status
fi

exec "$@"
