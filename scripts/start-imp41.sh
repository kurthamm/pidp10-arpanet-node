#!/usr/bin/env bash
set -euo pipefail
cd /home/pi/arpanet-bridge
mkdir -p logs
if screen -list | grep -q '[.]imp41'; then
  echo 'imp41 already running'
  exit 0
fi
screen -dmS imp41 /opt/pidp10/bin/h316-arpa /home/pi/arpanet-bridge/imp41.simh
sleep 1
screen -ls | grep imp41 || true
