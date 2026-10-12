# Vibecoding

Guidelines and warnings on LLM-assisted coding with CoralOS

Source: https://docs.coralos.ai/help/vibecoding

Making agents or adding existing agents to Coral is easy, but there are some important considerations when using LLMs for coding tasks.

## Tl;dr
Use [DeepWiki](https://deepwiki.com/Coral-Protocol/coral-server) and, when possible, models with native MCP awareness (e.g., recent Anthropic models).

## MCP is new

Coral agents connect to their Coral Servers via MCP (Model Context Protocol). MCP is a protocol for exposing tools and other context-related primitives to LLMs via transports like HTTP (SSE).

Because MCP is relatively new, many LLMs may not have strong built‑in knowledge of it. Simply stating “this server exposes MCP tools” often means more to a human than to an LLM unless the model natively understands MCP.

Coral is also relatively new, so terms like “Coralized” may not be recognized by many models without additional context.

In practice, some models may hallucinate understanding of MCP/Coral and produce code that is syntactically correct but semantically incorrect. Prefer models with demonstrated MCP awareness.

You can always provide a brief primer about MCP and Coral in‑prompt, but native MCP awareness generally yields better results. Even MCP‑aware models may lag on the newest features, so keep examples and instructions current.

## DeepWiki
[DeepWiki](https://deepwiki.com/Coral-Protocol/coral-server) provides an LLM-generated documentation of the coral server's code.

It is generally pretty accurate. It can be asked questions directly, or be used as a source of truth for other agents.

## Prompt engineering

When using LLMs for coding tasks, prompt engineering is crucial. Here are some tips:
* Encourage the model to ask questions to you about Coral and MCP if it is unsure.
* Work from high quality up to date examples.
* For agentic coding tools without access to DeepWiki, consider giving them access to the coral server source

## Warnings
Vibe coding can engage less familiar developers and allow people to get started faster, but it is not a substitute for understanding the underlying technology and your solution.

Typing is rarely the bottleneck in software development. Agentic coding tool usage is inherently tech debt producing. It is easy to fall into a trap where you have a solution that seems to work, but you don't understand how it works or how to fix it when it breaks.

Consider using a tool like Copilot or Windsurf to assist with typing and help to explore unfamiliar APIs and languages without delegating thinking itself to something that cannot learn.
