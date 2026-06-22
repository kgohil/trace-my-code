---
type: architecture
title: <Module> — Architecture
tags: [architecture, <context>]
updated: YYYY-MM-DD
---

# <Module> — Architecture

> The detail layer for `<path/to/module>`. Read before changing it.
> Companion: [[../../docs/DOMAIN|DOMAIN]] (the map) · [[../../docs/adrs/README|ADRs]] (why).

One-paragraph: what this module does and which bounded context it belongs to.

## Flow

What happens, in what order, **under which conditions** — the branches, gates, and
fallbacks, not just the happy path. Cite by symbol.

- Step 1 — … (`path/to/file.ts › entrypoint()`)
- Step 2 — … condition/branch: when X → A, else B (`path › fn`)

## Patterns & extension points

The reusable shapes this module follows, so new work **extends** instead of reinventing.
For each: name it, point at the **canonical example to copy**, and say **how to add a new one**.

- **<Pattern name>** — _what it is_. Canonical example: `` `path/to/file.ts › symbol` ``.
  To add a new <thing>: <the seam — which file/registry/array to plug into, what to implement>.
- **<Pattern name>** — …

<!-- This section powers reuse-first (Mode C). If you'd reach for a new file, the answer
     to "what do I extend?" must live here. -->

## Invariants & absences

What's guaranteed, what's bounded, and — critically — **what is NOT enforced** (the blind
spots an agent will otherwise assume). Cite each.

- **Invariant:** <X always holds> (`path › symbol`).
- **Limit / magic number:** `<value>` lives at `` `path › symbol` `` (always cite the source
  of a constant, never just state the number).
- **Absence:** <what is deliberately or accidentally _not_ validated/capped/deduped>; effect
  if violated (`path › symbol`). <!-- e.g. "no minimum count enforced; codes silently dropped" -->

## External / out-of-repo

Logic that does NOT live in this repo and is therefore invisible to a code search — name the
real system **from its import/SDK/config**, not from a comment.

- **<capability>** — managed in <real system> via `<@scope/sdk or client>`; entry:
  `` `path/to/client.ts › fn` ``. <!-- e.g. prompts → PostHog via @posthog/ai -->
- **Feature flags / env gates:** <flag/env> changes behavior at `path › symbol`.

## Gotchas

Non-obvious traps, stale-comment warnings, ordering constraints.

- <gotcha> (`path › symbol`).
