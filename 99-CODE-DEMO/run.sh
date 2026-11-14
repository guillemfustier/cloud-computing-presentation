#!/bin/bash
# Starts (or stops) a Selkies session for one user. Each user is a container with its own ports.
#
#   ./run.sh <n> [password]       # starts session n (0, 1, 2...)
#                                 # default password: sjk005-seminar-user-<n>
#   ./run.sh stop <n>             # stops it
#
# Ports of session n:
#   web (HTTPS)       8080+n
#   Zenoh (ROS 2)     7447+n
#   TURN (WebRTC)     3478+n  tcp/udp
#   TURN relay        65000+20n .. 65019+20n  udp
set -e
IMAGE=selkies-ros

if [ "$1" = "stop" ]; then
  docker stop "selkies-$2"
  exit 0
fi

N="${1:?Usage: ./run.sh <n> [password]}"
PASS="${2:-sjk005-seminar-user-$N}"
HOST_IP="${HOST_IP:-$(ip -4 route get 1.1.1.1 | awk '{for(i=1;i<NF;i++) if($i=="src") print $(i+1)}')}"

WEB=$((8080 + N)); ZENOH=$((7447 + N)); TURN=$((3478 + N))
# Each WebRTC connection uses 2 relay ports and failed ones take a while to be released: leave headroom
RELAY_MIN=$((65000 + 20 * N)); RELAY_MAX=$((RELAY_MIN + 19))

docker run -d --rm --name "selkies-$N" \
  --gpus 1 --shm-size=2g \
  --memory 8g --cpus 4 \
  -e TZ=Europe/Madrid -e PASSWD="$PASS" -e SELKIES_ENABLE_HTTPS=true \
  -e DISPLAY_SIZEW=1600 -e DISPLAY_SIZEH=900 \
  -e SELKIES_TURN_HOST="$HOST_IP" -e TURN_EXTERNAL_IP="$HOST_IP" \
  -e SELKIES_TURN_PORT="$TURN" -e SELKIES_TURN_PROTOCOL=tcp \
  -e TURN_MIN_PORT="$RELAY_MIN" -e TURN_MAX_PORT="$RELAY_MAX" \
  -p "$WEB:8080" -p "$ZENOH:7447" \
  -p "$TURN:$TURN/tcp" -p "$TURN:$TURN/udp" \
  -p "$RELAY_MIN-$RELAY_MAX:$RELAY_MIN-$RELAY_MAX/udp" \
  "$IMAGE" >/dev/null

echo "Session $N started (container selkies-$N)"
echo "  Desktop:     https://$HOST_IP:$WEB"
echo "  User:        ubuntu"
echo "  Password:    $PASS"
echo "  ROS 2/Zenoh: tcp/$HOST_IP:$ZENOH"
