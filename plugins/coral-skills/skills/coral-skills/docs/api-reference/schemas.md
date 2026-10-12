# API reference: schemas

Compact TypeScript-style rendering of the docs' `api_v1.json`, in breadth-first order from the endpoints.
A `?` marks an optional property. Comments carry the schema descriptions.

## SessionRequest

```ts
type SessionRequest = {
  // A request for the agents in this session
  agentGraphRequest: AgentGraphRequest
  // A description of what namespace this session should run in
  namespaceProvider:
    | { type: "create_if_not_exists"; namespaceRequest: SessionNamespaceRequest }
    | { type: "use_existing"; name: string }
  execution?: { mode: "defer" } | { mode: "immediate"; runtimeSettings?: SessionRuntimeSettings }
  // Budget settings for this session. See SessionBudgetSettings for more information
  budgetSettings?: SessionBudgetSettings
  annotations?: Record<string, string>
}
```

## SessionIdentifier

```ts
type SessionIdentifier = {
  // The namespace that this session belongs in
  namespace: string
  // The unique identifier for the session
  sessionId: string
}
```

## RouteException

```ts
type RouteException = { message: string }
```

## SessionRuntimeSettings

```ts
type SessionRuntimeSettings = {
  // If specified, the session will never live longer than this many milliseconds.
  ttl?: integer /* int64 */
  // If specified, the end report generated for this session will be extended, including threads and messages
  extendedEndReport?: boolean
  // Persistence mode for the session. Default is "none" meaning the session will be deleted as soon as it exits
  persistenceMode?:
    | { mode: "hold_after_exit"; duration: integer /* int64 */ }
    | { mode: "minimum_time"; time: integer /* int64 */ }
    | { mode: "none" }
  // Webhooks executed for this session
  webhooks?: SessionWebhooks
}
```

## SessionStateBase

The base state of a running session, without agent or threads

```ts
type SessionStateBase = {
  // The unique identifier for this session
  id: string
  // The timestamp of when this state was generated
  timestamp: string
  // The namespace that this session resides in
  namespace: string
  // The status of the session
  status:
    | { type: "closing"; executionTime: string; closingTime: string }
    | { type: "pending_execution" }
    | { type: "executed"; executionTime: string }
  annotations: Record<string, string>
}
```

## SessionStateExtended

The state of a running session

```ts
type SessionStateExtended = {
  // Base session state
  base: SessionStateBase
  // A list of the states of all agents in this session
  agents: SessionAgentState[]
  // A list of the states of all threads in this session
  threads: SessionThread[]
  // A counter for the session's running budget. See SessionRunningBudget for more information
  runningBudget: SessionRunningBudget
  // The budget settings for this session
  budgetSettings: SessionBudgetSettings
  // A list of receipts for all claims made by all agents in this session
  agentClaimReceipts: SessionAgentClaimReceipt[]
}
```

## SessionNamespaceRequest

```ts
type SessionNamespaceRequest = {
  // The name of this namespace
  name: string
  // If this is true the namespace will be deleted when the last session in this namespace closes. Note that this does not guarantee that the namespace will never be empty, because namespaces can be created without sessions
  deleteOnLastSessionExit?: boolean
  annotations?: Record<string, string>
}
```

## SessionNamespaceStateBase

The base state of a namespace, without session information

```ts
type SessionNamespaceStateBase = {
  // The name of this namespace
  name: string
  // Whether or not this namespace will be deleted when the last session exits
  deleteOnLastSessionExit: boolean
  annotations: Record<string, string>
}
```

## SessionNamespaceStateExtended

The extended state of a namespace, including all sessions

```ts
type SessionNamespaceStateExtended = {
  // Base namespace state
  base: SessionNamespaceStateBase
  // A list of sessions that exist inside this namespace
  sessions: SessionStateBase[]
}
```

## AgentRegistrySource

```ts
type AgentRegistrySource = {
  identifier: { type: "linked"; linkedServerId: string } | { type: "local" } | { type: "marketplace" }
  timestamp: string
  name: string
  agents: RegistryAgentCatalog[]
}
```

## RestrictedRegistryAgent

```ts
type RestrictedRegistryAgent = {
  registryAgent: RegistryAgent
  restrictions: Array<{ type: "linked"; linkedServerId: string } | { type: "local" } | { type: "remote" }>
  extension?: { type: "marketplace"; iconUrl?: string; developer?: string; publishedAt: string }
}
```

## CreateThreadInput

