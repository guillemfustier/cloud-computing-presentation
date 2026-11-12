# 01 The Construct
**Category:** browser-accessible robotics development and learning environment. **Relevance:** medium to high for cloud **simulation**, lower for managed large-scale RL **training**.

### What it provides

The Construct offers online ROS/ROS 2 development and robot labs without needing a local full robotics installation. Its site describes preconfigured workspaces for **ROS, ROS 2, Gazebo and also Isaac Lab**. Gazebo is a useful simulator for navigation, sensor integration and robot controls. Existing online robot simulations can be adapted, tested or shared as projects.

### Can robots learn in the cloud here?

**In principle yes, with extra engineering:** you can write controllers and run learning experiments in a cloud robotics environment if the workspace permits your required packages and resources. **But** the website does not establish an out-of-the-box managed RL service equivalent to thousands of parallel Isaac Lab environments with job scheduling, metrics and model export. Distinguish “running an online simulator” from “a vendor-operated high-throughput policy trainer.”

### What makes it useful

- Opens in a browser; familiar ROS/Gazebo workflow.
- Suitable for education and illustrating simulated sensors or robot navigation.
- Lower setup hurdle than assembling ROS + Gazebo on a blank virtual machine.
- Has both NVIDIA and non-NVIDIA paths: an **Isaac Lab workspace is NVIDIA-based**, whereas Gazebo-based work is a separate route.

### Limitations and price

Plan features and limits vary. The official pricing page lists basic vs paid access, project storage, private projects and workspace resource ceilings; do not assume unrestricted GPU compute or free parallel training. Different pages show different offers over time: check the live plan at signup.

### Example seminar distinction

A classroom can open a simulated mobile robot in The Construct, change its controller, observe collisions and sensors, and share the ROS project. That is an excellent **cloud robotics development demonstration**, but not proof of automated GPU-scale RL learning.

**Primary sources:** [Homepage](https://www.theconstruct.ai/), [Plans](https://www.theconstruct.ai/pricing/), [How to simulate robots](https://www.theconstruct.ai/the-construct-how-to/).

---
