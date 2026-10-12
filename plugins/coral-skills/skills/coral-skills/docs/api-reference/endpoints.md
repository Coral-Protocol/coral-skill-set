# API reference: endpoints

Rendered from the docs' `api_v1.json` in the order of the docs' API Reference tab.
Schemas are in [schemas.md](schemas.md). The raw OpenAPI document is [api_v1.json](api_v1.json).
The running server's own schema at `/api_v1.json` is authoritative for that server.

## Local

### Session

#### Create session

`POST /api/v1/local/session`

Creates a new session in a given namespace

- Request body (optional): [`SessionRequest`](schemas.md#sessionrequest). The session request body, containing the agents to use in the session and other settings
- Response 200: Success, [`SessionIdentifier`](schemas.md#sessionidentifier)
- Response 403: Invalid application ID or privacy key, [`RouteException`](schemas.md#routeexception)
- Response 400: The agent graph is invalid and could not be processed, [`RouteException`](schemas.md#routeexception)
- Auth: bearer `token`

#### Executes a session

`POST /api/v1/local/session/{namespace}/{sessionId}`

Executes a session was created with deferred execution

- path `namespace` (string, required): The namespace of the session
- path `sessionId` (string, required): The sessionId of the session
- Request body (optional): [`SessionRuntimeSettings`](schemas.md#sessionruntimesettings). Settings for the execution of the session
- Response 200: Success
- Response 404: Either namespace or session ID is invalid, [`RouteException`](schemas.md#routeexception)
- Response 400: The session exists but is not pending execution, [`RouteException`](schemas.md#routeexception)
- Auth: bearer `token`

#### Close an active session

`DELETE /api/v1/local/session/{namespace}/{sessionId}`

Closes an active session, cancelling all running agents

- path `namespace` (string, required): The namespace of the session to close
- path `sessionId` (string, required): The sessionId of the session to close
- Response 200: Success
- Response 404: If either namespace or session ID is invalid, [`RouteException`](schemas.md#routeexception)
- Auth: bearer `token`

#### Get base session state

`GET /api/v1/local/session/{namespace}/{sessionId}`

Returns a session's state

- path `namespace` (string, required): The namespace of the session
- path `sessionId` (string, required): The sessionId of the session
- Response 200: Success, [`SessionStateBase`](schemas.md#sessionstatebase)
- Response 404: Either namespace or session ID is invalid, [`RouteException`](schemas.md#routeexception)
- Auth: bearer `token`

#### Get extended session state

`GET /api/v1/local/session/{namespace}/{sessionId}/extended`

Returns a session's extended state

- path `namespace` (string, required): The namespace of the session
- path `sessionId` (string, required): The sessionId of the session
- Response 200: Success, [`SessionStateExtended`](schemas.md#sessionstateextended)
- Response 404: Either namespace or session ID is invalid, [`RouteException`](schemas.md#routeexception)
- Auth: bearer `token`

### Namespace

#### Create namespace

`POST /api/v1/local/namespace`

Creates a new empty namespace

- Request body (optional): [`SessionNamespaceRequest`](schemas.md#sessionnamespacerequest). Namespace settings
- Response 200: Success
- Response 403: Invalid application ID or privacy key, [`RouteException`](schemas.md#routeexception)
- Response 400: Invalid namespace settings providewd, [`RouteException`](schemas.md#routeexception)
- Auth: bearer `token`

#### Delete a namespace

`DELETE /api/v1/local/namespace/{namespace}`

Deletes a given namespace, closing any session that it may contain

- path `namespace` (string, required): The namespace to delete
- Response 404: Invalid namespace provided, [`RouteException`](schemas.md#routeexception)
- Auth: bearer `token`

#### List base namespace states

`GET /api/v1/local/namespace`

Returns a list of namespace states

- Response 200: Success, `SessionNamespaceStateBase[]`
- Auth: bearer `token`

#### List base session states

`GET /api/v1/local/namespace/{namespace}`

List base session states for a given namespace

- path `namespace` (string, required): The namespace name
- Response 200: Success, `SessionStateBase[]`
- Response 404: Invalid namespace provided, [`RouteException`](schemas.md#routeexception)
- Auth: bearer `token`

#### List extended session states

`GET /api/v1/local/namespace/{namespace}/extended`

List extended session states for a given namespace

- path `namespace` (string, required): The namespace name
- Response 200: Success, `SessionStateExtended[]`
- Response 404: Invalid namespace provided, [`RouteException`](schemas.md#routeexception)
- Auth: bearer `token`

#### List extended namespace states

`GET /api/v1/local/namespace/extended`

Returns a list of extended namespace states

- Response 200: Success, `SessionNamespaceStateExtended[]`
- Auth: bearer `token`

## Registry

### Get registry agents

`GET /api/v1/registry`

Returns a list of all agents available in this servers registry

- Response 200: Success, `AgentRegistrySource[]`
- Auth: bearer `token`

### Inspect local registry agent

`GET /api/v1/registry/local/{agentName}/{agentVersion}`

Returns all details about a specific agent in the local registry

- path `agentName` (string, required): The name of the agent
- path `agentVersion` (string, required): The version of the agent
- Response 200: Success, [`RestrictedRegistryAgent`](schemas.md#restrictedregistryagent)
- Response 404: Agent not found, [`RouteException`](schemas.md#routeexception)
- Auth: bearer `token`

### Inspect marketplace registry agent

`GET /api/v1/registry/marketplace/{agentName}/{agentVersion}`

Returns all details about a specific agent in the marketplace

- path `agentName` (string, required): The name of the agent
- path `agentVersion` (string, required): The version of the agent
- Response 200: Success, [`RestrictedRegistryAgent`](schemas.md#restrictedregistryagent)
- Response 404: Agent not found, [`RouteException`](schemas.md#routeexception)
- Auth: bearer `token`

### Inspect linked server registry agent

`GET /api/v1/registry/linked/{linkedServerName}/{agentName}/{agentVersion}`

Returns all details about a specific agent from a specific linked server

- path `linkedServerName` (string, required): The name of the linked server to source the details of this agent from
- path `agentName` (string, required): The name of the agent
- path `agentVersion` (string, required): The version of the agent
- Response 200: Success, [`RestrictedRegistryAgent`](schemas.md#restrictedregistryagent)
- Response 404: Agent or linked server not found, [`RouteException`](schemas.md#routeexception)
- Auth: bearer `token`

## Puppet

### Create thread

`POST /api/v1/puppet/{namespace}/{sessionId}/{agentName}/thread`

Creates a new thread masquerading as the specified agent

- path `namespace` (string, required): The session's namespace
- path `sessionId` (string, required): The session's ID
- path `agentName` (string, required): The agent's name
- Request body (optional): [`CreateThreadInput`](schemas.md#createthreadinput). Thread creation input
- Response 200: Success, [`CreateThreadOutput`](schemas.md#createthreadoutput)
- Response 404: Agent not found, [`RouteException`](schemas.md#routeexception)
- Auth: bearer `token`

### Close thread

`DELETE /api/v1/puppet/{namespace}/{sessionId}/{agentName}/thread`

Closes a thread masquerading as the specified agent

- path `namespace` (string, required): The session's namespace
- path `sessionId` (string, required): The session's ID
- path `agentName` (string, required): The agent's name
- Request body (optional): [`CloseThreadInput`](schemas.md#closethreadinput). Thread close input
- Response 200: Success
- Response 404: Agent or thread not found, [`RouteException`](schemas.md#routeexception)
- Response 400: Thread cannot be closed, [`RouteException`](schemas.md#routeexception)
- Auth: bearer `token`

### Add thread participant

`POST /api/v1/puppet/{namespace}/{sessionId}/{agentName}/thread/participant`

Adds an agent to a thread masquerading as the specified agent

- path `namespace` (string, required): The session's namespace
- path `sessionId` (string, required): The session's ID
- path `agentName` (string, required): The agent's name
- Request body (optional): [`AddParticipantInput`](schemas.md#addparticipantinput). Thread and participant information details
- Response 200: Success
- Response 404: Agent or thread not found, [`RouteException`](schemas.md#routeexception)
- Response 400: Participant cannot be added, [`RouteException`](schemas.md#routeexception)
- Auth: bearer `token`

### Remove thread participant

`DELETE /api/v1/puppet/{namespace}/{sessionId}/{agentName}/thread/participant`

Removes an agent from a thread masquerading as the specified agent

- path `namespace` (string, required): The session's namespace
- path `sessionId` (string, required): The session's ID
- path `agentName` (string, required): The agent's name
- Request body (optional): [`RemoveParticipantInput`](schemas.md#removeparticipantinput). Thread and participant information details
- Response 200: Success
- Response 404: Agent or thread not found, [`RouteException`](schemas.md#routeexception)
- Response 400: Participant cannot be removed, [`RouteException`](schemas.md#routeexception)
- Auth: bearer `token`

### Send message

`POST /api/v1/puppet/{namespace}/{sessionId}/{agentName}/thread/message`

Sends a message in a thread masquerading as the specified agent

- path `namespace` (string, required): The session's namespace
- path `sessionId` (string, required): The session's ID
- path `agentName` (string, required): The agent's name
- Request body (optional): [`SendMessageInput`](schemas.md#sendmessageinput). Message input
- Response 200: Success, [`SendMessageOutput`](schemas.md#sendmessageoutput)
- Response 404: Agent or thread not found, [`RouteException`](schemas.md#routeexception)
- Response 400: Bad message, [`RouteException`](schemas.md#routeexception)
- Auth: bearer `token`

### End agent runtime

`DELETE /api/v1/puppet/{namespace}/{sessionId}/{agentName}`

Forcefully cause an agent to exit it's own runtime

- path `namespace` (string, required): The session's namespace
- path `sessionId` (string, required): The session's ID
- path `agentName` (string, required): The agent's name
- Response 200: Success
- Response 404: Agent not found, [`RouteException`](schemas.md#routeexception)
- Response 400: Agent not running, [`RouteException`](schemas.md#routeexception)
- Auth: bearer `token`

## Agent RPC

### Submit an agent claim

`POST /api/v1/agent-rpc/claim`

Submits a claim for work performed

- Request body (optional): [`AgentClaimRequest`](schemas.md#agentclaimrequest). A description of the work done and the payment required
- Response 200: Success, [`AgentClaimResult`](schemas.md#agentclaimresult)
- Response 401: Bad agent secret provided, [`RouteException`](schemas.md#routeexception)
- Response 400: Invalid claim type provided, [`RouteException`](schemas.md#routeexception)
- Auth: bearer `agentSecret`

### Request for x402 proxying

`POST /api/v1/agent-rpc/x402`

Allows an agent to request that the server pays for an x402 service by proxy

- path `agentSecret` (string, required): The agent's unique secret
- Request body (optional): [`X402ProxyRequest`](schemas.md#x402proxyrequest). The request to be proxied
- Response 200: Success, [`X402ProxiedResponse`](schemas.md#x402proxiedresponse)
- Auth: bearer `agentSecret`
