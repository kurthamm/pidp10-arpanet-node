#!/usr/bin/env bash
set -euo pipefail
screen -S pidp10 -X quit 2>/dev/null || true
for pid in $(pgrep -f '^/opt/pidp10/bin/(pidp10|pdp10-ka|pdp10-ka-ncp) /opt/pidp10/systems/.*/boot\.(pi|pidp)$' || true); do
  kill "$pid" 2>/dev/null || true
done
sleep 3
cp -a /opt/pidp10/src/its/out/pdp10-ka/rp03.[0-3] /opt/pidp10/src/its/out/pdp10-ka/dskdmp.rim /opt/pidp10/systems/its-arpa51/
/home/pi/arpanet-bridge/start-imp41.sh
screen -dmS pidp10 /opt/pidp10/bin/pdp10-ka-ncp-pidp /opt/pidp10/systems/its-arpa51/boot.pi
