# Coral API Schema Index

Alphabetical list of all schemas in the Coral Server OpenAPI spec. For full details, access the interactive spec at `http://localhost:5555/ui/docs` when the server is running.

| Schema | Description |
|--------|-------------|
| AddParticipantInput | Input for adding a participant to a thread |
| AgentCapability | Describes a capability an agent supports |
| AgentExportSettings | Settings for exporting an agent |
| AgentGraphRequest | The top-level agent graph for session creation (contains agents + groups) |
| AgentOptionDisplay | Display metadata for an agent option |
| AgentOptionTransport | Transport format for agent options |
| AgentPaymentClaimRequest | Request to claim payment for agent work |
| AgentRegistrySource | Source identifier for an agent (local, marketplace, linked) |
| AgentRemainingBudget | Remaining budget for a rental agent |
| BlobAgentOptionValidation | Validation rules for blob-type agent options |
| ByteAgentOptionValidation | Validation rules for byte-type options |
| ByteUnitSizes | Byte unit size definitions |
| CloseThreadInput | Input for closing a thread |
| CreateThreadInput | Input for creating a thread (threadName + participantNames) |
| CreateThreadOutput | Response from thread creation (contains SessionThread) |
| DoubleAgentOptionValidation | Validation rules for double-type options |
| Erc8004Endpoint | ERC-8004 payment endpoint definition |
| FloatAgentOptionValidation | Validation rules for float-type options |
| FunctionRuntime | Runtime definition for function-based agents |
| GraphAgentRequest | Individual agent request within a graph (id, name, provider, options, etc.) |
| GraphAgentServer | Server configuration for a graph agent |
| GraphAgentServerAttributeType | Attribute types for agent server scoring |
| GraphAgentServerScorerEffect | Scoring effect for agent server selection |
| GraphAgentTool | Tool definition for a graph agent |
| IntAgentOptionValidation | Validation rules for integer-type options |
| JsonElement | Generic JSON element |
| LocalSessionManagerEvent | Event emitted by the local session manager |
| LoggingEvent | Logging event data |
| LoggingTagIo | I/O tag for logging |
| LongAgentOptionValidation | Validation rules for long-type options |
| McpResourceName | MCP resource identifier |
| McpToolName | MCP tool identifier |
| McpTransportType | MCP transport type (streamable_http, stdio) |
| PaidGraphAgentRequest | Agent request with payment information |
| PrototypeLoopInitialPrompt | Initial prompt for prototype loop runtime |
| PrototypeLoopPrompt | Loop prompt for prototype runtime |
| PrototypePrompts | All prompts for prototype runtime |
| PrototypeRuntime | Prototype runtime configuration |
| PrototypeString | String template for prototype runtime |
| PrototypeSystemPrompt | System prompt for prototype runtime |
| PublicAgentExportSettings | Public export settings for agents |
| PublicRegistryAgent | Public-facing registry agent data |
| PublicRestrictedRegistryAgent | Registry agent with run-location restrictions |
| RegistryAgent | Full registry agent definition |
| RegistryAgentCatalog | Catalog of an agent and its available versions |
| RegistryAgentExportPricing | Pricing info for exported agents |
| RegistryAgentIdentifier | Agent identifier (name + version + source) |
| RegistryAgentInfo | Basic agent info from registry |
| RegistryAgentMarketplaceIdentities | Marketplace identity info for agents |
| RegistryAgentMarketplaceIdentityErc8004 | ERC-8004 marketplace identity |
| RegistryAgentMarketplacePricing | Marketplace pricing configuration |
| RegistryAgentMarketplacePricingRecommendations | Pricing recommendations |
| RegistryAgentMarketplaceSettings | Marketplace publication settings |
| RemoveParticipantInput | Input for removing a thread participant |
| RestrictedRegistryAgent | Agent with run restrictions |
| RouteException | Error response from API |
| RuntimeId | Runtime identifier |
| SendMessageInput | Input for sending a message (threadId + content + mentions) |
| SendMessageOutput | Response from message send (status + message) |
| SessionAgentState | State of an agent in a session (name, status, links) |
| SessionAgentUsageReport | Usage report for a session agent |
| SessionEndReport | Report generated when a session ends |
| SessionEndWebhook | Webhook called when session ends |
| SessionEvent | Event in a session lifecycle |
| SessionIdentifier | Session identifier (namespace + sessionId) |
| SessionNamespaceRequest | Request to create a namespace |
| SessionNamespaceStateBase | Base namespace state (no session details) |
| SessionNamespaceStateExtended | Extended namespace state (includes sessions) |
| SessionRequest | Top-level session creation request |
| SessionRuntimeSettings | Runtime settings (TTL, etc.) |
| SessionStateBase | Base session state (no agent/thread details) |
| SessionStateExtended | Full session state (agents + threads + messages) |
| SessionThread | Thread with messages and participants |
| SessionThreadMessage | Individual message in a thread |
| SessionWebhooks | Webhook configuration for sessions |
| ShortAgentOptionValidation | Validation for short-type options |
| StringAgentOptionValidation | Validation for string-type options |
| ToolAnnotations | Annotations for MCP tools |
| ToolSchema | Schema definition for a tool |
| UByteAgentOptionValidation | Validation for unsigned byte options |
| UIntAgentOptionValidation | Validation for unsigned int options |
| ULongAgentOptionValidation | Validation for unsigned long options |
| UShortAgentOptionValidation | Validation for unsigned short options |
| ValidationFileSize | File size validation rules |
| X402BudgetedResource | Budget for x402 payment resources |
| X402ProxiedResponse | Response from x402 proxy |
| X402ProxyRequest | Request to proxy through x402 |
| docker | Docker runtime configuration |
| executable | Executable runtime configuration |
| flat | Flat scoring weight (positive or negative) |
| runtime | Generic runtime definition |
