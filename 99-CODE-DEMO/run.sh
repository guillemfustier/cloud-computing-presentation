#!/bin/bash
# Lanza (o para) una sesión Selkies para un usuario. Cada usuario es un contenedor con sus propios puertos.
#
#   ./run.sh <n> [contraseña]     # lanza la sesión n (0, 1, 2...)
#                                 # contraseña por defecto: sjk005-seminar-user-<n>
#   ./run.sh stop <n>             # la para
#
# Puertos de la sesión n:
#   web (HTTPS)       8080+n
#   Zenoh (ROS 2)     7447+n
#   TURN (WebRTC)     3478+n  tcp/udp
#   relay TURN        65000+20n .. 65019+20n  udp
set -e
IMAGE=selkies-ros

if [ "$1" = "stop" ]; then
  docker stop "selkies-$2"
  exit 0
fi

N="${1:?Uso: ./run.sh <n> [contraseña]}"
PASS="${2:-sjk005-seminar-user-$N}"
HOST_IP="${HOST_IP:-$(ip -4 route get 1.1.1.1 | awk '{for(i=1;i<NF;i++) if($i=="src") print $(i+1)}')}"

WEB=$((8080 + N)); ZENOH=$((7447 + N)); TURN=$((3478 + N))
# Cada conexión WebRTC gasta 2 puertos de relay y las fallidas tardan en liberarse: dejar margen
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

echo "Sesión $N lanzada (contenedor selkies-$N)"
echo "  Escritorio:  https://$HOST_IP:$WEB"
echo "  Usuario:     ubuntu"
echo "  Contraseña:  $PASS"
echo "  ROS 2/Zenoh: tcp/$HOST_IP:$ZENOH"
