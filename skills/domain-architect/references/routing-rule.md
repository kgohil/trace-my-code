# Routing rule for the root CLAUDE.md / claude.md

This single rule is what makes an agent read docs instead of crawling files. Paste it
into the repo's root agent-instructions file (under tool-selection / "when in doubt").

```md
- **Before changing an area, read its docs — don't crawl the codebase.** In order:
  the module's `ARCHITECTURE.md` / `CLAUDE.md` / `DATA_FLOW.md` for the pattern + flow +
  gotchas, `docs/DOMAIN.md` for the bounded context + ubiquitous language, and any
  `docs/adrs/*` that governs the area for the _why_. Open source files only for the
  specific symbol/signature the docs point you to. When you make a non-trivial or
  hard-to-reverse decision, record it with the domain-architect skill (a new ADR).
```

## Why this works (measured)

An agent restricted to this rule + the curated docs planned a real cross-module feature
with **0 source-file reads** and caught the implementation gotchas (notification gating,
fail-safe, the import trap) that graph extraction missed or got wrong. The docs are the
load-bearing layer; this rule points the agent at them first.
