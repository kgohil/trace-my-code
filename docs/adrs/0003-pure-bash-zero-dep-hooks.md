---
type: adr
id: ADR-0003
title: Hooks are pure bash + git, zero runtime deps
status: proposed
date: 2026-06-28
deciders: []
governs: [skills/trace-my-code/hooks]
tags: [adr]
---

# ADR-0003: Hooks are pure bash + git, zero runtime deps

> Related: [[DOMAIN]] · [[ARCHITECTURE|hooks ARCHITECTURE]]

## Context

The hooks run on every developer's machine and in CI, across macOS and Ubuntu, inside
arbitrary target repos. A Node/Python runtime requirement would make installation a
yak-shave and bar the plugin from repos in other languages.

## Decision

Every hook is `bash 3.2+` + `git` + `awk`/`grep`/`sed` only — no package manager, no
network, read-only except the deliberate drift commit. Portability is enforced: BSD+GNU-safe
sed (`skills/trace-my-code/hooks/trace-eval.sh › comma`, no `\b`), the token estimate is a
crude `wc -c`/4 (`skills/trace-my-code/hooks/trace-eval.sh › toks`) rather than a real
tokenizer dep. Shellcheck runs on every hook in
CI (`.github/workflows/ci.yml`).

## Consequences

- **Positive:** install = drop the plugin in; works in any repo regardless of language; trivial
  to audit (it's all readable shell).
- **Trade-offs:** no real tokenizer (token figures are estimates), no AST (citation checks are
  substring grep), and shared logic can't be a library — hence the duplicated citation parser
  ([[0001-cite-by-symbol-not-line|ADR-0001]]). bash 3.2 is the floor (macOS default), so no
  `mapfile` assumptions beyond what's guarded. _TODO: confirm_ bash 3.2 is the intended floor.
- **Gotchas future changes must respect:** don't reach for `jq`/`node`/`python` — match the
  existing awk/grep idiom. Keep sed BSD-safe.

## References

- Code: `skills/trace-my-code/hooks/`
- CI: `.github/workflows/ci.yml` (shellcheck)
- Related: [[ARCHITECTURE]], [[DOMAIN]]
