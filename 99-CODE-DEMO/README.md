# Demo: tu propia nube de simulación con Selkies

Un PC con GPU NVIDIA (el **servidor**) ejecuta Gazebo dentro de un contenedor. Otras personas lo ven y lo manejan desde su navegador, y conectan sus nodos ROS 2 desde su portátil por Zenoh.

Explicación completa (qué es Selkies, puertos, TURN, problemas típicos): [`00-VAULT/03-DEMO-SELKIES/01-Selkies.md`](../00-VAULT/03-DEMO-SELKIES/01-Selkies.md).

## Requisitos

**Servidor:** Linux con GPU NVIDIA y su driver, Docker, NVIDIA Container Toolkit, unos 16 GB de disco libres y conexión a Internet.

Comprobar que Docker ve la GPU (debe mostrar la tabla de `nvidia-smi`):

```bash
docker run --rm --gpus all ubuntu nvidia-smi
```

Si falla, configurar el toolkit para Docker:

```bash
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

**Usuario:** un navegador. Para conectar nodos ROS 2: Ubuntu 24.04 con ROS 2 **Jazzy**.

## 1. Servidor: construir y lanzar

```bash
git clone https://github.com/guillemfustier/cloud-computing-presentation.git
cd cloud-computing-presentation/99-CODE-DEMO
docker build -t selkies-ros .     # una sola vez, tarda unos minutos
./run.sh 0                        # lanza la sesión 0
```

`run.sh` muestra la dirección, el usuario y la contraseña de la sesión:

```
Sesión 0 lanzada (contenedor selkies-0)
  Escritorio:  https://<ip-servidor>:8080
  Usuario:     ubuntu
  Contraseña:  sjk005-seminar-user-0
  ROS 2/Zenoh: tcp/<ip-servidor>:7447
```

Si la IP detectada no es la de la red de los usuarios, indicarla a mano:

```bash
HOST_IP=192.168.10.202 ./run.sh 0
```

Parar la sesión:

```bash
./run.sh stop 0
```

## 2. Usuario: ver la simulación

1. Abrir `https://<ip-servidor>:8080` en el navegador.
2. Aceptar el aviso del certificado (es autofirmado).
3. Entrar con usuario `ubuntu` y contraseña `sjk005-seminar-user-0`.
4. En el escritorio, doble clic en **Gazebo: diff_drive** (o **Gazebo: g1_mesa** / **Gazebo: go2_parque** para los robots Unitree).

## 3. Usuario: conectar nodos ROS 2 por Zenoh

Instalar Zenoh y el teleoperador de teclado (una vez):

```bash
sudo apt install ros-jazzy-rmw-zenoh-cpp ros-jazzy-teleop-twist-keyboard
```

**Terminal 1**, router Zenoh local conectado al servidor (dejarlo abierto):

```bash
source /opt/ros/jazzy/setup.bash
export ZENOH_CONFIG_OVERRIDE='connect/endpoints=["tcp/<ip-servidor>:7447"]'
ros2 run rmw_zenoh_cpp rmw_zenohd
```

**Terminal 2**, comandos ROS 2 normales:

```bash
source /opt/ros/jazzy/setup.bash
export RMW_IMPLEMENTATION=rmw_zenoh_cpp
ros2 topic list                   # /clock /cmd_vel /odom ...
ros2 run teleop_twist_keyboard teleop_twist_keyboard
```

El coche azul se mueve en el navegador.

## Varios usuarios

Una sesión por persona, cada una con sus puertos y su contraseña:

```bash
./run.sh 1        # web :8081, Zenoh :7448, contraseña sjk005-seminar-user-1
./run.sh 2        # web :8082, Zenoh :7449, contraseña sjk005-seminar-user-2
```

El usuario de la sesión `n` usa el puerto web `8080 + n` y el de Zenoh `7447 + n`.
