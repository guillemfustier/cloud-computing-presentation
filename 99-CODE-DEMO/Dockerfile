# Selkies desktop (WebRTC, NVIDIA GPU) + ROS 2 Jazzy + Gazebo Harmonic + Zenoh
# Base: official Selkies image on Ubuntu 24.04 (Jazzy only has packages for 24.04)
FROM ghcr.io/selkies-project/nvidia-egl-desktop:24.04

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Official ROS 2 repository (ros2-apt-source package) + ROS base, Gazebo, bridge, Zenoh and RViz
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates \
 && VER=$(curl -fsSL https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F '"tag_name"' | cut -d'"' -f4) \
 && curl -fsSL -o /tmp/ros2-apt-source.deb \
      "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${VER}/ros2-apt-source_${VER}.noble_all.deb" \
 && apt-get install -y /tmp/ros2-apt-source.deb && rm /tmp/ros2-apt-source.deb \
 && apt-get update && apt-get install -y --no-install-recommends \
      ros-jazzy-ros-base ros-jazzy-ros-gz ros-jazzy-rmw-zenoh-cpp \
      ros-jazzy-rviz2 ros-jazzy-teleop-twist-keyboard \
 && rm -rf /var/lib/apt/lists/*

ENV RMW_IMPLEMENTATION=rmw_zenoh_cpp

# Worlds: the Gazebo Harmonic examples + one bridge.yaml per world
COPY worlds/ /opt/worlds/
RUN GZW=/opt/ros/jazzy/opt/gz_sim_vendor/share/gz/gz-sim8/worlds \
 && for w in /opt/worlds/*/; do n=$(basename "$w"); [ -f "$w/world.sdf" ] || cp "$GZW/$n.sdf" "$w/world.sdf"; done

# World launcher, and Zenoh router started by supervisord when the container starts
COPY sim.sh /usr/local/bin/sim
COPY zenohd.conf /etc/supervisor/conf.d/zenohd.conf
RUN chmod 755 /usr/local/bin/sim

# Desktop shortcuts and ROS environment in every terminal
COPY --chown=1000:1000 desktop/ /home/ubuntu/Desktop/
RUN chmod 755 /home/ubuntu/Desktop/*.desktop \
 && echo 'source /opt/ros/jazzy/setup.bash' >> /home/ubuntu/.bashrc

USER 1000
