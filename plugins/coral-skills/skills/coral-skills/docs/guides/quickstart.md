# Quickstart

CoralOS Quickstart

Source: https://docs.coralos.ai/guides/quickstart

## What is CoralOS?

CoralOS is a platform for deploying and orchestrating agents that connect easily (with each other, your application, agentic middleware, ...)

CoralOS consists of the Coral Server and supporting tooling/ecosystem.

Think of CoralOS as the "Kubernetes for agents": you have a HTTP API, like a control plane, that lets you spin up a graph of agents with fully controlled lifecycles.

### What makes an agent a CoralOS agent?

The basic requirements for an agent to run via Coral and be fully interoperable with the ecosystem are:
* it can run in a container
* it connects to the supplied unique MCP server URL passed to it

With just those met, a whole host of things become possible:
* Custom tools can be provided to any agent by the consuming application
* Agents can discover and work with the other agents they are in groups with
* Their lifecycles are fully managed, with configurable time-to-live for cost predictability.

### What are some more advanced features of CoralOS?

CoralOS makes many more interesting things easy:

* Pushing your agents to a [marketplace](https://marketplace.coralprotocol.ai/), where they may be used securely for free or become their own revenue streams
* Agent re-usability via [exposable configuration (options)](../reference/agent/tables/options.md)
* Safely intercept & manipulate LLM requests in-flight, to e.g. patch prompts, add memory to memoryless agents, or change the model used; without touching agent code (in-flight manipulation features coming soon)

# Getting started

> **Tip:**
>
> You can try out CoralOS right away with some pre-built agents using [Coral Cloud](https://coralcloud.ai/).
>
> The operation of Coral Cloud is very similar, though currently it doesn't support using your own agents.
>
> For a deep dive on using Coral Cloud, see [this guide](../cloud/using-api.md)

## Step 1: Run the server

Running the server is easy:

Agents that request an LLM proxy need a matching provider configured on the server. A Coral Cloud API key configures supported providers automatically; alternatively, [configure your own provider keys](../reference/server/llm-proxy.md#providers). Built-in debug agents do not need an LLM provider.
Build and run the server with JDK 24 and Git installed. Docker is also required for agents using the Docker runtime.
```bash git + gradle
# Start server (logs show in this terminal)
git clone --branch v1.5.0 https://github.com/Coral-Protocol/coral-server
cd coral-server
./gradlew run --args="--auth.keys=dev --cloud.api-key=coral..."
```

> **Note:**
>
> After the server starts, it prints an address to the Coral Console. You can "login" with the auth key `dev` or whatever you passed for the auth.keys parameter.

> **Danger:**
>
> Make sure to use a secure auth key in production, and follow conventional security practices when exposing your Coral Server to the public internet!

## Step 2: Create your own agent

Let's create a new agent from source to use in our server.

We will use a template for convenience, but writing agents in any framework (or modifying existing to work with Coral) is also easy.

> **Tip:**
>
> See [this guide](../guides/writing-agents.md) on writing agents for more information on agent requirements.

### Using the Koog template (Kotlin)

```bash npm
npm create koog -- my-first-agent --agentName=my-first-agent --packageName=com.example.myfirstagent --keepWorkflows=true --keepPublishJvm=true --keepPublishNative=true --keepReleasePlease=true
```

```bash git + gradle
git clone https://github.com/Coral-Protocol/coral-koog-agent my-first-agent
cd my-first-agent
./gradlew hydrate my-first-agent
```

Check the template's own README for its JDK requirement; it can differ from Coral Server's JDK 24 requirement.

This will create a Kotlin agent using JetBrain's wonderful [Koog framework](https://docs.koog.ai/)

You should now have a file structure that looks something like this:

```text
my-first-agent/
  src/
    ...
  build.gradle.kts
  coral-agent.toml
  ...
```

> **Note:**
>
> `coral-agent.toml` is Coral's entrypoint to this agent, with all relevant agent metadata (runtime, options, etc).
>
> Learn more about it [here](../reference/agent.md)

### Other templates & agent examples

| Language | Framework      | Maturity | Repositories |
|----------|----------------|----------------------|------------------------------------------------------------------------------------------------|
| Rust     | coral-rs (Rig) | Low                  | [Deepwiki Agent](https://github.com/Coral-Protocol/agents/blob/main/rust/agent-deepwiki/src/main.rs) |
| Kotlin   | Koog           | High                 | [Template](https://github.com/Coral-Protocol/coral-koog-agent)                      |
| Python   | LangChain      | Low                  | [Template](https://github.com/Coral-Protocol/langchain-agent)                  |

Missing any? Come to [our discord](https://discord.gg/2subZkSWWu) to share your own examples or ask for relevant ones.

## Step 3: Add the agent to your server

Open a terminal in your generated `my-first-agent` directory, then link it so servers on that machine can discover it:
```bash
npx @coral-protocol/coralizer@latest link .
```

> **Note:**
>
> On Windows, you may need to run as administrator to avoid permission issues creating the symlink

> **Info:**
>
> This creates a symlink called `~/.coral/agents/my-first-agent/{agentVersion}` pointing to your agent's directory

To "unlink" this agent, you can run:
```bash
unlink ~/.coral/agents/my-first-agent/{version}
# replace {version} with your agent's version (as seen in the coral-agent.toml)
```

## Step 4: Create a session in Coral Server

Now that you have agent(s) in your server, you can create a multi agent session!

Creating a session can be done in [one POST request](../api-reference/endpoints.md#create-session), but for a more convenient experience, you can use Coral Console.

### Coral Console (development / testing)

#### Step 1: Navigate to the console

Open your browser and go to http://localhost:5555/ui/console

#### Step 2: Create a new template

Click on 'Templates' under 'Workbench', then create a new template

#### Step 3: Add your agent

Click `Add an agent` to add an agent to the template

#### Step 4: Fill out necessary agent options and session TTL

Depending on your agent(s), you may need to fill out some values here.

You must also set the session's TTL (time-to-live), which determines how long the session can run before it is automatically terminated.

#### Step 5: Click 'Save template'

Optionally, save the template you just created

#### Step 6: Run the template

Run the template you just created to start a new session with your agent

#### Step 7: Observe the agents

1. Go to the session you just started under "Session" in the sidebar
2. Check out the agents and their logs
3. Check out what's going on in the threads

### From code (production)

Ultimately it's intended that Coral sessions are instantiated via code. Coral Console provides the needed JSON payload for the [create session endpoint](../api-reference/endpoints.md#create-session), as well as code snippets that include making the request.

Coral Server requires a bearer token for application REST endpoints. We set our auth key to `dev` in [Step 1](#step-1-run-the-server), so use the header `Authorization: Bearer dev`. The documentation endpoints are public, while agents use their own MCP URLs and agent RPC credentials.

> **Note:**
>
> In the case of Coral Cloud, it must be an API key you create from your [account settings](https://coralcloud.ai/account).

> **Danger:**
>
> Make sure to use a secure auth key, and follow conventional security practices when exposing your Coral Server to the public internet!

Naturally, variable substitution and environment variables should be used over hardcoding every option value, since sensitive information like API keys can be passed as agent options.

That wraps up the CoralOS quickstart! Next, see [Integrating with your app](../guides/integrating-with-your-app.md).
