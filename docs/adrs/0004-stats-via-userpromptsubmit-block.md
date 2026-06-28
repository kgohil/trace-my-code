---
type: adr
id: ADR-0004
title: /trace-stats returns via a blocked prompt (zero model tokens)
status: proposed
date: 2026-06-28
deciders: []
governs: [skills/trace-my-code/hooks/trace-stats-command.sh, skills/trace-my-code/hooks/reuse-first-hooks.json]
tags: [adr]
---

# ADR-0004: `/trace-stats` returns via a blocked prompt (zero model tokens)

> Related: [[DOMAIN]] · [[ARCHITECTURE|hooks ARCHITECTURE]]

## Context

The trace-eval report is deterministic bash output — running it through the model would
spend tokens to relay text the model didn't compute, and risk it paraphrasing the numbers.
A slash command that shows a report should cost nothing and show the report verbatim.

## Decision

`/trace-stats` is a `UserPromptSubmit` hook (`trace-stats-command.sh`, registered in
`reuse-first-hooks.json`). On a `/trace-stats` prefix it runs `trace-eval.sh`, JSON-escapes
the output, and returns `{"decision":"block","reason":<output>}` — the host shows the reason
to the user and the prompt never reaches the model (the `/caveman-stats` pattern). Default
view is `--usage`; flags pass through. Any non-matching prompt exits 0 silently.

## Consequences

- **Positive:** the meter costs zero model tokens and shows exact figures; same mechanism is
  the reusable "prompt-prefix command" pattern.
- **Trade-offs:** output must be valid JSON-escaped or the block fails — the `sed` escape chain
  is fragile to new control chars. _TODO: confirm_ behaviour on very large reports / odd bytes.
- **Gotchas future changes must respect:** the prefix match is intentionally strict
  (`"prompt":"/trace-stats` start), so "what does /trace-stats do?" mid-sentence won't trigger.
  Self-gates on a trace existing, like the nudge.

## References

- Code: `skills/trace-my-code/hooks/trace-stats-command.sh`
- Registration: `skills/trace-my-code/hooks/reuse-first-hooks.json`
- Related: [[ARCHITECTURE]], [[DOMAIN]]