```ts
type CreateThreadInput = {
  // The name of the thread to create, this should be a short summary of the intended topic
  threadName: string
  // The list of participants to include in the thread, this should include any agent that is expected to be involved in the thread's topic. You do not need to include yourself in this list.
  participantNames: string[]
}
```

## CreateThreadOutput

```ts
type CreateThreadOutput = { thread: SessionThread }
```

## CloseThreadInput

```ts
type CloseThreadInput = {
  // The unique identifier for the thread to close
  threadId: string
  // A shortened summary of all important details in this thread. This could also be considered the thread's "conclusion".
  summary: string
}
```

## AddParticipantInput

```ts
type AddParticipantInput = {
  // The unique identifier for the thread to add participants to
  threadId: string
  // The name of the agent to add as a participant to the thread
  participantName: string
}
```

## RemoveParticipantInput

```ts
type RemoveParticipantInput = {
  // The unique identifier for the thread to remove participants from
  threadId: string
  // The name of the agent to remove as a participant of the thread
  participantName: string
}
```

## SendMessageInput

```ts
type SendMessageInput = {
  // The unique identifier for the thread to send a message in
  threadId: string
  // The content of the message to send
  content: string
  mentions: string[]
}
```

## SendMessageOutput

```ts
type SendMessageOutput = { status: string; message: SessionThreadMessage }
```

## AgentClaimRequest

```ts
type AgentClaimRequest = {
  // The name of the claim type. This claim type must be defined in the agent's coral-agent.toml file
  claimTypeName: string
  // The amount of the claim type to claim. The cost of this claim will be multiplied by this value.
  quantity?: integer
  // An additional description of the claim, clamped at 256 characters long
  additionalDescription?: string
  // Set this to false if the agent wants to handle budget exhaustion itself. Budget settings may kill agents on budget exhaustion even if this is set to false
  autoKill: boolean
}
```

## AgentClaimResult

A response to a claim request.

```ts
type AgentClaimResult = {
  // A unique sequential ID assigned to this claim
  claimId: integer /* int32 */
  // The amount requested, echoed back to the agent
  requestedAmount: integer
  // The amount of the budget that could be fulfilled. If this is not equal to the requested amount, the budget was exhausted.
  fulfilledAmount: integer
  // The remaining agent budget after the claim was made
  remainingAgentBudget: integer
  // The remaining session budget after the claim was made
  remainingSessionBudget: integer
  // If this is true, the claim resulted in a budget exhaustion that should cause the agent to exit.
  shouldExit: boolean
}
```

## AgentGraphRequest

```ts
type AgentGraphRequest = {
  // Every agent required for this agent graph
  agents: GraphAgentRequest[]
  // A set, containing sets that define the agent groups by name
  groups?: string[][]
  // A map of custom tools to provide to the agents in this graph
  customTools?: Record<string, GraphAgentTool>
}
```

## GraphAgentRequest

A request for an agent. GraphAgentRequest -> GraphAgent

```ts
type GraphAgentRequest = {
  // The ID of this agent in the registry
  id: RegistryAgentIdentifier
  // A given name for this agent in the session/group
  name: string
  // An optional override for the description of this agent
  description?: string
  // The arguments to pass to the agent
  options?: Record<string,
    | { type: "blob"; value: string }
    | { type: "list[blob]"; value: string[] }
    | { type: "bool"; value: boolean }
    | { type: "i8"; value: integer }
    | { type: "list[i8]"; value: integer[] }
    | { type: "f64"; value: number /* double */ }
    | { type: "list[f64]"; value: Array<number /* double */> }
    | { type: "f32"; value: number /* float */ }
    | { type: "list[f32]"; value: Array<number /* float */> }
    | { type: "i32"; value: integer /* int32 */ }
    | { type: "list[i32]"; value: Array<integer /* int32 */> }
    | { type: "i64"; value: integer /* int64 */ }
    | { type: "list[i64]"; value: Array<integer /* int64 */> }
    | { type: "i16"; value: integer }
    | { type: "list[i16]"; value: integer[] }
    | { type: "string"; value: string }
    | { type: "list[string]"; value: string[] }
    | { type: "u8"; value: integer }
    | { type: "list[u8]"; value: integer[] }
    | { type: "u32"; value: integer }
    | { type: "list[u32]"; value: integer[] }
    | { type: "u64"; value: string }
    | { type: "list[u64]"; value: string[] }
    | { type: "u16"; value: integer }
    | { type: "list[u16]"; value: integer[] }>
  // The system prompt/developer text/preamble passed to the agent
  systemPrompt?: string
  // All blocking agents in a group must be instantiated before the group can communicate. Non-blocking agents' contributions to groups are optional
  blocking?: boolean
  // A list of custom tools that this agent can access. The custom tools must be defined in the parent AgentGraphRequest object
  customToolAccess?: string[]
  // Plugins that should be installed on this agent. See GraphAgentPlugin for more information
  plugins?: Array<{ type: "close_session_tool" }>
  // The server that should provide this agent and the runtime to use
  provider:
    | { type: "linked"; linkedServerName: string; runtime: RuntimeId }
    | { type: "local"; runtime: RuntimeId }
  // An optional list of resources and an accompanied budget that this agent may spend on services that accept x402 payments
  x402Budgets?: X402BudgetedResource[]
  // A map where the key is the name of the proxy request and the value is the configuration and model that should be selected.
  proxies?: Record<string, GraphAgentProxyRequest>
  // Budget settings for this agent. By default the agent has no budget of its own, and can only claim from the sessions budget.
  budgetSettings?: GraphAgentBudgetSettings
  annotations?: Record<string, string>
}
```

