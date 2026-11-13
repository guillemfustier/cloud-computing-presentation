# 02 Kasm Workspaces

**Categoría:** plataforma autoalojada de escritorios y aplicaciones en contenedores, servidos al navegador, con portal multiusuario. **Relevancia:** alta como solución "completa" para ofrecer tu GPU a varias personas; **descartada para nuestra demo** por lo que exige instalar en el servidor.

Relacionado: [[01-Selkies]] (la opción que usamos)

---

## Qué es

[Kasm Workspaces](https://kasmweb.com) hace como producto acabado lo que con Selkies hacemos a mano: cada usuario inicia sesión en un portal web, elige un "workspace" de un catálogo (un escritorio Ubuntu, Firefox, Blender o una imagen propia) y Kasm le lanza **un contenedor Docker solo para él**, que ve en el navegador. Al cerrar la sesión, el contenedor se destruye.

```
Navegador ── HTTPS :443 ──> Kasm (en el servidor)
  ├─ Portal web: login, usuarios, catálogo
  ├─ Manager / API: decide qué lanzar y dónde
  └─ Agent: lanza un contenedor por sesión
       └─ Escritorio Linux + KasmVNC
            └─ GPU NVIDIA del servidor
```

Lo que aporta frente a Selkies:

- **Multiusuario de verdad**: cuentas, grupos, permisos y catálogo de imágenes desde una web de administración.
- Sesiones **bajo demanda**: el usuario las lanza y las cierra él; hay caducidad automática.
- Límites de CPU, RAM y GPU **por imagen**, almacenamiento persistente opcional, registros de imágenes.

## Cómo usa la GPU

Según su [documentación de GPU](https://docs.kasm.com/docs/tutorials/install/gpu):

- Requiere GPU NVIDIA con CUDA, driver reciente y NVIDIA Container Toolkit en cada servidor (Agent).
- Cada imagen declara cuántas GPU necesita. Por defecto **1 GPU física = 1 sesión**, pero el administrador puede declarar que el Agent tiene, por ejemplo, 4 GPU "virtuales" para que la compartan 4 sesiones.
- OpenGL acelerado con **VirtualGL (EGL)** o Vulkan con Zink, la misma técnica de fondo que Selkies y que la opción hecha a mano de Jorge.
- La propia Kasm advierte que compartir una GPU entre varios usuarios "no está bien establecido" en cuanto a seguridad; la única forma segura es **MIG**, que no tienen las GPU de consumo como la RTX 3060.

## Licencia

La **Community Edition** es gratuita para pruebas, uso no comercial y organizaciones sin ánimo de lucro, con un **límite de 5 sesiones simultáneas** ([licencia](https://docs.kasm.com/docs/license/index.html)). Las ediciones de pago se licencian por usuario o por sesión concurrente.

## ROS 2 y Gazebo en Kasm

No hay imagen oficial con ROS 2. Habría que construir una propia partiendo de la imagen base de Kasm con CUDA, añadir ROS 2 Jazzy y Gazebo (como hicimos con Selkies) y registrarla en el panel. Además, Kasm solo expone el escritorio web: para conectar nodos ROS 2 desde fuera por Zenoh habría que abrir un puerto extra con su configuración avanzada de Docker, o ejecutar los nodos dentro del escritorio.

## Por qué no la usamos

| Requisito de Kasm                                                      | Situación en el PC servidor                                                                                                      |
| ---------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| 50–75 GB de disco libres (según versión)                               | 37 GB libres                                                                                                            |
| Instalador con **sudo** que trae **su propio Docker y Docker Compose** | La máquina ya tiene Docker 29 con otros proyectos en marcha; la documentación avisa de incompatibilidades con Docker 29 |
| Configura **swap** en el sistema                                       | Cambio en el host que no queríamos hacer                                                                                |
| Puerto 443                                                             | Libre, pero es un cambio más                                                                                            |

Queríamos que **todo quedara en contenedores, sin tocar el sistema** de una máquina compartida. Kasm es una plataforma que se instala en el host; Selkies es un contenedor que se lanza y se borra. Para una demo con 1–2 usuarios, Selkies cubre lo necesario con mucho menos coste.

**Cuándo sí elegir Kasm**: un servidor dedicado, con varios usuarios habituales que deben lanzar sus sesiones sin depender de un administrador.

## Fuentes

- [Kasm: aceleración por GPU](https://docs.kasm.com/docs/tutorials/install/gpu)
- [Kasm: licencia y Community Edition](https://docs.kasm.com/docs/license/index.html)
- [Kasm: comparativa de ediciones](https://trust.kasmweb.com/community-edition)
- [Kasm: requisitos del sistema](https://docs.kasm.com/docs/install/system_requirements/index.html)
- [Kasm: instalación en un solo servidor](https://docs.kasm.com/docs/tutorials/install/single-server-install/index.html)
- [Kasm: construir imágenes propias](https://docs.kasm.com/docs/how-to/workspaces-sessions/container-workspace/customization/building-images/index.html)
