---
title: NVIDIA Brev
type: note
tags: [brev, gpu-cloud, launchables, cuda, containers, prototyping]
created: 2026-11-13
parent: "[[NVIDIA Cloud & 3D Infrastructure]]"
---

# NVIDIA Brev

Part of [[NVIDIA Cloud & 3D Infrastructure]]. In the overall workflow it is the entry point: the place where a project gets its first GPU environment.

## What it is

A console and CLI that lists GPU instances from several cloud providers behind one interface. The docs mention AWS, Google Cloud, Crusoe, Lambda, Nebius, Hyperstack and Oracle, among others. Every instance comes with NVIDIA drivers, CUDA, Python and Docker. Brev started as an independent startup before NVIDIA took it over.

The console is organized into GPUs (create and manage instances), Deployments (serverless NIM endpoints), Blueprints and Launchables (ready-made environments), plus Team and Billing sections for organizations.

## The problem it removes

The usual first-day failures are a driver and CUDA version mismatch, a container runtime without GPU access, and a different console for every provider. The docs organize Brev around three concepts: Instances (the compute), Environments (the preconfigured software) and Launchables (both bundled into a shareable deployment). In the docs' own words, deploying a Launchable means no manual installation and no cloud console navigation.

## Launchables

A Launchable captures four things:

- hardware: GPU type, memory, disk
- software: base image, dependencies, setup scripts
- code: a Git repository, notebooks or embedded files
- networking: exposed ports and Jupyter settings

It runs in one of two modes. VM mode uses Ubuntu 22.04 with Docker, Python and CUDA preinstalled. Container mode runs a Docker image or a Docker Compose stack. A Launchable is shared as a link with an access level, and the docs list reproducing research and team onboarding among the intended uses.

Shared Launchables can be browsed and filtered by GPU type, VRAM, cloud provider or price. Filtered views can be deep-linked with query parameters such as `?gpuType=A100`, which is handy for a README. NVIDIA's own blueprints use the same mechanism. One video-analytics blueprint ships a notebook meant for two RTX PRO 6000 GPUs on AWS, and another version is written for eight L40S GPUs on Crusoe. So a Launchable often pins the hardware as well as the software.

## Access

VS Code Remote SSH, JupyterLab through port forwarding, or the Brev CLI. The RAPIDS quickstart shows the container route: a Compose file reserves all GPUs for the container and exposes the Jupyter port.

## Use in robotics research

Brev suits the stage before committing to a cluster: start an instance, load an Isaac Sim scene, check that a policy trains at all. A plausible routine is to prototype on one rented GPU, and move to a larger setup only once the pipeline works. Two practical notes from an NVIDIA Launchable guide for an Isaac Sim-based workload:

- Compute-only accelerators cannot render the Isaac Sim scene. The guide recommends GPUs with RT cores, such as the L40S, RTX A6000 or RTX 6000 Ada.
- Some cloud regions are refused by NGC with an HTTP 403 that is not an authentication problem. The fix was to redeploy in a US region.

The same guide reports that a first run takes about 30 to 45 minutes on a two-GPU RTX 6000 Ada instance, so "one click" does not mean "ready in seconds".

## Limits

- It provisions machines. Running many coordinated jobs is a different problem, handled by a separate orchestration layer.
- Availability and GPU types vary by provider and region.
- Cost accrues while an instance runs. I have not checked current pricing.

## Sources

- [NVIDIA Brev documentation](https://docs.nvidia.com/brev/latest)
- [Getting started overview](https://docs.nvidia.com/brev/getting-started/overview)
- [Launchables concept page](https://docs.nvidia.com/brev/latest/concepts/launchables)
- [Core concepts](https://docs.nvidia.com/brev/latest/concepts/overview.md)
- [Console reference](https://docs.nvidia.com/brev/latest/guides/console-reference.md)
- [Brev quickstart for RAPIDS](https://docs.nvidia.com/datascience/deployment/latest/cloud/nvidia/brev/)
- [Brev Launchable guide for an Isaac Sim-based workload](https://docs.nvidia.com/halos/outside-in-safety/getting-started/brev-launchable)