#!/bin/bash
# Uso: sim <mundo>    (diff_drive | sensors_demo | shapes | g1_mesa | go2_parque)
# Arranca Gazebo con el mundo y el bridge Gazebo <-> ROS 2 definido en su bridge.yaml.
W="${1:-diff_drive}"
D="/opt/worlds/$W"
[ -f "$D/world.sdf" ] || { echo "Mundo desconocido: $W. Disponibles: $(ls /opt/worlds)"; exit 1; }

source /opt/ros/jazzy/setup.bash
[ -d "$D/models" ] && export GZ_SIM_RESOURCE_PATH="$D/models"

ros2 run ros_gz_bridge parameter_bridge --ros-args -p config_file:="$D/bridge.yaml" &
BRIDGE=$!
trap 'kill $BRIDGE 2>/dev/null' EXIT

# El escritorio entero corre bajo VirtualGL (vglrun -d egl), así que Gazebo renderiza en la GPU
gz sim -r "$D/world.sdf"