## GraphAgentTool

```ts
type GraphAgentTool = {
  transport: { type: "http"; url: string; signatureHeader?: string }
  inputSchema?: ToolSchema
  outputSchema?: ToolSchema
  description?: string
  title?: string
  annotations?: ToolAnnotations
}
```

## SessionBudgetSettings

Budgets settings for this session. Budgets are consumed by agents in the session.

```ts
type SessionBudgetSettings = {
  // This budget is shared across all agents in the session and can be used by any agent configured to consume the shared budget. The value is specified in micro cents. $1.00 is 100000000 and $0.01 is 1000000.")
  budget?: integer
  // The behavior for agents consuming from this budget after it has been exhausted. Note that this behavior only applies to agents that consume from the session budgets. Agents that have their own budget will first perform behaviors described by the agent's own budget settings.
  exhaustionBehavior?:
    | { type: "ignore" }
    | {
      type: "kill_agent"
      // The minimum value, specified in micro cents. $1.00 is 100000000 and $0.01 is 1000000.
      minimum: integer
      // If this is true, when an agent claims from the session budget that is below the minimum, the agent will be killed immediately. If this is false, the agent will only be killed if the agent requests for automatic closing.
      force: boolean
      // If force killing is enabled, it will be delayed by this amount before the agent is killed. If this delay is too low the agent may be killed before it handles to response to a claim
      forceDelay?: string
    }
    | {
      type: "kill_session"
      // The minimum value, specified in micro cents. $1.00 is 100000000 and $0.01 is 1000000.
      minimum: integer
      // The delay before the session is killed. If this delay is too low, the agent whose claim triggered this may be killed before it receives the response to that claim
      delay?: string
    }
}
```

## SessionWebhooks

```ts
type SessionWebhooks = {
  // The webhook that is called when this session ends. The model sent is a SessionEndState
  sessionEnd?: SessionEndWebhook
}
```

## SessionAgentState

The state of an agent running in a session

```ts
type SessionAgentState = {
  // The name given for this agent in the AgentGraph, this is unique in the graph
  name: string
  // The identifier for this agent's registry entry. See RegistryAgent for more information
  registryAgentIdentifier: RegistryAgentIdentifier
  // Nested status state for this agent, running -> connected -> thinking/waiting/sleeping
  status:
    | {
      type: "running"
      connectionStatus:
        | {
          type: "connected"
          communicationStatus: { type: "sleeping" } | { type: "thinking" } | { type: "waiting_message" }
        }
        | { type: "not_connected" }
      // The time that this agent started
      startTime: string
    }
    | {
      type: "stopped"
      // The time that this agent started
      startTime?: string
    }
    | { type: "waiting" }
  // The description of this agent, given to other agents in the graph
  description?: string
  // A list of agents that this agent is aware of, constructed from agent groups in the AgentGraph
  links: string[]
  // A counter for the agent's running budget. See SessionRunningBudget for more information
  runningBudget: SessionRunningBudget
  // The budget settings for this agent
  budgetSettings: GraphAgentBudgetSettings
  annotations: Record<string, string>
}
```

## SessionThread

```ts
type SessionThread = {
  id: string
  name: string
  creatorName: string
  participants: string[]
  messages: SessionThreadMessage[]
  state: { state: "closed"; summary: string; timestamp: string } | { state: "open" }
  timestamp: string
}
```

