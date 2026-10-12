# Vibecoding

Guidelines and warnings on LLM-assisted coding with CoralOS

Source: https://docs.coralos.ai/help/vibecoding

Making agents or adding existing agents to Coral is easy, but there are some important considerations when using LLMs for coding tasks.

## Tl;dr
Recent models work well with Coral and MCP. In Claude Code or Codex, install the Coral skill, which gives the agent these docs and Coral's usage model:

```text Claude Code
/plugin marketplace add Coral-Protocol/coral-skill-set
/plugin install coral-skills@coral-skill-set
```

```bash Codex
codex plugin marketplace add Coral-Protocol/coral-skill-set
codex plugin add coral-skills@coral-skill-set
```

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

Typing is rarely the bottleneck in software development. It is easy to fall into a trap where you have a solution that seems to work, but you don't understand how it works or how to fix it when it breaks.
