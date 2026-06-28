---
type: adr-index
title: Architecture Decision Records
updated: 2026-06-28
tags: [adr, index]
---

# Architecture Decision Records

> The _why_ layer. Each ADR records a deliberate decision and the constraints future
> changes must respect. Companion: [[DOMAIN]] · [[ARCHITECTURE|hooks ARCHITECTURE]].

Seed ADRs from bootstrap (status `proposed` — confirm Consequences with a human).

| ADR | Title | Governs |
| --- | --- | --- |
| [[0001-cite-by-symbol-not-line|ADR-0001]] | Cite by symbol, not line number | the citation format + drift/eval checks |
| [[0002-drift-hook-aborts-push|ADR-0002]] | Drift hook commits off-`main` and aborts the push | `doc-drift.sh` |
| [[0003-pure-bash-zero-dep-hooks|ADR-0003]] | Hooks are pure bash + git, zero runtime deps | `skills/trace-my-code/hooks/` |
| [[0004-stats-via-userpromptsubmit-block|ADR-0004]] | `/trace-stats` returns via a blocked prompt (zero model tokens) | `trace-stats-command.sh` |
