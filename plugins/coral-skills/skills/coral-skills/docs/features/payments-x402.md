# Payments: x402 status

Scope of the experimental x402 implementation in public Coral Server.

Source: https://docs.coralos.ai/features/payments-x402

Public Coral Server 1.4.0 contains x402 types, wallet configuration, and an agent RPC endpoint. This is not a documented, complete paid-resource workflow: agent resource grants are not populated by the current session agent implementation. Configuring a wallet alone does not provide an end-to-end resource purchasing flow.

With no wallet configured, the server installs a blank x402 service. Applications should not infer payment support from the presence of `X402BudgetedResource`, `PaymentConfig`, or `/api/v1/agent-rpc/x402` in the source/schema.

For working local usage accounting, use [session budgets and agent claims](../concepts/payments.md). These are separate from HTTP 402 negotiation, on-chain escrow, and remote agent rental.

If you develop the experimental integration, validate the wallet selection, resource-grant population, payment response, and settlement behavior in the specific server build you deploy. This page makes no claim that the historical remote rental routes are available.
