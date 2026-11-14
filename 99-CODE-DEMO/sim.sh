#!/bin/bash
# Usage: sim <world>    (diff_drive | sensors_demo | shapes | g1_mesa | go2_parque)
# Starts Gazebo with the world and the Gazebo <-> ROS 2 bridge defined in its bridge.yaml.
W="${1:-diff_drive}"
D="/opt/worlds/$W"
[ -f "$D/world.sdf" ] || { echo "Unknown world: $W. Available: $(ls /opt/worlds)"; exit 1; }

source /opt/ros/jazzy/setup.bash
[ -d "$D/models" ] && export GZ_SIM_RESOURCE_PATH="$D/models"

ros2 run ros_gz_bridge parameter_bridge --ros-args -p config_file:="$D/bridge.yaml" &
BRIDGE=$!
trap 'kill $BRIDGE 2>/dev/null' EXIT

# The whole desktop runs under VirtualGL (vglrun -d egl), so Gazebo renders on the GPU
gz sim -r "$D/world.sdf"
