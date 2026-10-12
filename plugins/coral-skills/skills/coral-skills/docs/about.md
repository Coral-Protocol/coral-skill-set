# About

Kubernetes for AI agents: CoralOS is a platform for everything between your agents and production: registry, runtimes, security, and orchestration.

Source: https://docs.coralos.ai/about

[Video](https://www.youtube.com/embed/YHd5cZJsUjA)

### Value for Developers

CoralOS allows agents to be reused across the internet, It allows agent developers to publish agents to the global marketplace where they can be used on demand by anyone.

- [**Agent developers**](guides/writing-agents.md) earn incentives when their agents are used.
- [**Application developers**](guides/integrating-with-your-app.md) can mix and match from Coral's growing [library](https://github.com/Coral-Protocol/awesome-composable-agents) of agents to assemble advanced systems faster and without vendor lock-in.

### Key Components

- **[Coralized Agents](guides/writing-agents.md)**

  Add any agent from any framework to our marketplace in minutes.

- **[Coral Marketplace](concepts/marketplace.md)**

  Discover, publish, monetize & verify agents with built-in attestation.

- **[Coral Server](https://github.com/Coral-Protocol/coral-server)**

  Orchestrate many agents together easily.

- **[Coral Console](concepts/coral-console.md)**

  Monitor, test & debug agents during development.

- **[Coralizer](https://github.com/Coral-Protocol/coralizer)**

  Turn any MCP server into a coralized agent.

### Key Benefits

#### Built-in privacy

Agent communication is scoped to sessions. Applications remain responsible for authenticating users, controlling access to the server API, and mapping callbacks and stored results to the correct tenant.

#### Build faster with reusable agents

Leverage agents from any framework and integrate pre-built, specialized agents developed by others. Instead of reinventing the wheel, plug them directly into your system for faster deployment.

#### Scalable graph-based architecture

Most multi-agent systems are built hierarchically, where a central “planner” delegates tasks to worker agents or runs workflows sequentially. This structure quickly becomes a bottleneck, where one agent has too much responsibility.

 Coral’s architecture introduces a **graph-based design** that enables **direct agent-to-agent communication**, unlocking significant improvements in performance, scalability, and cost-efficiency. Instead of funneling decisions through a single controller, agents can coordinate dynamically and share progress in real time.

As shown in[_Anemoi: A Semi-Centralized Multi-Agent System Based on Agent-to-Agent Communication_](https://arxiv.org/abs/2508.17068)  (Ren et al., 2025), this approach:

> “Enables structured and direct inter-agent collaboration, allowing all agents to monitor progress, assess results, identify bottlenecks, and propose refinements in real time.”
>
> “Reduces reliance on a single planner, supports adaptive plan updates, and minimizes redundant context passing, resulting in more scalable and cost-efficient execution.”

This architecture has also demonstrated measurable performance gains on benchmarks:

> “On the GAIA benchmark, Anemoi achieved 52.73 % accuracy with a small LLM (GPT-4.1-mini) as the planner, surpassing the strongest open-source baseline OWL (43.63 %) by \+9.09 % under identical LLM settings.”

Because each agent in Coral’s architecture handles smaller, well-defined responsibilities and communicates via a scalable graph, you gain:

- **Higher throughput** — Multiple agents run concurrently without blocking, using the server’s coroutine-based connection handling. Actual throughput also depends on agent implementations and provider limits.
- **Improved reasoning quality** — Specialized agents continuously refine each other’s outputs in real time.
- **Safer and more predictable AI systems** — Instead of scaling performance by making models larger, Coral lets you scale by adding more intelligent agents.

  See more results on the **GAIA benchmark:** [https://gaia.coralos.ai/](https://gaia.coralos.ai/)

### Ready to Start Building?

- **[Check out our GitHub](https://github.com/Coral-Protocol/coral-server)**

- **[Get started with Coralizer](https://github.com/Coral-Protocol/coralizer)**

- **[Join the Community](https://discord.gg/xRFpVS5N)**

- **[Video workshop ](https://youtu.be/H5n0N8xYKHo)**
