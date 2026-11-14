# Demo: your own simulation cloud with Selkies

A PC with an NVIDIA GPU (the **server**) runs Gazebo inside a container. Other people see and control it from their browser, and connect their ROS 2 nodes from their laptop over Zenoh.

Full explanation (what Selkies is, ports, TURN, common problems): [`00-VAULT/03-DEMO-SELKIES/01-Selkies.md`](../00-VAULT/03-DEMO-SELKIES/01-Selkies.md).

## Requirements

**Server:** Linux with an NVIDIA GPU and its driver, Docker, NVIDIA Container Toolkit, about 16 GB of free disk and an Internet connection.

Check that Docker sees the GPU (it should print the `nvidia-smi` table):

```bash
docker run --rm --gpus all ubuntu nvidia-smi
```

If it fails, configure the toolkit for Docker:

```bash
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

**User:** a browser. To connect ROS 2 nodes: Ubuntu 24.04 with ROS 2 **Jazzy**.

## 1. Server: build and launch

```bash
git clone https://github.com/guillemfustier/cloud-computing-presentation.git
cd cloud-computing-presentation/99-CODE-DEMO
docker build -t selkies-ros .     # only once, takes a few minutes
./run.sh 0                        # launches session 0
```

`run.sh` prints the session's address, user and password:

```
Session 0 started (container selkies-0)
  Desktop:     https://<server-ip>:8080
  User:        ubuntu
  Password:    sjk005-seminar-user-0
  ROS 2/Zenoh: tcp/<server-ip>:7447
```

If the detected IP is not the one on the users' network, set it by hand:

```bash
HOST_IP=192.168.10.202 ./run.sh 0
```

Stop the session:

```bash
./run.sh stop 0
```

## 2. User: view the simulation

1. Open `https://<server-ip>:8080` in the browser.
2. Accept the certificate warning (it is self-signed).
3. Log in with user `ubuntu` and password `sjk005-seminar-user-0`.
4. On the desktop, double-click **Gazebo: diff_drive** (or **Gazebo: g1_mesa** / **Gazebo: go2_parque** for the Unitree robots).

## 3. User: connect ROS 2 nodes over Zenoh

Install Zenoh and the keyboard teleoperator (once):

```bash
sudo apt install ros-jazzy-rmw-zenoh-cpp ros-jazzy-teleop-twist-keyboard
```

**Terminal 1**, local Zenoh router connected to the server (leave it open):

```bash
source /opt/ros/jazzy/setup.bash
export ZENOH_CONFIG_OVERRIDE='connect/endpoints=["tcp/<server-ip>:7447"]'
ros2 run rmw_zenoh_cpp rmw_zenohd
```

**Terminal 2**, regular ROS 2 commands:

```bash
source /opt/ros/jazzy/setup.bash
export RMW_IMPLEMENTATION=rmw_zenoh_cpp
ros2 topic list                   # /clock /cmd_vel /odom ...
ros2 run teleop_twist_keyboard teleop_twist_keyboard
```

The blue car moves in the browser.

## Multiple users

One session per person, each with its own ports and password:

```bash
./run.sh 1        # web :8081, Zenoh :7448, password sjk005-seminar-user-1
./run.sh 2        # web :8082, Zenoh :7449, password sjk005-seminar-user-2
```

The user of session `n` uses web port `8080 + n` and Zenoh port `7447 + n`.
