---
title: Índice
type: moc
tags: [seminar, cloud, robotics, simulation, index]
---

# 00 Índice: servicios cloud para simuladores robóticos

Punto de entrada de la documentación del seminario. Recorre las opciones para simular robots sin tener (o sin tener que usar) el hardware en tu propio portátil: desde servicios en la nube ya hechos hasta montar tu propio servidor con GPU.

---

## 00 Entornos online (sin NVIDIA)

Servicios gestionados a los que se accede desde el navegador.

- [[01-The-Construct|The Construct]]: entorno online de desarrollo y laboratorios ROS / ROS 2 con Gazebo.
- [[02-Webots-cloud|Webots cloud]]: publicación de simulaciones Webots interactivas y demos reproducibles en la web.

## 01 Cloud autodesplegado (sin NVIDIA)

Software de simulación y aprendizaje que se despliega uno mismo en máquinas cloud.

- [[01-Unity-Simulation-Pro-and-ML-Agents|Unity Simulation Pro y ML-Agents]]: simulación robótica en Unity y entrenamiento de agentes.
- [[02-MuJoCo-Playground|MuJoCo Playground]]: motor de física MuJoCo y su ecosistema de aprendizaje de robots.
- [[03-Genesis-World|Genesis World]]: framework de simulación para *physical AI*, configurable para aceleradores cloud.

## 02 Infraestructura cloud de NVIDIA

Herramientas de NVIDIA para cada paso: conseguir GPU, simular y escalar.

- [[NVIDIA Cloud & 3D Infrastructure]]: mapa general de la infraestructura y cómo encajan sus piezas.
  - [[NVIDIA Brev]]: instancias GPU bajo demanda y *Launchables*.
  - [[NVIDIA Omniverse Cloud]]: aplicaciones 3D y de simulación alojadas, OpenUSD y streaming.
  - [[NVIDIA OSMO]]: orquestación de pipelines de *physical AI* a escala.

## 03 Demo: tu propia nube de simulación

Ofrecer la GPU de un PC propio para que otras personas simulen desde su navegador.

- [[01-Selkies|Selkies]]: la opción que usamos en la demo. Escritorio con GPU en el navegador, Gazebo y ROS 2 por Zenoh.
- [[02-Kasm-Workspaces|Kasm Workspaces]]: la alternativa multiusuario completa, y por qué no la usamos.

El código para reproducir la demo está fuera de esta vault, en la carpeta `99-CODE-DEMO/` del repositorio. Su `README.md` tiene los pasos.
