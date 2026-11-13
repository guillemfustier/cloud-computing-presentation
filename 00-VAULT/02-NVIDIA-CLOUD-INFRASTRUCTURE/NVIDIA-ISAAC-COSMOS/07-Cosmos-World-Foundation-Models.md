---
tags: [nvidia, cosmos, world-foundation-model, generative-ai, part-2]
aliases: [Cosmos, Cosmos 3, World Foundation Models]
---
# 09 Cosmos – World Foundation Models

## English

**Category:** open-weight generative "world foundation models" (WFMs) for physical AI plus tooling for data curation, post-training and evaluation. **Relevance:** high for **vision-based** robot policies and data augmentation; it *complements* simulation and does not replace it.

### What a world foundation model is

Like a large language model, but trained on huge amounts of **video of the physical world**. It can **understand** scenes (describe, reason about physics, judge plausibility) and **generate** realistic video – e.g. predict what happens next or re-render a scene under different conditions.

### Cosmos 3 (current generation, released May 2026)

Cosmos 3 is **omnimodal** and based on a **Mixture-of-Transformers** architecture with two "towers":

| Tower | Input → Output | Replaces earlier model family |
|---|---|---|
| **Reasoner** | text / vision → text | Cosmos Reason 1/2 |
| **Generator** | text / vision / audio / action → vision / audio / action | Cosmos Predict 1/2.5 (future video), Cosmos Transfer 1/2.5 (controlled re-rendering) |

The Generator can also output **robot actions**, which moves Cosmos from "data generator" towards **policy model**.

**Sizes and target hardware:**

| Variant | Parameters | Target GPUs |
|---|---|---|
| **Super** | 64B | H200, B200, GB200 |
| **Nano** | 16B | RTX PRO 6000, H100, B200 |
| **Edge** | 4B (released July 2026) | Jetson AGX Orin / Thor, RTX PRO 6000 |

FP8 checkpoints exist to reduce memory. Examples of post-trained models: *Nano-Sim-Auto*, *Nano-Transfer-Auto*, *Nano-Sim-Bimanual*, *Nano-Sim-Transfer*, *Super-Text2Image*, *Super-Image2Video* (also 4-step distilled variants), *Nano/Edge-Policy-DROID* (robot policy trained on the DROID dataset).

### Platform around the models

| Component | Purpose |
|---|---|
| **Cosmos Framework** | Post-training: SFT, LoRA, RL, distillation |
| **Cosmos Curator** | Curating and filtering large video datasets |
| **Cosmos Evaluator** | Evaluating generated outputs |
| **Cosmos Data Factory** | Large-scale synthetic data production |
| **Cosmos-RL** | Reinforcement-learning post-training |
| **cosmos-xenna** | Ray-based pipelines for data processing at scale |

Inference backends: Hugging Face **Diffusers** (`Cosmos3OmniPipeline`), **Transformers**, **vLLM**, **vLLM-Omni**, **SGLang**, **TensorRT-LLM**, and **NVIDIA NIM** microservices. Try it in the browser on **build.nvidia.com**.

Licence: **OpenMDW-1.1** (open model licence). **Guardrails** (content safety filters) are enabled by default.

### Simulation vs. Cosmos

| Isaac Sim | Cosmos |
|---|---|
| **Calculates** physics (PhysX / Newton) | **Generates** pixels statistically |
| Contacts, forces, joints are exact and repeatable | Looks realistic, but no guaranteed physical correctness |
| Fast enough for millions of RL steps | Diffusion/large models: far too slow inside an RL loop |
| Labels (depth, segmentation) are exact | Output needs checking (Evaluator, Reasoner) |

**Known limitations** (from NVIDIA's model cards): temporal inconsistency (objects changing between frames) and physically implausible dynamics can occur.

→ Best use: **augment camera data** for imitation learning and perception, generate rare scenarios, evaluate policies – see [[11-Augmented-Imitation-Learning-with-Cosmos]].

### History of model families (for reading older papers/tutorials)

- **Cosmos Predict 1 / 2.5:** generate future video frames from text/image/video.
- **Cosmos Transfer 1 / 2.5:** "sim-to-real style transfer" – re-render a video guided by control maps (depth, segmentation, edges, blur).
- **Cosmos Reason 1 / 2:** vision-language model for physical reasoning.
- The GitHub organisation moved from `nvidia-cosmos` to `NVIDIA/Cosmos`. In October 2026 an *interactive world simulation* cookbook was added.

### Who uses it

NVIDIA lists e.g. 1X, Agility Robotics, Figure, Skild AI, Uber, Toyota Research Institute and General Motors among adopters (vendor statement).

### Best seminar sentence

"Isaac Sim calculates the world, Cosmos imagines how it could look – it makes training data more diverse and realistic, but it is a complement to simulation, not a replacement."

**Primary sources:** [Cosmos GitHub (models, cookbook)](https://github.com/NVIDIA/Cosmos), [Cosmos product page](https://www.nvidia.com/en-us/ai/cosmos/), [Cosmos 3 announcement blog](https://blogs.nvidia.com/blog/cosmos-3-physical-ai-open-world-foundation-model), [Cosmos models on Hugging Face](https://huggingface.co/nvidia), [build.nvidia.com](https://build.nvidia.com/).

---