## SessionRunningBudget

```ts
type SessionRunningBudget = { startBudget: integer; clamp: boolean; remaining: integer; overclaim: integer }
```

## SessionAgentClaimReceipt

A receipt for a claim made by an agent

```ts
type SessionAgentClaimReceipt = {
  // The claim that was made
  claim:
    | {
      type: "llm_proxy_claim"
      timestamp: string
      inputTokenCount: integer
      inputTokenCost: integer
      outputTokenCount: integer
      outputTokenCost: integer
    }
    | {
      type: "rpc_claim"
      timestamp: string
      claimType: RegistryAgentClaimType
      quantity: integer
      additionalDescription?: string
    }
  // The calculated cost of the claim
  cost: integer
  // A unique sequential ID assigned to this claim
  id: integer /* int32 */
}
```

## RegistryAgentCatalog

A catalog describing an agent and it's available versions

```ts
type RegistryAgentCatalog = {
  // The agent's registry name
  name: string
  // All versions this agent is available in
  versions: string[]
}
```

## RegistryAgent

```ts
type RegistryAgent = {
  info: RegistryAgentInfo
  edition: integer /* int32 */
  runtimes: runtime
  options: Record<string,
    | {
      type: "blob"
      default?: string
      validation?: BlobAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "list[blob]"
      default?: string[]
      validation?: BlobAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "bool"
      default?: boolean
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "i8"
      default?: integer
      validation?: ByteAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "list[i8]"
      default?: integer[]
      validation?: ByteAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "f64"
      default?: number /* double */
      validation?: DoubleAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "list[f64]"
      default?: Array<number /* double */>
      validation?: DoubleAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "f32"
      default?: number /* float */
      validation?: FloatAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "list[f32]"
      default?: Array<number /* float */>
      validation?: FloatAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "i32"
      default?: integer /* int32 */
      validation?: IntAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "list[i32]"
      default?: Array<integer /* int32 */>
      validation?: IntAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "i64"
      default?: integer /* int64 */
      validation?: LongAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "list[i64]"
      default?: Array<integer /* int64 */>
      validation?: LongAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "i16"
      default?: integer
      validation?: ShortAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "list[i16]"
      default?: integer[]
      validation?: ShortAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "string"
      default?: string
      validation?: StringAgentOptionValidation
      base64?: boolean
      secret?: boolean
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "list[string]"
      default?: string[]
      validation?: StringAgentOptionValidation
      base64?: boolean
      secret?: boolean
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "u8"
      default?: integer
      validation?: UByteAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "list[u8]"
      default?: integer[]
      validation?: UByteAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "u32"
      default?: integer
      validation?: UIntAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "list[u32]"
      default?: integer[]
      validation?: UIntAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "u64"
      default?: string
      validation?: ULongAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "list[u64]"
      default?: string[]
      validation?: ULongAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "u16"
      default?: integer
      validation?: UShortAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }
    | {
      type: "list[u16]"
      default?: integer[]
      validation?: UShortAgentOptionValidation
      required?: boolean
      display?: AgentOptionDisplay
      transport?: AgentOptionTransport
    }>
  llm?: AgentLlmConfig
  marketplace?: RegistryAgentMarketplaceSettings
  dependencies: RegistryAgentDependency[]
  claimTypes: RegistryAgentClaimType[]
}
```

## SessionThreadMessage

```ts
type SessionThreadMessage = {
  id: string
  threadId: string
  text: string
  senderName: string
  mentionNames: string[]
  timestamp: string
}
```

## RegistryAgentIdentifier

```ts
type RegistryAgentIdentifier = {
  // The exact name of the agent in the registry
  name: string
  // The exact version of the agent in the registry
  version: string
  // The identifier for the registry source that contains this agent
  registrySourceId: { type: "linked"; linkedServerId: string } | { type: "local" } | { type: "marketplace" }
}
```

## RuntimeId

```ts
type RuntimeId = "executable" | "docker" | "function" | "prototype"
```

## X402BudgetedResource

A budget given to an agent for a specific resource

```ts
type X402BudgetedResource = {
  // The priority of this budget. If a x402 service accepts multiple resources and an agent was given a budget for multiple resources, the resource with the highest priority will be used until it is consumed
  priority: integer /* int32 */
  // The this budget is for
  resource: string
  // The remaining budget for this resource in atomic units
  remainingBudget: integer
}
```

## GraphAgentProxyRequest

