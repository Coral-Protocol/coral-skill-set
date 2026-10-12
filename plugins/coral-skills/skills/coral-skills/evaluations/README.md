# Awareness Verification Scenarios

`awareness-scenarios.json` is a set of inputs and acceptance rubrics, not a model
runner or a runtime emulator. It covers planning and failure-prone public patterns.
No result is implied by checking in this file.

## Static checks

From the repository root:

```bash
python3 scripts/check_awareness.py
```

This checks fixture structure/coverage, local Markdown links, shell syntax, and
known misleading guidance regressions. It does not prove semantics, model
attention, source permissions, or actual Coral delivery. The repository has no
pre-existing test runner; the check uses only Python's standard library and Bash.

## Planning evaluation

For each `kind: planning` case, use a fresh coding-agent conversation with the
installed skill. Record the model/harness version, prompt, loaded skill commit,
raw response, and evaluator. Present the case input without the expected rubric.
Score each `expect` and `reject` separately: all expectations must be supported
and no rejected behavior may occur for a pass. Have a reviewer judge the actual
plan, not keyword presence. Repeat across the deployment's intended models and
record variation rather than implying one sample establishes reliability.

Also try the ordinary installation/first-use path and the README prompt. Verify
that information boundaries and the single-harness question appear before any
suggested executor org chart, without blocking a simple installation on a long
architecture questionnaire. A design with justified parallel executors must
remain possible.

## Runtime integration

Implement the public-pattern slice in a disposable authorized application and
Coral session using that runtime's actual schemas. Set explicit source versions,
subscriptions, freshness budgets, retry/reconciliation windows, and test deadlines.
Use a fake source fixture for repeatable changes, but real selected harnesses,
tool authorization, persistence, and Coral transport for integration claims.

Run all `kind: runtime` cases and save transport IDs, journal/inbox/outbox rows,
checkpoint positions, versioned evidence, acknowledgement/result records, denial
logs, and archive receipts. For quiet cases, observe through the configured
reconciliation window; silence without a completed scan is not a pass. For
restart cases, terminate and restart the relevant process, not just its function.
For mutation denial, test the actual available tools/environment. For archival,
prove failure prevents close and successful archival survives close.

Run the two-harness case once per real adapter, capturing the supported hook or
polling mechanism and busy-consumer latency. Do not count a mocked adapter as a
real harness. Preserve useful independent parallel execution as a separate
measurement, not a requirement for portable awareness.

Report one row per case: `case_id`, `skill_commit`, `server_commit_or_version`,
`harness_version`, `mode` (static/planning/runtime), `pass|fail|not_run`, evidence
location, and limitation. A static pass must never fill a planning/runtime result.
Do not put credentials, private data, or proprietary source in public evidence.
