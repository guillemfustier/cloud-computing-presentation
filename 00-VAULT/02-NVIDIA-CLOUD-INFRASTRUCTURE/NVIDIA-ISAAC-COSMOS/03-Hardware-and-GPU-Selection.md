---
tags: [nvidia, hardware, gpu, cloud, part-2]
aliases: [Hardware Requirements, GPU Selection]
---
# 03 Hardware and GPU Selection

## English

**Category:** requirements analysis and cloud instance selection. **Relevance:** high – the hardware requirements are the main *reason* to use the cloud, and the wrong GPU type is the most common mistake.

### Official Isaac Sim requirements (docs 6.2.0)

| | Minimum | Good | Ideal |
|---|---|---|---|
| GPU | GeForce RTX 4080 | GeForce RTX 5080 | RTX PRO 6000 Blackwell |
| VRAM | 16 GB | 16 GB | 48 GB |
| RAM | 32 GB | 64 GB | 64 GB |
| Storage | 50 GB SSD | 500 GB SSD | 1 TB NVMe SSD |
| OS | Ubuntu 22.04 / 24.04 (22.04 deprecated), Windows 11 | | |
| Driver | Linux 595.58.03, Windows 595.97 (at research date) | | |

- **Isaac Lab** training needs **more RAM and VRAM** than these numbers, depending on `--num_envs`, sensors and cameras.
- The **container** runs on Linux only.

### The RT-core trap

Isaac Sim's RTX renderer needs GPUs with **RT cores** (ray-tracing hardware). Many classic AI data-center GPUs do not have them:

| GPU | RT cores | Isaac Sim | Typical cloud |
|---|---|---|---|
| **A100** | no | not supported (also no NVENC → no livestream) | AWS p4, GCP A2, Azure ND |
| **H100 / H200** | no | not supported | AWS p5, GCP A3, Azure ND H100 |
| **T4** | yes (Turing) | below the minimum recommendation, older | GCP N1, AWS g4dn |
| **A10 / A10G** | yes | usable for smaller scenes | AWS g5, Azure NVadsA10, Alibaba |
| **L4** | yes | usable, 24 GB | GCP G2, AWS g6 |
| **L40S** | yes | good, 48 GB – used in the Brev docs | AWS g6e, Brev |
| **RTX PRO 6000 Blackwell** | yes | ideal, 96 GB | AWS g7e, GCP G4, Azure NCv6 |

### Best seminar sentence

"In the cloud you can't just take *any* GPU: Isaac Sim needs RT cores, Cosmos needs huge AI GPUs – so the cloud's real value here is choosing the *right* hardware for each step, by the hour."

**Primary sources:** [Isaac Sim requirements](https://docs.isaacsim.omniverse.nvidia.com/6.2.0/installation/requirements.html), [Livestream clients (A100/NVENC note)](https://docs.isaacsim.omniverse.nvidia.com/6.2.0/installation/manual_livestream_clients.html), [AWS deployment (g6e/g7e)](https://docs.isaacsim.omniverse.nvidia.com/6.2.0/installation/install_advanced_cloud_setup_aws.html), [Isaac Automator (GPU options)](https://github.com/isaac-sim/IsaacAutomator), [Cosmos GitHub (model hardware)](https://github.com/NVIDIA/Cosmos), [NVENC support matrix](https://developer.nvidia.com/video-encode-decode-support-matrix).

---
