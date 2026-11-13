# 01 Selkies: compartir tu GPU para simular robots

Este documento explica la demo que montamos: un PC con GPU NVIDIA ejecuta Gazebo. En nuestro caso es **eloi-ubuntu**, un PC personal con una RTX 3060 de 12 GB; en el resto del documento lo llamamos **el PC servidor**. Otra persona lo ve y lo maneja desde su navegador, y conecta sus nodos ROS 2 desde su portátil, **aunque su portátil no tenga GPU NVIDIA**.

Alternativas consideradas: [[02-Kasm-Workspaces|Kasm Workspaces]] (descartada, ver su nota).

---

## 1. Qué es Selkies

[Selkies](https://github.com/selkies-project) es un proyecto de código abierto (licencia MPL-2.0) que **transmite un escritorio Linux al navegador por WebRTC**, la misma tecnología que usan las videollamadas. Nació para clústeres académicos y de Kubernetes, como "escritorio remoto con GPU para HPC".

Su imagen `nvidia-egl-desktop` es un contenedor que ya trae todo lo necesario:

| Pieza (ya incluida en la imagen) | Para qué sirve |
|---|---|
| Escritorio KDE Plasma sobre un servidor X virtual | La pantalla donde se dibujan las aplicaciones |
| **VirtualGL** (`vglrun -d egl`) | Hace que el OpenGL de las aplicaciones (Gazebo, RViz) se renderice en la **GPU NVIDIA** en lugar de por software |
| GStreamer + codificador **NVENC** (`nvh264enc`) | Comprime la pantalla en vídeo H.264 en la propia GPU |
| `selkies-gstreamer` + nginx | Página web, login y envío del vídeo por WebRTC; teclado y ratón de vuelta |
| Servidor **TURN** (coturn) | Relay del vídeo cuando el navegador y el contenedor no se ven directamente |

Para quien se conecta, es abrir una URL y tener un escritorio Linux con GPU en una pestaña. **No instala nada** para ver la simulación.

### Qué versión usamos y por qué

- La generación actual de Selkies (`selkies-egl-desktop`) solo existe para **Ubuntu 26.04**.
- ROS 2 **Jazzy** (el que tenemos en el portátil) solo tiene paquetes para **Ubuntu 24.04**. Para hablar por Zenoh, servidor y cliente deben usar la misma distribución de ROS.
- Por eso partimos de la generación anterior, **`ghcr.io/selkies-project/nvidia-egl-desktop:24.04`**, que sigue publicada.

## 2. Cómo lo adaptamos a nuestro uso

No programamos ninguna plataforma. Solo añadimos ROS 2 a la imagen de Selkies y escribimos un script de lanzamiento. Todo está en la carpeta [`99-CODE-DEMO/`](../../99-CODE-DEMO/README.md) del repositorio, separada de esta documentación:

| Archivo | Qué hace |
|---|---|
| [`Dockerfile`](../../99-CODE-DEMO/Dockerfile) | Parte de Selkies 24.04 y añade ROS 2 Jazzy (`ros-base`), Gazebo Harmonic + `ros_gz_bridge`, `rmw_zenoh_cpp`, RViz2 y `teleop_twist_keyboard` |
| [`zenohd.conf`](../../99-CODE-DEMO/zenohd.conf) | Programa de supervisord: arranca el **router Zenoh** al iniciar el contenedor |
| [`sim.sh`](../../99-CODE-DEMO/sim.sh) | Comando `sim <mundo>`: lanza Gazebo con el mundo y el bridge Gazebo ↔ ROS 2 |
| [`worlds/`](../../99-CODE-DEMO/worlds) | Un directorio por mundo con su `bridge.yaml`; el `world.sdf` se copia de los ejemplos de Gazebo al construir |
| [`desktop/`](../../99-CODE-DEMO/desktop) | Accesos directos en el escritorio: *Gazebo: diff_drive*, *sensors_demo*, *shapes* y *RViz2* |
| [`run.sh`](../../99-CODE-DEMO/run.sh) | Lanza o para la sesión `n`, cada una con sus propios puertos y contraseña |

```
┌────────────────────────────────────────┐
│ Portátil del usuario (sin NVIDIA)      │
│   - Navegador                          │
│   - Router Zenoh + nodos ROS 2         │
└────────────────────────────────────────┘
        │  HTTPS :8080   escritorio
        │  TURN  :3478   vídeo WebRTC
        │  TCP   :7447   ROS 2 (Zenoh)
        ▼
┌────────────────────────────────────────┐
│ PC servidor (RTX 3060)                 │
│   Contenedor selkies-0 (Ubuntu 24.04)  │
│   ├─ Escritorio KDE + Selkies          │
│   ├─ Gazebo, renderizado en la GPU     │
│   ├─ ros_gz_bridge (Gazebo - ROS 2)    │
│   └─ Router Zenoh                      │
└────────────────────────────────────────┘
```

### Por qué Zenoh y no el DDS por defecto

ROS 2 usa DDS por defecto, que descubre los nodos por **multicast**. Las WiFi de universidades y las VPN (Tailscale incluida) suelen bloquearlo o no reenviarlo. Con **Zenoh** (`rmw_zenoh_cpp`, un RMW oficial de ROS 2) basta **una conexión TCP a un puerto**. Además, cada contenedor tiene su propio router, así que cada usuario solo ve sus topics, sin repartir `ROS_DOMAIN_ID`.

### Mundos incluidos

| Mundo | Topics ROS 2 |
|---|---|
| `diff_drive` | `/cmd_vel` (entrada, mueve el coche azul), `/odom`, `/clock` |
| `sensors_demo` | `/camera`, `/scan`, `/clock` |
| `shapes` | `/clock` |

Para añadir un mundo: crear `worlds/<nombre>/world.sdf` y `bridge.yaml` (tabla de tipos en el README de `ros_gz_bridge`) y reconstruir la imagen.

## 3. Requisitos del PC servidor

- Ubuntu con GPU NVIDIA y driver propietario (probado con el driver 580).
- **Docker** y **NVIDIA Container Toolkit** (`docker info` debe listar el runtime `nvidia`).
- Unos **16 GB de disco** para la imagen (descarga de unos 4 GB).
- Nada más: ni ROS, ni Python, ni paquetes en el host. Todo vive en el contenedor.

Construir la imagen (una vez):

```bash
cd 99-CODE-DEMO     # dentro del repositorio clonado
docker build -t selkies-ros .
```

## 4. Una persona

```bash
./run.sh 0
```

Salida:

```
Sesión 0 lanzada (contenedor selkies-0)
  Escritorio:  https://192.168.10.202:8080
  Usuario:     ubuntu
  Contraseña:  sjk005-seminar-user-0
  ROS 2/Zenoh: tcp/192.168.10.202:7447
```

Qué hace `run.sh` por debajo:

```bash
docker run -d --rm --name selkies-0 \
  --gpus 1 --shm-size=2g --memory 8g --cpus 4 \
  -e PASSWD=sjk005-seminar-user-0 -e SELKIES_ENABLE_HTTPS=true \
  -e SELKIES_TURN_HOST=<ip-servidor> \
  -e TURN_EXTERNAL_IP=<ip-servidor> \
  -e SELKIES_TURN_PORT=3478 -e SELKIES_TURN_PROTOCOL=tcp \
  -e TURN_MIN_PORT=65000 -e TURN_MAX_PORT=65019 \
  -p 8080:8080 -p 7447:7447 -p 3478:3478/tcp -p 3478:3478/udp \
  -p 65000-65019:65000-65019/udp \
  selkies-ros
```

Detalles importantes:

- **`SELKIES_TURN_HOST` / `TURN_EXTERNAL_IP`**: la dirección del repetidor de vídeo (TURN, ver [[#Cómo llega el vídeo: WebRTC y TURN]]). Por defecto Selkies pone la **IP pública** del servidor, que en una red universitaria es la del NAT del campus y el navegador no puede alcanzar. `run.sh` la fija a la IP local del servidor.
- **`SELKIES_ENABLE_HTTPS=true`**: así la contraseña no viaja en claro. El certificado es autofirmado y el navegador avisa la primera vez.
- **`--memory` y `--cpus`** limitan RAM y CPU. La **VRAM no se puede limitar**: todas las sesiones comparten los 12 GB.

Parar la sesión: `./run.sh stop 0`.

## 5. Más de una persona

Selkies no tiene portal ni login multiusuario: **una sesión es un contenedor**. Para varias personas, se lanza un contenedor por persona con puertos distintos:

```bash
./run.sh 0      # contraseña sjk005-seminar-user-0
./run.sh 1      # contraseña sjk005-seminar-user-1
./run.sh 2      # ...
```

| Puerto | Sesión `n` | Sesión 0 | Sesión 1 | Protocolo |
|---|---|---|---|---|
| Web (escritorio) | 8080 + n | 8080 | 8081 | TCP |
| Zenoh (ROS 2) | 7447 + n | 7447 | 7448 | TCP |
| TURN (vídeo) | 3478 + n | 3478 | 3479 | TCP y UDP |
| Relay TURN | 65000 + 20n … +19 | 65000–65019 | 65020–65039 | UDP |

Cada contenedor tiene **su escritorio, su Gazebo y su router Zenoh**, así que los usuarios no se ven entre sí. Comprobado: con `diff_drive` abierto en la sesión 0, `ros2 topic list` en la sesión 1 no muestra `/odom` ni `/cmd_vel`.

Uso medido de GPU con 2 sesiones y un Gazebo abierto: **~620 MiB de 12 GB** (Gazebo GUI ~290 MiB). Con mundos sencillos caben varias sesiones; con cámaras y LiDAR, menos. Conviene vigilarlo con `watch -n1 nvidia-smi`.

> **Lo que falta frente a una plataforma completa:** no hay portal para que cada usuario lance su sesión, ni login centralizado, ni caducidad automática. Lo hace el administrador a mano con `run.sh`. Para eso existen plataformas como [[02-Kasm-Workspaces|Kasm Workspaces]].

## 6. Puertos y red

### Cómo llega el vídeo: WebRTC y TURN

Selkies envía el escritorio como **vídeo WebRTC**, la misma tecnología que Google Meet o Discord. WebRTC intenta primero mandar el vídeo **directo** del emisor al receptor: cada lado le dice al otro "estoy en esta dirección, mándamelo aquí".

Aquí eso no funciona: el emisor está **dentro de un contenedor Docker**, con una dirección interna (`172.17.0.x`) que solo existe dentro del PC servidor. El portátil no puede llegar a ella.

La solución estándar es **TURN**, un **repetidor de vídeo**. Es un pequeño servidor (coturn, ya incluido en la imagen de Selkies) al que los dos lados sí llegan: el contenedor le manda el vídeo y el navegador lo recoge de ahí.

```
Sin TURN:
  contenedor (172.17.0.x) ──X──> navegador
  (dirección interna: el portátil no llega)

Con TURN:
  contenedor ──> TURN 192.168.10.202:3478 ──> navegador
```

| Pieza | Qué es | Puerto en la sesión 0 |
|---|---|---|
| Dirección del repetidor (`SELKIES_TURN_HOST`) | La IP que se le da al navegador para encontrar el TURN | `192.168.10.202` |
| Puerto TURN | La "puerta de entrada" al repetidor | 3478 (TCP y UDP) |
| Puertos de relay | Los "canales" que el repetidor abre para cada conexión de vídeo | 65000–65019 (UDP) |

Por culpa de Docker, **el vídeo pasa siempre por TURN**, también en la red local. Cada conexión de vídeo gasta 2 canales y las que fallan tardan unos minutos en liberarlos, así que hay que dejar margen: por eso `run.sh` reserva **20 canales por sesión**.

### Desde la misma red

Basta con que el portátil llegue a la IP del servidor. Comprobación rápida desde el portátil:

```bash
nc -vz 192.168.10.202 8080    # web
nc -vz 192.168.10.202 7447    # Zenoh
nc -vz 192.168.10.202 3478    # TURN
```

### Desde fuera, con Tailscale

Probado desde otra red, con el portátil en Tailscale y un nodo que hace de **subnet router** hacia `192.168.10.0/24`. Las URL y los endpoints son los mismos (`192.168.10.202`).

No hace falta nada especial: el repetidor TURN está en `192.168.10.202`, que es alcanzable por Tailscale igual que la web y Zenoh.

**Problema que encontramos aquí:** al principio `run.sh` reservaba solo 2 canales de relay por sesión. En la red local bastaron, porque la primera conexión los encontró libres. Por Tailscale hubo reconexiones, los canales se agotaron y el log de TURN mostraba `ALLOCATE ... error 508: Cannot create socket`: la web se reconectaba cada pocos segundos sin mostrar el escritorio. Se solucionó ampliando a 20 canales por sesión.

## 7. Conectar los nodos ROS 2 del usuario por Zenoh

Requisito en el portátil: ROS 2 **Jazzy** y Zenoh.

```bash
sudo apt install ros-jazzy-rmw-zenoh-cpp
```

**Terminal 1**: router Zenoh local conectado al router de su sesión (puerto 7447 + n):

```bash
source /opt/ros/jazzy/setup.bash
export ZENOH_CONFIG_OVERRIDE='connect/endpoints=["tcp/192.168.10.202:7447"]'
ros2 run rmw_zenoh_cpp rmw_zenohd
```

**Terminal 2 y siguientes**: los nodos de siempre, cambiando solo el RMW:

```bash
source /opt/ros/jazzy/setup.bash
export RMW_IMPLEMENTATION=rmw_zenoh_cpp      # mejor en el ~/.bashrc

ros2 topic pub -r 10 /cmd_vel geometry_msgs/msg/Twist "{linear: {x: 0.5}, angular: {z: 0.3}}" # ejemplo para hacer girar al robot
```



¿Por qué un router local? Con `rmw_zenoh`, cada nodo busca un router en `localhost:7447`. Si ese router está conectado al del servidor, **todas** las herramientas (`ros2 topic`, `ros2 launch`, `rviz2`, nodos propios…) funcionan sin configurar nada más. Si los nodos usan el tiempo de simulación, arrancarlos con `use_sim_time:=true`, porque `/clock` llega desde Gazebo.

## 8. Comandos para probar

### En el navegador

1. Abrir `https://192.168.10.202:8080`, aceptar el aviso del certificado y entrar con `ubuntu` / `sjk005-seminar-user-0`.
2. Doble clic en **Gazebo: diff_drive** (o abrir una terminal en el escritorio y escribir `sim diff_drive`).

### En el portátil (con el router de la terminal 1 en marcha)

```bash
# Topics de la sesión: /clock /cmd_vel /odom ...
ros2 topic list

# Odometría del coche
ros2 topic echo /odom --once

# Moverlo (Ctrl+C para cortar el envío)
ros2 topic pub -r 10 /cmd_vel geometry_msgs/msg/Twist \
  "{linear: {x: 0.5}, angular: {z: 0.3}}"

# Pararlo (mantiene la última velocidad recibida)
ros2 topic pub --once /cmd_vel geometry_msgs/msg/Twist "{}"

# Manejarlo con el teclado
ros2 run teleop_twist_keyboard teleop_twist_keyboard
```

El coche azul se mueve en la pestaña del navegador.

### Aislamiento entre usuarios (en el portátil)

Con Gazebo abierto solo en la sesión 0, parar el router de la terminal 1 y conectarlo a la **sesión 1** (puerto 7448):

```bash
export ZENOH_CONFIG_OVERRIDE='connect/endpoints=["tcp/192.168.10.202:7448"]'
ros2 run rmw_zenoh_cpp rmw_zenohd
```

En la terminal 2, `ros2 topic list` ya no muestra `/odom` ni `/cmd_vel`: cada usuario solo ve los topics de su propia sesión.

### Comprobaciones del administrador (opcional, en el PC servidor)

**No hacen falta para usar la demo.** Sirven para demostrar que la GPU que trabaja es la del servidor y para diagnosticar problemas. Se escriben en una terminal del PC servidor. Los que empiezan por `docker exec selkies-0` ejecutan la orden *dentro* del contenedor de la sesión 0.

```bash
# Qué sesiones hay en marcha
docker ps --filter name=selkies

# Uso de la GPU: con Gazebo abierto aparece "gz sim gui"
watch -n1 nvidia-smi

# Qué GPU renderiza: debe decir NVIDIA GeForce RTX 3060
docker exec selkies-0 vglrun -d egl glxinfo -B | grep renderer

# Servicios del contenedor (zenohd incluido)
docker exec selkies-0 supervisorctl status

# Log del vídeo (WebRTC y TURN)
docker exec selkies-0 tail -f /tmp/selkies-gstreamer-entrypoint.log

# Log del router Zenoh
docker exec selkies-0 tail -f /tmp/zenohd.log
```

## 9. Limitaciones

- **Un usuario por contenedor**: el multiusuario se hace a mano. Sin portal, sin cuentas, sin caducidad automática.
- **La VRAM no se aísla**: un usuario con un mundo pesado puede dejar sin memoria a los demás.
- Seguridad de demo: contraseñas predecibles (`sjk005-seminar-user-n`) y certificado autofirmado. Válido en una red de confianza, **no para exponer a Internet**.
- Los usuarios tienen un terminal con `sudo` (falso) dentro del contenedor y salida a Internet: dar acceso solo a gente de confianza.
- Ambos lados deben usar la misma distribución de ROS 2.
- La imagen 24.04 es la generación anterior de Selkies: funciona, pero ya no recibe las novedades.

## Fuentes

- [selkies-project/docker-nvidia-egl-desktop](https://github.com/selkies-project/docker-nvidia-egl-desktop)
- [Selkies (organización en GitHub)](https://github.com/selkies-project)
- [rmw_zenoh](https://github.com/ros2/rmw_zenoh)
- [ros_gz_bridge](https://github.com/gazebosim/ros_gz/tree/jazzy/ros_gz_bridge)
- [National Research Platform: GUI desktop (Selkies en un clúster académico)](https://docs.nationalresearchplatform.org/userdocs/running/gui-desktop)
