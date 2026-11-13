---
title: Presentation Script - 3 Min
type: script
tags: [seminar, script, nvidia, cloud-robotics]
created: 2026-11-13
---

# Part 1 script (about 3 min, roughly 440 words)

## 0:00 - 0:30 The problem

[Show the Obsidian map note, summary callout visible]

Simulation is now the main way we train and test robot policies. But it has a hidden cost. Before the first experiment, you need a capable GPU, a working environment on it, and a way to run many jobs in parallel. Most labs do not have that sitting around, so it has to come from the cloud. This is the infrastructure layer of cloud robotics, and it is what I'll cover in Part 1. NVIDIA addresses it with three separate tools: Omniverse Cloud, Brev, and OSMO.

## 0:30 - 1:20 Omniverse Cloud

[Scroll to the Mermaid diagram, point at the Omniverse node and the arrow back to the researcher]

Let's start with Omniverse Cloud, which NVIDIA now offers as Omniverse on DGX Cloud. It is a managed platform for deploying 3D and simulation applications on NVIDIA's GPUs. Scenes are described in OpenUSD, a layered format, so several people can contribute to one scene as separate layers without overwriting each other. The application renders in the cloud and is streamed to a browser over WebRTC. For headset work, such as teleoperating a robot, CloudXR plays the same role for XR devices. The trade-off is latency: every frame crosses the network, so reviewing a scene is easy, but teleoperation is demanding.

## 1:20 - 2:00 Brev

[Point at the Brev node, then open the Launchable section of the Brev note]

Brev solves the first-day problem. Instead of picking a cloud, matching drivers to CUDA and debugging containers, you choose a GPU from a menu that spans several providers, and you get a machine with drivers, CUDA, Python and Docker already installed. The key idea is the Launchable, a shareable link that captures the hardware, the software stack and the code. NVIDIA lists reproducing research and onboarding as intended uses, so a lab can publish one and a new student gets an identical environment from a single link. One caution for robotics: Isaac Sim needs RT cores, so compute-only GPUs will not work.

## 2:00 - 2:40 OSMO

[Open the OSMO note, show the pipeline diagram, trace it left to right]

Once the prototype works, you need scale. OSMO is an open-source orchestrator that runs on Kubernetes. You write the whole pipeline as a YAML file: simulation, synthetic data generation, training and evaluation. Each stage is a task with declared dependencies, so OSMO handles ordering and resource allocation. It schedules those tasks across heterogeneous hardware, from cloud GPUs to simulation clusters to edge devices. In NVIDIA's own examples, it chains Isaac Sim data collection with Cosmos augmentation as one pipeline, and you can open an interactive session to a running Isaac Sim container when you need to record data by hand.

## 2:40 - 3:00 Close

[Back to the map note diagram, trace Brev, then OSMO, then Omniverse]

To sum up: Brev gives you the machine, OSMO runs the pipeline, and Omniverse lets you see and interact with the result. They are separate tools, best seen as a toolbox rather than one platform. In Part 2, we move from this infrastructure to the simulators that run on it.