```ts
type GraphAgentProxyRequest = {
  // The name of the LLM proxy configuration
  configurationName: string
  // The name of the model
  modelName: string
}
```

## GraphAgentBudgetSettings

```ts
type GraphAgentBudgetSettings = {
  // The budget for this specific agent. The value is specified in micro cents. $1.00 is 100000000 and $0.01 is 1000000.
  budget?: integer
  // A map where each key is a claim type name and the value the cost for that claim. Claims that do not have default values set must have their values set in this map or else they will not contribute to the budget.
  claimTypeCosts?: Record<string, integer>
  // The behavior of agent budget exhaustion, defaults to consuming session budget.
  exhaustionBehavior?:
    | { type: "consume_session" }
    | {
      type: "kill"
      // The minimum value, specified in micro cents. $1.00 is 100000000 and $0.01 is 1000000.
      minimum: integer
      // If this is true, the agent will be killed immediately. If this is false, the agent will only be killed if the claim requests for automatic closing.
      force: boolean
      // If force killing is enabled, it will be delayed by this amount before the agent is killed. If this delay is too low the agent may be killed before it handles to response to a claim
      forceDelay?: string
    }
}
```

## ToolSchema

```ts
type ToolSchema = {
  $schema?: string
  properties?: Record<string, JsonElement>
  required?: string[]
  $defs?: Record<string, JsonElement>
  type: string
}
```

## ToolAnnotations

```ts
type ToolAnnotations = {
  title?: string
  readOnlyHint?: boolean
  destructiveHint?: boolean
  idempotentHint?: boolean
  openWorldHint?: boolean
}
```

## SessionEndWebhook

The webhook that is called when this session ends. The model sent is a SessionEndState

```ts
type SessionEndWebhook = { url: string }
```

## RegistryAgentClaimType

```ts
type RegistryAgentClaimType = {
  // A unique name for this claim type. This name will be used to make claims of this type
  name: string
  // A human-readable description of this claim type
  description: string
  dependency: string
  // The cost of this claim type. This value can be overridden by the application. Application developers are encouraged to specify values for all claim types. The value is specified in micro cents. $1.00 is 100000000 and $0.01 is 1000000.
  cost?: integer
}
```

## RegistryAgentInfo

```ts
type RegistryAgentInfo = {
  capabilities: AgentCapability[]
  identifier: RegistryAgentIdentifier
  description: string
  readme: string
  summary: string
  license: { type: "spdx"; expression: string } | { type: "text"; text: string }
  keywords?: string[]
  links?: Record<string, string>
}
```

## runtime

```ts
type runtime = {
  executable?: executable
  docker?: docker
  function?: FunctionRuntime
  prototype?: PrototypeRuntime
}
```

## BlobAgentOptionValidation

```ts
type BlobAgentOptionValidation = { min_size?: ByteSize; max_size?: ByteSize }
```

## AgentOptionDisplay

```ts
type AgentOptionDisplay = { label?: string; description?: string; group?: string; multiline?: boolean }
```

## AgentOptionTransport

```ts
type AgentOptionTransport = "env" | "fs"
```

## ByteAgentOptionValidation

```ts
type ByteAgentOptionValidation = { variants?: integer[]; min?: integer; max?: integer }
```

## DoubleAgentOptionValidation

```ts
type DoubleAgentOptionValidation = { variants?: Array<number /* double */>; min?: number /* double */; max?: number /* double */ }
```

## FloatAgentOptionValidation

```ts
type FloatAgentOptionValidation = { variants?: Array<number /* float */>; min?: number /* float */; max?: number /* float */ }
```

## IntAgentOptionValidation

```ts
type IntAgentOptionValidation = { variants?: Array<integer /* int32 */>; min?: integer /* int32 */; max?: integer /* int32 */ }
```

## LongAgentOptionValidation

```ts
type LongAgentOptionValidation = { variants?: Array<integer /* int64 */>; min?: integer /* int64 */; max?: integer /* int64 */ }
```

## ShortAgentOptionValidation

```ts
type ShortAgentOptionValidation = { variants?: integer[]; min?: integer; max?: integer }
```

## StringAgentOptionValidation

```ts
type StringAgentOptionValidation = {
  variants?: string[]
  min_length?: integer /* int32 */
  max_length?: integer /* int32 */
  regex?: string
}
```

## UByteAgentOptionValidation

```ts
type UByteAgentOptionValidation = { variants?: integer[]; min?: integer; max?: integer }
```

