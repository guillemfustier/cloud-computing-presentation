---
title: Index
type: moc
tags: [seminar, cloud, robotics, simulation, index]
---

# 00 Index: cloud services for robot simulators

Entry point to the seminar documentation. It walks through the options for simulating robots without having (or without having to use) the hardware on your own laptop: from ready-made cloud services to setting up your own GPU server.

---

## 00 Online workspaces (no NVIDIA)

Managed services accessed from the browser.

- [[01-The-Construct|The Construct]]: online development environment and ROS / ROS 2 labs with Gazebo.
- [[02-Webots-cloud|Webots cloud]]: publishing interactive Webots simulations and reproducible demos on the web.

## 01 Self-deployed cloud (no NVIDIA)

Simulation and learning software that you deploy yourself on cloud machines.

- [[01-Unity-Simulation-Pro-and-ML-Agents|Unity Simulation Pro and ML-Agents]]: robot simulation in Unity and agent training.
- [[02-MuJoCo-Playground|MuJoCo Playground]]: the MuJoCo physics engine and its robot learning ecosystem.
- [[03-Genesis-World|Genesis World]]: simulation framework for *physical AI*, configurable for cloud accelerators.

## 02 NVIDIA cloud infrastructure

NVIDIA tools for each step: getting a GPU, simulating and scaling.

- [[NVIDIA Cloud & 3D Infrastructure]]: overall map of the infrastructure and how its pieces fit together.
  - [[NVIDIA Brev]]: on-demand GPU instances and *Launchables*.
  - [[NVIDIA Omniverse Cloud]]: hosted 3D and simulation applications, OpenUSD and streaming.
  - [[NVIDIA OSMO]]: orchestration of *physical AI* pipelines at scale.

## 03 Demo: your own simulation cloud

Offering the GPU of your own PC so other people can simulate from their browser.

- [[01-Selkies|Selkies]]: the option we use in the demo. GPU desktop in the browser, Gazebo and ROS 2 over Zenoh.
- [[02-Kasm-Workspaces|Kasm Workspaces]]: the full multi-user alternative, and why we did not use it.

The code to reproduce the demo lives outside this vault, in the repository's `99-CODE-DEMO/` folder. Its `README.md` has the steps.
