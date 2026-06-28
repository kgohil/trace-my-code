# CLAUDE.md — trace-my-code

This repo is the **trace-my-code** agent skill + plugin. It dogfoods its own trace:
the trace under `docs/` + `skills/trace-my-code/hooks/ARCHITECTURE.md` describes this repo.

## Read the trace before changing an area — don't crawl the codebase

- **Before changing an area, read its docs first.** In order: the module's
  `ARCHITECTURE.md` for the pattern + flow + gotchas, `docs/DOMAIN.md` for the bounded
  context + ubiquitous language, and any `docs/adrs/*` that governs the area for the
  _why_. Open source files only for the specific symbol/signature the docs point you to.
  When you make a non-trivial or hard-to-reverse decision, record it with the
  trace-my-code skill (a new ADR).

- **Editing the hooks** (`skills/trace-my-code/hooks/`) → start at
  [hooks ARCHITECTURE](skills/trace-my-code/hooks/ARCHITECTURE.md). Honor:
  citation parser is duplicated across `doc-drift.sh` + `trace-eval.sh`
  (ADR-0001); pure bash + git, no deps (ADR-0003); drift `exit 1` is load-bearing (ADR-0002).

- **Editing the skill behavior** (Modes, ladder, guardrails) → `skills/trace-my-code/SKILL.md`
  and `skills/trace-my-code/references/*` are the source of truth, not this file.

## Self-test after touching a hook

`shellcheck` runs in CI on every `*.sh`; run it locally too. Verify the meter still parses:
`bash skills/trace-my-code/hooks/trace-eval.sh` from the repo root.
