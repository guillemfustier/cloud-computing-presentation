# 01 Selkies: sharing your GPU to simulate robots

This document explains the demo we built: a PC with an NVIDIA GPU runs Gazebo. In our case it is **eloi-ubuntu**, a personal PC with a 12 GB RTX 3060; in the rest of the document we call it **the server PC**. Another person sees and controls it from their browser, and connects their ROS 2 nodes from their laptop, **even if their laptop has no NVIDIA GPU**.

Alternatives considered: [[02-Kasm-Workspaces|Kasm Workspaces]] (ruled out, see its note).

---

## 1. What Selkies is

[Selkies](https://github.com/selkies-project) is an open-source project (MPL-2.0 license) that **streams a Linux desktop to the browser over WebRTC**, the same technology used by video calls. It was born for academic and Kubernetes clusters, as a "GPU remote desktop for HPC".

Its `nvidia-egl-desktop` image is a container that already ships with everything needed:

| Component (already in the image) | What it is for |
|---|---|
| KDE Plasma desktop on a virtual X server | The screen where applications are drawn |
| **VirtualGL** (`vglrun -d egl`) | Makes the applications' OpenGL (Gazebo, RViz) render on the **NVIDIA GPU** instead of in software |
| GStreamer + **NVENC** encoder (`nvh264enc`) | Compresses the screen into H.264 video on the GPU itself |
| `selkies-gstreamer` + nginx | Web page, login and sending the video over WebRTC; keyboard and mouse back |
| **TURN** server (coturn) | Relays the video when the browser and the container cannot see each other directly |

For whoever connects, it is just opening a URL and getting a Linux desktop with a GPU in a tab. **Nothing to install** to view the simulation.

### Which version we use and why

- The current Selkies generation (`selkies-egl-desktop`) only exists for **Ubuntu 26.04**.
- ROS 2 **Jazzy** (the one on our laptop) only has packages for **Ubuntu 24.04**. To talk over Zenoh, server and client must use the same ROS distribution.
- That is why we start from the previous generation, **`ghcr.io/selkies-project/nvidia-egl-desktop:24.04`**, which is still published.

## 2. How we adapted it to our use case

We did not program any platform. We only added ROS 2 to the Selkies image and wrote a launch script. Everything is in the repository's [`99-CODE-DEMO/`](../../99-CODE-DEMO/README.md) folder, separate from this documentation:

| File | What it does |
|---|---|
| [`Dockerfile`](../../99-CODE-DEMO/Dockerfile) | Starts from Selkies 24.04 and adds ROS 2 Jazzy (`ros-base`), Gazebo Harmonic + `ros_gz_bridge`, `rmw_zenoh_cpp`, RViz2 and `teleop_twist_keyboard` |
| [`zenohd.conf`](../../99-CODE-DEMO/zenohd.conf) | supervisord program: starts the **Zenoh router** when the container starts |
| [`sim.sh`](../../99-CODE-DEMO/sim.sh) | `sim <world>` command: launches Gazebo with the world and the Gazebo ↔ ROS 2 bridge |
| [`worlds/`](../../99-CODE-DEMO/worlds) | One directory per world with its `bridge.yaml`; the `world.sdf` is copied from the Gazebo examples at build time, except for `g1_mesa` and `go2_parque`, which bring their own plus the Unitree models in `models/` |
| [`desktop/`](../../99-CODE-DEMO/desktop) | Desktop shortcuts: *Gazebo: diff_drive*, *sensors_demo*, *shapes* and *RViz2* |
| [`run.sh`](../../99-CODE-DEMO/run.sh) | Starts or stops session `n`, each with its own ports and password |

```
┌────────────────────────────────────────┐
│ User's laptop (no NVIDIA)              │
│   - Browser                            │
│   - Zenoh router + ROS 2 nodes         │
└────────────────────────────────────────┘
        │  HTTPS :8080   desktop
        │  TURN  :3478   WebRTC video
        │  TCP   :7447   ROS 2 (Zenoh)
        ▼
┌────────────────────────────────────────┐
│ Server PC (RTX 3060)                   │
│   Container selkies-0 (Ubuntu 24.04)   │
│   ├─ KDE desktop + Selkies             │
│   ├─ Gazebo, rendered on the GPU       │
│   ├─ ros_gz_bridge (Gazebo - ROS 2)    │
│   └─ Zenoh router                      │
└────────────────────────────────────────┘
```

### Why Zenoh and not the default DDS

ROS 2 uses DDS by default, which discovers nodes via **multicast**. University WiFi networks and VPNs (Tailscale included) usually block it or do not forward it. With **Zenoh** (`rmw_zenoh_cpp`, an official ROS 2 RMW) **a single TCP connection to one port** is enough. In addition, each container has its own router, so each user only sees their own topics, without handing out `ROS_DOMAIN_ID`s.

### Included worlds

| World | ROS 2 topics |
|---|---|
| `diff_drive` | `/cmd_vel` (input, moves the blue car), `/odom`, `/clock` |
| `sensors_demo` | `/camera`, `/scan`, `/clock` |
| `shapes` | `/clock` |
| `g1_mesa` | Unitree G1 humanoid (29 joints) anchored in front of a table: `/g1/cmd/<joint>` (input), `/g1/joint_states`, `/g1/camara`, `/clock` |
| `go2_parque` | Unitree Go2 quadruped in a 16 × 16 m park: `/go2/cmd_vel` (input, slides the body without walking), `/go2/cmd/<joint>`, `/go2/odom`, `/go2/imu`, `/go2/scan`, `/go2/points`, `/go2/camara`, `/clock` |

To add a world: create `worlds/<name>/world.sdf` and `bridge.yaml` (type table in the `ros_gz_bridge` README) and rebuild the image.

## 3. Server PC requirements

- Ubuntu with an NVIDIA GPU and the proprietary driver (tested with driver 580).
- **Docker** and **NVIDIA Container Toolkit** (`docker info` must list the `nvidia` runtime).
- About **16 GB of disk** for the image (a download of about 4 GB).
- Nothing else: no ROS, no Python, no packages on the host. Everything lives in the container.

Build the image (once):

```bash
cd 99-CODE-DEMO     # inside the cloned repository
docker build -t selkies-ros .
```

## 4. One person

```bash
./run.sh 0
```

Output:

```
Session 0 started (container selkies-0)
  Desktop:     https://192.168.10.202:8080
  User:        ubuntu
  Password:    sjk005-seminar-user-0
  ROS 2/Zenoh: tcp/192.168.10.202:7447
```

What `run.sh` does under the hood:

```bash
docker run -d --rm --name selkies-0 \
  --gpus 1 --shm-size=2g --memory 8g --cpus 4 \
  -e PASSWD=sjk005-seminar-user-0 -e SELKIES_ENABLE_HTTPS=true \
  -e SELKIES_TURN_HOST=<server-ip> \
  -e TURN_EXTERNAL_IP=<server-ip> \
  -e SELKIES_TURN_PORT=3478 -e SELKIES_TURN_PROTOCOL=tcp \
  -e TURN_MIN_PORT=65000 -e TURN_MAX_PORT=65019 \
  -p 8080:8080 -p 7447:7447 -p 3478:3478/tcp -p 3478:3478/udp \
  -p 65000-65019:65000-65019/udp \
  selkies-ros
```

Important details:

- **`SELKIES_TURN_HOST` / `TURN_EXTERNAL_IP`**: the address of the video relay (TURN, see [[#How the video gets through: WebRTC and TURN]]). By default Selkies uses the server's **public IP**, which on a university network is the campus NAT's and the browser cannot reach it. `run.sh` sets it to the server's local IP.
- **`SELKIES_ENABLE_HTTPS=true`**: so the password does not travel in clear text. The certificate is self-signed and the browser warns the first time.
- **`--memory` and `--cpus`** limit RAM and CPU. **VRAM cannot be limited**: all sessions share the 12 GB.

Stop the session: `./run.sh stop 0`.

## 5. More than one person

Selkies has no portal or multi-user login: **one session is one container**. For several people, one container per person is launched with different ports:

```bash
./run.sh 0      # password sjk005-seminar-user-0
./run.sh 1      # password sjk005-seminar-user-1
./run.sh 2      # ...
```

| Port | Session `n` | Session 0 | Session 1 | Protocol |
|---|---|---|---|---|
| Web (desktop) | 8080 + n | 8080 | 8081 | TCP |
| Zenoh (ROS 2) | 7447 + n | 7447 | 7448 | TCP |
| TURN (video) | 3478 + n | 3478 | 3479 | TCP and UDP |
| TURN relay | 65000 + 20n … +19 | 65000–65019 | 65020–65039 | UDP |

Each container has **its own desktop, its own Gazebo and its own Zenoh router**, so users do not see each other. Verified: with `diff_drive` open in session 0, `ros2 topic list` in session 1 does not show `/odom` or `/cmd_vel`.

Measured GPU usage with 2 sessions and one Gazebo open: **~620 MiB of 12 GB** (Gazebo GUI ~290 MiB). With simple worlds several sessions fit; with cameras and LiDAR, fewer. It is worth keeping an eye on it with `watch -n1 nvidia-smi`.

> **What is missing compared to a full platform:** there is no portal for each user to launch their own session, no centralised login and no automatic expiry. The administrator does it by hand with `run.sh`. That is what platforms such as [[02-Kasm-Workspaces|Kasm Workspaces]] exist for.

## 6. Ports and network

### How the video gets through: WebRTC and TURN

Selkies sends the desktop as **WebRTC video**, the same technology as Google Meet or Discord. WebRTC first tries to send the video **directly** from sender to receiver: each side tells the other "I am at this address, send it to me here".

Here that does not work: the sender is **inside a Docker container**, with an internal address (`172.17.0.x`) that only exists inside the server PC. The laptop cannot reach it.

The standard solution is **TURN**, a **video relay**. It is a small server (coturn, already included in the Selkies image) that both sides can reach: the container sends it the video and the browser picks it up from there.

```
Without TURN:
  container (172.17.0.x) ──X──> browser
  (internal address: the laptop cannot reach it)

With TURN:
  container ──> TURN 192.168.10.202:3478 ──> browser
```

| Component | What it is | Port in session 0 |
|---|---|---|
| Relay address (`SELKIES_TURN_HOST`) | The IP given to the browser to find the TURN server | `192.168.10.202` |
| TURN port | The "front door" to the relay | 3478 (TCP and UDP) |
| Relay ports | The "channels" the relay opens for each video connection | 65000–65019 (UDP) |

Because of Docker, **the video always goes through TURN**, even on the local network. Each video connection uses 2 channels and failed ones take a few minutes to release them, so you need to leave some headroom: that is why `run.sh` reserves **20 channels per session**.

### From the same network

It is enough for the laptop to reach the server's IP. Quick check from the laptop:

```bash
nc -vz 192.168.10.202 8080    # web
nc -vz 192.168.10.202 7447    # Zenoh
nc -vz 192.168.10.202 3478    # TURN
```

### From outside, with Tailscale

Tested from another network, with the laptop on Tailscale and a node acting as **subnet router** towards `192.168.10.0/24`. The URLs and endpoints are the same (`192.168.10.202`).

Nothing special is needed: the TURN relay is at `192.168.10.202`, which is reachable through Tailscale just like the web and Zenoh.

**Problem we ran into here:** at first `run.sh` reserved only 2 relay channels per session. On the local network they were enough, because the first connection found them free. Over Tailscale there were reconnections, the channels ran out and the TURN log showed `ALLOCATE ... error 508: Cannot create socket`: the web page reconnected every few seconds without showing the desktop. It was fixed by increasing to 20 channels per session.

## 7. Connecting the user's ROS 2 nodes over Zenoh

Requirement on the laptop: ROS 2 **Jazzy** and Zenoh.

```bash
sudo apt install ros-jazzy-rmw-zenoh-cpp
```

**Terminal 1**: local Zenoh router connected to the router of your session (port 7447 + n):

```bash
source /opt/ros/jazzy/setup.bash
export ZENOH_CONFIG_OVERRIDE='connect/endpoints=["tcp/192.168.10.202:7447"]'
ros2 run rmw_zenoh_cpp rmw_zenohd
```

**Terminal 2 onwards**: your usual nodes, changing only the RMW:

```bash
source /opt/ros/jazzy/setup.bash
export RMW_IMPLEMENTATION=rmw_zenoh_cpp      # best in ~/.bashrc

ros2 topic pub -r 10 /cmd_vel geometry_msgs/msg/Twist "{linear: {x: 0.5}, angular: {z: 0.3}}" # example to make the robot turn
```



Why a local router? With `rmw_zenoh`, each node looks for a router at `localhost:7447`. If that router is connected to the server's, **all** tools (`ros2 topic`, `ros2 launch`, `rviz2`, your own nodes…) work without any further configuration. If the nodes use simulation time, start them with `use_sim_time:=true`, because `/clock` comes from Gazebo.

## 8. Commands to try

### In the browser

1. Open `https://192.168.10.202:8080`, accept the certificate warning and log in with `ubuntu` / `sjk005-seminar-user-0`.
2. Double-click **Gazebo: diff_drive** (or open a terminal on the desktop and type `sim diff_drive`).

### On the laptop (with the router from terminal 1 running)

```bash
# Session topics: /clock /cmd_vel /odom ...
ros2 topic list

# Car odometry
ros2 topic echo /odom --once

# Move it (Ctrl+C to stop publishing)
ros2 topic pub -r 10 /cmd_vel geometry_msgs/msg/Twist \
  "{linear: {x: 0.5}, angular: {z: 0.3}}"

# Stop it (it keeps the last velocity received)
ros2 topic pub --once /cmd_vel geometry_msgs/msg/Twist "{}"

# Drive it with the keyboard
ros2 run teleop_twist_keyboard teleop_twist_keyboard
```

The blue car moves in the browser tab.

### Isolation between users (on the laptop)

With Gazebo open only in session 0, stop the router from terminal 1 and connect it to **session 1** (port 7448):

```bash
export ZENOH_CONFIG_OVERRIDE='connect/endpoints=["tcp/192.168.10.202:7448"]'
ros2 run rmw_zenoh_cpp rmw_zenohd
```

In terminal 2, `ros2 topic list` no longer shows `/odom` or `/cmd_vel`: each user only sees the topics of their own session.

### Administrator checks (optional, on the server PC)

**They are not needed to use the demo.** They are useful to show that the GPU doing the work is the server's and to diagnose problems. They are typed in a terminal on the server PC. Those starting with `docker exec selkies-0` run the command *inside* the session 0 container.

```bash
# Which sessions are running
docker ps --filter name=selkies

# GPU usage: with Gazebo open, "gz sim gui" appears
watch -n1 nvidia-smi

# Which GPU renders: it should say NVIDIA GeForce RTX 3060
docker exec selkies-0 vglrun -d egl glxinfo -B | grep renderer

# Container services (zenohd included)
docker exec selkies-0 supervisorctl status

# Video log (WebRTC and TURN)
docker exec selkies-0 tail -f /tmp/selkies-gstreamer-entrypoint.log

# Zenoh router log
docker exec selkies-0 tail -f /tmp/zenohd.log
```

## 9. Limitations

- **One user per container**: multi-user is done by hand. No portal, no accounts, no automatic expiry.
- **VRAM is not isolated**: a user with a heavy world can leave the others without memory.
- Demo-grade security: predictable passwords (`sjk005-seminar-user-n`) and a self-signed certificate. Fine on a trusted network, **not for exposing to the Internet**.
- Users have a terminal with (fake) `sudo` inside the container and Internet access: only give access to trusted people.
- Both sides must use the same ROS 2 distribution.
- The 24.04 image is the previous Selkies generation: it works, but it no longer receives new features.

## Sources

- [selkies-project/docker-nvidia-egl-desktop](https://github.com/selkies-project/docker-nvidia-egl-desktop)
- [Selkies (GitHub organisation)](https://github.com/selkies-project)
- [rmw_zenoh](https://github.com/ros2/rmw_zenoh)
- [ros_gz_bridge](https://github.com/gazebosim/ros_gz/tree/jazzy/ros_gz_bridge)
- [National Research Platform: GUI desktop (Selkies on an academic cluster)](https://docs.nationalresearchplatform.org/userdocs/running/gui-desktop)
