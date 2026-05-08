# Creating Agents with Koog Template

Koog is JetBrains' agent framework for Kotlin. Coral provides a template to quickly scaffold a Koog-based agent.

## Installation & Scaffolding

### Using npm (recommended)

```bash
npm create koog my-first-agent
```

### Using git + gradle

```bash
git clone https://github.com/Coral-Protocol/coral-koog-agent my-first-agent
cd coral-koog-agent
./gradlew hydrate my-first-agent
```

## Expected Output Structure

```
my-first-agent/
├── src/
│   └── ...              # Kotlin source files
├── build.gradle.kts      # Gradle build configuration
├── coral-agent.toml      # Coral agent manifest
└── ...
```

## Key File: coral-agent.toml

The `coral-agent.toml` is Coral's entrypoint to the agent. It defines metadata, runtime, and configuration options. See `reference-agent-toml.md` for a fully annotated example.

## Linking the Agent to Coral Server

After creating the agent, link it so the server can find it:

```bash
cd my-first-agent
npx @coral-protocol/coralizer@latest link .
```

This creates a symlink: `~/.coral/agents/my-first-agent/{version}` → your agent directory.

To unlink:

```bash
unlink ~/.coral/agents/my-first-agent/{version}
```

## Other Templates & Frameworks

| Language | Framework | Repository |
|----------|-----------|------------|
| Kotlin | Koog | [coral-koog-agent](https://github.com/Coral-Protocol/coral-koog-agent) |
| Rust | coral-rs (Rig) | [Deepwiki Agent](https://github.com/Coral-Protocol/agents/blob/main/rust/agent-deepwiki/src/main.rs) |
| Python | LangChain | [langchain-agent](https://github.com/Coral-Protocol/langchain-agent) |
| TypeScript | Mastra | Use the `coralize-your-agent` skill |

## Koog Framework Docs

For deeper Koog framework documentation: https://docs.koog.ai/
