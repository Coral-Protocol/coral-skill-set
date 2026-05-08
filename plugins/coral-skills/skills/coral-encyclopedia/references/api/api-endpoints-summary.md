# Coral Server API Endpoints Summary

Base URL: `http://localhost:5555` (local) or `https://api.coralcloud.ai/` (cloud)

All requests require `Authorization: Bearer <token>` header.

---

## Session Management

### POST /api/v1/local/session — Create session

Creates a new session with agents.

```json
// Request
{
  "agentGraphRequest": {
    "agents": [
      {
        "id": {"name": "claude-code-agent", "version": "0.1.0", "registrySourceId": {"type": "local"}},
        "name": "my-claude",
        "provider": {"type": "local", "runtime": "executable"},
        "description": "Coding agent",
        "options": {},
        "blocking": false
      }
    ],
    "groups": [["my-claude", "puppet-agent"]]
  },
  "namespaceProvider": {
    "type": "create_if_not_exists",
    "namespaceRequest": {"name": "demo", "deleteOnLastSessionExit": false}
  },
  "execution": {
    "mode": "immediate",
    "runtimeSettings": {"ttl": 86400000}
  }
}

// Response
{
  "namespace": "demo",
  "sessionId": "abc123-..."
}
```

### GET /api/v1/local/session/{namespace}/{sessionId} — Get base session state

Returns basic session state (no agent/thread details).

### GET /api/v1/local/session/{namespace}/{sessionId}/extended — Get extended session state

Returns full session state including agents, threads, and messages. This is the primary endpoint for checking agent status and reading messages.

```json
// Response (simplified)
{
  "base": {
    "namespace": "demo",
    "sessionId": "abc123",
    "status": "running"
  },
  "agents": [
    {
      "name": "my-claude",
      "status": "connected",
      "description": "Coding agent"
    }
  ],
  "threads": [
    {
      "id": "thread-1",
      "name": "Task Thread",
      "creatorName": "puppet-agent",
      "participants": ["puppet-agent", "my-claude"],
      "messages": [
        {
          "id": "msg-1",
          "threadId": "thread-1",
          "text": "Hello from puppet",
          "senderName": "puppet-agent",
          "mentionNames": ["my-claude"],
          "timestamp": "2025-01-01T00:00:00Z"
        }
      ]
    }
  ]
}
```

### POST /api/v1/local/session/{namespace}/{sessionId} — Execute session

Executes/interacts with an active session.

### DELETE /api/v1/local/session/{namespace}/{sessionId} — Close session

Terminates an active session and all its agents.

---

## Namespace Management

### GET /api/v1/local/namespace — List namespace states (base)
### POST /api/v1/local/namespace — Create namespace
### GET /api/v1/local/namespace/{namespace} — List session states in namespace
### DELETE /api/v1/local/namespace/{namespace} — Delete namespace
### GET /api/v1/local/namespace/{namespace}/extended — List extended session states
### GET /api/v1/local/namespace/extended — List extended namespace states

---

## Puppet API (Agent HTTP interface)

These endpoints let you control an agent via HTTP (primarily used with puppet-agent).

### POST /api/v1/puppet/{namespace}/{sessionId}/{agentName}/thread — Create thread

```json
// Request
{
  "threadName": "Task Thread",
  "participantNames": ["puppet-agent", "my-claude"]
}

// Response
{
  "thread": {
    "id": "thread-uuid",
    "name": "Task Thread",
    "creatorName": "puppet-agent",
    "participants": ["puppet-agent", "my-claude"],
    "messages": [],
    "state": "open"
  }
}
```

### POST /api/v1/puppet/{namespace}/{sessionId}/{agentName}/thread/message — Send message

```json
// Request
{
  "threadId": "thread-uuid",
  "content": "Please analyze this code",
  "mentions": ["my-claude"]
}

// Response
{
  "status": "sent",
  "message": {
    "id": "msg-uuid",
    "threadId": "thread-uuid",
    "text": "Please analyze this code",
    "senderName": "puppet-agent",
    "mentionNames": ["my-claude"],
    "timestamp": "2025-01-01T00:00:00Z"
  }
}
```

### POST /api/v1/puppet/{namespace}/{sessionId}/{agentName}/thread/participant — Add participant

```json
{"threadId": "thread-uuid", "participantName": "another-agent"}
```

### DELETE /api/v1/puppet/{namespace}/{sessionId}/{agentName}/thread/participant — Remove participant

### DELETE /api/v1/puppet/{namespace}/{sessionId}/{agentName}/thread — Close thread

### DELETE /api/v1/puppet/{namespace}/{sessionId}/{agentName} — End agent runtime

---

## Registry

### GET /api/v1/registry — List all registry agents

Returns all agents available (local, marketplace, linked).

### GET /api/v1/registry/local/{agentName}/{agentVersion} — Inspect local agent
### GET /api/v1/registry/marketplace/{agentName}/{agentVersion} — Inspect marketplace agent
### GET /api/v1/registry/linked/{linkedServerName}/{agentName}/{agentVersion} — Inspect linked server agent

---

## Agent Rental & Payments

### POST /api/v1/agent-rental/reserve — Reserve rental agents
### GET /api/v1/agent-rental/wallet — Get wallet address
### GET /api/v1/agent-rental/catalog — Get available rental agents
### POST /api/v1/agent-rpc/rental-claim — Submit rental claim
### POST /api/v1/agent-rpc/x402 — Request x402 proxying
