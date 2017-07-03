#!/bin/bash

curl --unix-socket /var/run/docker.sock http:/v1.30/tasks >/dev/null 2>&1

status=$?
if [ $status -ne 0 ]; then
  echo "Failed to curl the docker.sock: $status"
  exit $status
fi

# catch current IPs
current_ips=$(curl --unix-socket /var/run/docker.sock http:/v1.30/tasks | jq -r -j ".[] | .NetworksAttachments[].Addresses[] + .ID");

# lets not relad in the first 30 seconds
sleep 30;

while /bin/true; do

  new_ips=$(curl --unix-socket /var/run/docker.sock http:/v1.30/tasks | jq -r -j ".[] | .NetworksAttachments[].Addresses[] + .ID");

  if [ "$new_ips" != "$current_ips" ]; then
    echo "It looks like the IPs have changed, restarting Nginx";

    if [ -z "$SLACK_HOOK_URL" ]; then
      curl -X POST --data-urlencode payload="{\"text\": \"Nginx container $(hostname) reloaded in $ENV environment because it detected IPs changes\"}" $SLACK_HOOK_URL;
    fi

    service nginx reload

  fi

  current_ips=$new_ips
  sleep 10

done
