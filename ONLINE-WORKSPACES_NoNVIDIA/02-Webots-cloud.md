# 02 Webots cloud

**Category:** cloud-hosted interactive robotics simulations and reproducible demos/benchmarks. **Relevance:** medium for cloud simulation and sharing; **not** a documented managed RL training platform.

### What the official guide confirms

Cyberbotics' Webots.cloud is a web service where users can publish 3D scenes, recordings and **fully interactive** Webots simulations. For a cloud simulation, the project files and deployment instructions are held in a GitHub repository, including a `Dockerfile` and `webots.yml`. Its servers can build a container, launch the simulator on a GPU instance and expose the interactive view in a browser.

### What it can and cannot prove

- **Yes:** an authentic physics simulator can run remotely; others can reproduce or explore published robotics experiments.
- **Yes:** authors can publish demos and benchmark-style scenarios.
- **Not established:** a general managed service that trains an RL policy from scratch using many environments, with provider-managed model lifecycle and GPU training quotas.
- **Possible separately:** use Webots as a simulator within a custom RL workflow on other compute, but that is a self-built training system.

### Why it belongs in the vault

It is a good counterexample to the misconception that “in a browser” necessarily means “AI training.” It is also useful for the seminar team members who will share simulations or demonstrate a robotics scenario. For Miquel's comparison, classify it as **interactive cloud simulator**, not **full cloud robot trainer**.

### Access and budget

Webots itself is open source. A deployed webots.cloud example may be publicly accessible, but publishing and service resources are governed by platform policies; do not infer free unlimited execution or GPU training.

**Primary sources:** [Webots.cloud documentation](https://www.cyberbotics.com/doc/guide/webots-cloud?version=released), [Cyberbotics website](https://www.cyberbotics.com/).

---
