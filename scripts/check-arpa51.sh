#!/usr/bin/env bash
set -euo pipefail
printf 'PDP-10 processes:\n'
pgrep -af '^/opt/pidp10/bin/(pidp10|pdp10-ka|pdp10-ka-ncp)' || true
printf '\nIMP/PDP UDP sockets:\n'
ss -uanp | grep -E '11141|20411|20412' || true
printf '\nScreens:\n'
screen -ls || true