## UIntAgentOptionValidation

```ts
type UIntAgentOptionValidation = { variants?: integer[]; min?: integer; max?: integer }
```

## ULongAgentOptionValidation

```ts
type ULongAgentOptionValidation = { variants?: integer[]; min?: integer; max?: integer }
```

## UShortAgentOptionValidation

```ts
type UShortAgentOptionValidation = { variants?: integer[]; min?: integer; max?: integer }
```

## AgentLlmConfig

```ts
type AgentLlmConfig = { proxies: AgentLlmProxyRequest[] }
```

## RegistryAgentMarketplaceSettings

```ts
type RegistryAgentMarketplaceSettings = {
  keywords?: string[]
  pricing?: RegistryAgentMarketplacePricing
  identities?: RegistryAgentMarketplaceIdentities
}
```

## RegistryAgentDependency

A dependency that must be provided to use this agent. Dependencies are powered by options. If a dependency is only provided options that are not required, the dependency is effectively optional.

```ts
type RegistryAgentDependency = {
  // The unique name of this dependency
  name: string
  // A list of options associated with this dependency
  options: string[]
}
```

## JsonElement

```ts
type JsonElement = object
```

## AgentCapability

```ts
type AgentCapability = "resources" | "tool_refreshing"
```

## executable

```ts
type executable = { path: string; arguments: string[]; transport: McpTransportType }
```

## docker

```ts
type docker = { image: string; transport: McpTransportType; command?: string[] }
```

## FunctionRuntime

```ts
type FunctionRuntime = { transport: McpTransportType }
```

## PrototypeRuntime

```ts
type PrototypeRuntime = {
  volatile: boolean
  proxy: PrototypeString
  client?:
    | { type: "anthropic" }
    | { type: "deepseek"; strict: boolean }
    | { type: "openai"; strict: boolean }
    | { type: "openrouter"; strict: boolean }
  iterations: PrototypeInteger
  delay: PrototypeInteger
  prompts: PrototypePrompts
  tools: Array<
    | {
      type: "mcp_sse"
      url: PrototypeString
      auth:
        | { type: "authorization_header"; header: PrototypeString }
        | { type: "bearer"; token: PrototypeString }
        | { type: "none" }
    }
    | {
      type: "mcp_streamable_http"
      url: PrototypeString
      auth:
        | { type: "authorization_header"; header: PrototypeString }
        | { type: "bearer"; token: PrototypeString }
        | { type: "none" }
    }>
}
```

## ByteSize

```ts
type ByteSize = object
```

## AgentLlmProxyRequest

```ts
type AgentLlmProxyRequest = {
  name: string
  format: { type: "Anthropic" } | { type: "DeepSeek" } | { type: "OpenAI" }
  models: string[]
}
```

## RegistryAgentMarketplacePricing

```ts
type RegistryAgentMarketplacePricing = {
  description: string
  recommendations: RegistryAgentMarketplacePricingRecommendations
  currency?: string
}
```

## RegistryAgentMarketplaceIdentities

```ts
type RegistryAgentMarketplaceIdentities = { erc8004?: RegistryAgentMarketplaceIdentityErc8004 }
```

## McpTransportType

```ts
type McpTransportType = "sse" | "streamable_http"
```

## PrototypeString

```ts
type PrototypeString = object
```

## PrototypeInteger

```ts
type PrototypeInteger = object
```

## PrototypePrompts

```ts
type PrototypePrompts = { system: PrototypeSystemPrompt; loop: PrototypeLoopPrompt }
```

## RegistryAgentMarketplacePricingRecommendations

```ts
type RegistryAgentMarketplacePricingRecommendations = { min: number /* double */; max: number /* double */ }
```

## RegistryAgentMarketplaceIdentityErc8004

```ts
type RegistryAgentMarketplaceIdentityErc8004 = { wallet: string; endpoints?: Erc8004Endpoint[] }
```

## PrototypeSystemPrompt

```ts
type PrototypeSystemPrompt = { base: PrototypeString; extra?: PrototypeString }
```

## PrototypeLoopPrompt

```ts
type PrototypeLoopPrompt = { initial: PrototypeLoopInitialPrompt; followup: PrototypeString }
```

## Erc8004Endpoint

```ts
type Erc8004Endpoint = { name: string; endpoint: string }
```

## PrototypeLoopInitialPrompt

```ts
type PrototypeLoopInitialPrompt = { base: PrototypeString; extra?: PrototypeString }
```
