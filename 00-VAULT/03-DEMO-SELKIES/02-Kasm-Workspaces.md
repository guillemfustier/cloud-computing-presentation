# 02 Kasm Workspaces

**Category:** self-hosted platform for containerised desktops and applications, served to the browser, with a multi-user portal. **Relevance:** high as a "complete" solution for offering your GPU to several people; **ruled out for our demo** because of what it requires installing on the server.

Related: [[01-Selkies]] (the option we use)

---

## What it is

[Kasm Workspaces](https://kasmweb.com) does as a finished product what we do by hand with Selkies: each user logs in to a web portal, picks a "workspace" from a catalogue (an Ubuntu desktop, Firefox, Blender or a custom image) and Kasm launches **a Docker container just for them**, which they see in the browser. When the session is closed, the container is destroyed.

```
Browser ── HTTPS :443 ──> Kasm (on the server)
  ├─ Web portal: login, users, catalogue
  ├─ Manager / API: decides what to launch and where
  └─ Agent: launches one container per session
       └─ Linux desktop + KasmVNC
            └─ Server's NVIDIA GPU
```

What it adds compared to Selkies:

- **Real multi-user support**: accounts, groups, permissions and an image catalogue from an admin web UI.
- **On-demand** sessions: users launch and close them themselves; sessions expire automatically.
- CPU, RAM and GPU limits **per image**, optional persistent storage, image registries.

## How it uses the GPU

According to its [GPU documentation](https://docs.kasm.com/docs/tutorials/install/gpu):

- It requires an NVIDIA GPU with CUDA, a recent driver and the NVIDIA Container Toolkit on every server (Agent).
- Each image declares how many GPUs it needs. By default **1 physical GPU = 1 session**, but the administrator can declare that the Agent has, for example, 4 "virtual" GPUs so that 4 sessions share it.
- Accelerated OpenGL with **VirtualGL (EGL)** or Vulkan with Zink, the same underlying technique as Selkies and as Jorge's hand-built option.
- Kasm itself warns that sharing a GPU between several users is "not well established" security-wise; the only safe way is **MIG**, which consumer GPUs such as the RTX 3060 do not have.

## License

The **Community Edition** is free for testing, non-commercial use and non-profit organisations, with a **limit of 5 concurrent sessions** ([license](https://docs.kasm.com/docs/license/index.html)). Paid editions are licensed per user or per concurrent session.

## ROS 2 and Gazebo on Kasm

There is no official image with ROS 2. You would have to build your own starting from Kasm's CUDA base image, add ROS 2 Jazzy and Gazebo (as we did with Selkies) and register it in the panel. In addition, Kasm only exposes the web desktop: to connect ROS 2 nodes from outside over Zenoh you would have to open an extra port through its advanced Docker configuration, or run the nodes inside the desktop.

## Why we did not use it

| Kasm requirement                                                       | Situation on the server PC                                                                                              |
| ---------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| 50–75 GB of free disk (depending on version)                           | 37 GB free                                                                                                              |
| Installer with **sudo** that brings **its own Docker and Docker Compose** | The machine already has Docker 29 with other projects running; the documentation warns of incompatibilities with Docker 29 |
| Configures **swap** on the system                                      | A change to the host we did not want to make                                                                            |
| Port 443                                                               | Free, but it is one more change                                                                                         |

We wanted **everything to stay in containers, without touching the system** of a shared machine. Kasm is a platform installed on the host; Selkies is a container you launch and delete. For a demo with 1–2 users, Selkies covers what is needed at a much lower cost.

**When to choose Kasm**: a dedicated server, with several regular users who need to launch their sessions without depending on an administrator.

## Sources

- [Kasm: GPU acceleration](https://docs.kasm.com/docs/tutorials/install/gpu)
- [Kasm: license and Community Edition](https://docs.kasm.com/docs/license/index.html)
- [Kasm: edition comparison](https://trust.kasmweb.com/community-edition)
- [Kasm: system requirements](https://docs.kasm.com/docs/install/system_requirements/index.html)
- [Kasm: single-server installation](https://docs.kasm.com/docs/tutorials/install/single-server-install/index.html)
- [Kasm: building custom images](https://docs.kasm.com/docs/how-to/workspaces-sessions/container-workspace/customization/building-images/index.html)
