---
title: NVIDIA Omniverse Cloud
type: note
tags: [omniverse, openusd, streaming, webrtc, cloudxr, cloud-robotics]
created: 2026-11-13
parent: "[[NVIDIA Cloud & 3D Infrastructure]]"
---

# NVIDIA Omniverse Cloud

Part of [[NVIDIA Cloud & 3D Infrastructure]]. In the overall workflow it sits after prototyping (Brev) and alongside large-scale runs (OSMO).

## Naming and status

Omniverse Cloud began as a set of Omniverse services hosted on Microsoft Azure. NVIDIA's blog was later edited to say that, from July 2025, Omniverse in the cloud is offered as part of DGX Cloud. The current product page calls it Omniverse on DGX Cloud: a managed platform for streamed applications on L40 GPU infrastructure, sold through Azure Marketplace. I use "Omniverse Cloud" here as shorthand for this family. The docs also note that the desktop Omniverse Launcher was deprecated on 1 October 2025, so older tutorials that start from it may be out of date.

## PaaS and SaaS sides

- **Platform side.** Developers build applications with the Kit SDK, containerize them and deploy them through Kit App Streaming. Scaling is handled by NVIDIA Cloud Functions. Cloud APIs expose USD ingest, RTX rendering output and sensor simulation.
- **Software side.** For the end user it behaves like SaaS: open a URL, and the application runs somewhere else.

The Kit App Streaming documentation shows what sits behind that URL: core services, network load balancers, an API gateway and a shader cache. Applications and their profiles are registered with an application and profile service, and a web client then asks the API for a stream, connects over WebRTC, and later disconnects and terminates the session. Part of the streaming stack is published as Helm charts and containers on NGC, and some components are gated behind an NVIDIA account contact.

## OpenUSD and collaboration

OpenUSD (Universal Scene Description) started at Pixar and is now developed with the Alliance for OpenUSD. A scene is a set of layers composed into one stage. References, payloads and variants allow reuse, and a stronger layer can override a weaker one without editing it. That is why several people can work on one scene: each writes to their own layer and composition resolves the result.

USD alone does not give live editing. Omniverse adds live sessions on top, and enterprise setups can connect a Nucleus server to the cloud deployment. For robotics, the useful part is that robot, environment, sensors and physics properties can share one format across Isaac Sim and other tools. A change to a warehouse layout, for instance, can be made once and picked up by every tool that opens the stage.

## Streaming

The Kit application runs on a cloud GPU. Livestream extensions encode the rendered frames and expose them as WebRTC streams (primary, spectator and AOV streams are supported), and a browser client built on the Omniverse Web Streaming Library displays them. User input travels back on the same connection. In the sample configuration, the primary stream has its own signaling port, and a small web server lists the detected streams through a REST endpoint, so the client can discover them automatically.

In the NVCF-based Low Latency Streaming service, media uses a single UDP port, and an optional TURN server gives a TCP or TLS fallback for networks that block UDP. This matters in practice, because university and corporate networks often do block UDP.

**CloudXR** is the XR counterpart. The 6.0 runtime streams OpenXR applications from a GPU server, with client SDKs for Apple platforms and CloudXR.js (early access) for browsers. NVIDIA's samples include teleoperation in Isaac Lab and Omniverse spatial streaming.

## Relevance for cloud robotics

- The simulation stays next to the GPUs, and a reviewer needs only a browser.
- Teleoperation for collecting demonstrations is the most latency-sensitive use. No latency figures are given here; they depend on the network and should be measured.
- Streaming is for humans in the loop. Headless batch runs do not need it and belong to the orchestration layer (OSMO).

## Limits

- Latency is bounded by the network path, not only by the GPU.
- Some streaming components are gated, so a lab without an NVIDIA contact may not get everything.
- The platform targets managed L40 infrastructure, which suits RTX rendering but ties you to what NVIDIA and Azure offer.

## Sources

- [Omniverse on DGX Cloud (product page)](https://www.nvidia.com/en-eu/data-center/omniverse-dgx-cloud/)
- [Omniverse on DGX Cloud documentation](https://docs.omniverse.nvidia.com/omniverse-dgxc/latest/overview/technical_summary.html)
- [NVIDIA blog: Omniverse APIs (with the DGX Cloud editor's note)](https://blogs.nvidia.com/blog/omniverse-cloud-apis)
- [Kit App Streaming: applications API](https://docs.omniverse.nvidia.com/ovas/latest/api-docs/applications-api.html)
- [Kit App Streaming: WebRTC livestream extension](https://docs.omniverse.nvidia.com/extensions/latest/ext_livestream/webrtc.html)
- [Low Latency Streaming overview](https://docs.omniverse.nvidia.com/ov/ovs/latest/low-latency-streaming/lls-overview.html)
- [NVIDIA CloudXR SDK](https://developer.nvidia.com/nvidia-cloudxr-sdk)
- [CloudXR.js documentation](https://docs.nvidia.com/cloudxr-sdk/latest/usr_guide/cloudxr_js/index.html)
- [OpenUSD](https://openusd.org)
- [Alliance for OpenUSD](https://aousd.org)