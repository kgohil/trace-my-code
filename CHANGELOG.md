# Changelog

All notable changes to this project are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this project versions
the skill via `version:` in `skills/trace-my-code/SKILL.md`.

## [0.6.0] - 2026-06-23

### Changed

- **Drift auto-update is now on by default.** Mode 0 bootstrap wires the freshness hook
  automatically — a CI workflow (`doc-drift.yml`) if the repo has `.github/`, otherwise a
  local pre-push hook — instead of leaving it as a manual `install.md` step. Default mode
  is now **rewrite** (auto-refresh + commit), committing to the **working/PR branch** (PR
  branch in CI, current branch locally), **never directly to `main`**. Degrades to **flag**
  (warn-only) when no Claude credential is present; set `TRACE_MY_CODE_MODE=flag` to opt out.
- The self-documenting loop is live after onboarding, not after a second manual setup.

## [0.5.0] - 2026-06-22

First tagged release. trace-my-code is a portable agent skill that keeps a living
**trace** of your codebase — the domain language, architecture, flow, and reuse
patterns — and makes a coding agent **understand what you mean and reuse what's
already there** before it writes code.

### Added

- **The trace (the map).** `DOMAIN.md` + per-module `ARCHITECTURE.md` + ADRs, in
  Obsidian-vault Markdown (frontmatter + `[[wikilinks]]`), with **symbol-anchored
  citations**. Templates for DOMAIN, ARCHITECTURE, and ADRs.
- **Mode 0 — bootstrap.** Generate a grounded first-draft trace on a fresh repo,
  `_TODO`-flagged where unverified.
- **Mode A — author / maintain.** Write and keep the trace grounded in code.
- **Mode B — drift auto-update.** `hooks/doc-drift.sh` (local git hook or CI) flags
  (default) or surgically rewrites stale docs, and runs a **citation-integrity check**
  that warns when a cited symbol is renamed or removed.
- **Mode C — reuse-first development.** An iron-law'd, gated loop (modeled on
  `superpowers:systematic-debugging`) with a 7-rung decision ladder and a **safety
  floor** (validation, error handling, security, a11y never cut), adapted from
  [ponytail](https://github.com/DietrichGebert/ponytail). Required `ARCHITECTURE.md`
  sections: **Patterns & extension points**, **Invariants & absences**,
  **External / out-of-repo**.
- **Multi-repo** anchor linking across services.
- **Docs + brand.** Value-forward README, otter mascot + agentic-loop diagram,
  `benchmarks/` (metrics, standard benchmarks to run, measured early-signal results),
  and a two-step setup callout.

### Measured (early signal, n=1 per arm)

On a real monorepo, same model and feature-request per pair, cold vs trace:
**−56% files read, −12% tokens, −20% wall time**, and reuse/extend instead of building
a parallel implementation. Method in [`benchmarks/`](benchmarks/).

### Inspiration

Andrej Karpathy's "LLM Wiki" idea; the ponytail reuse ladder + safety floor;
the `superpowers:systematic-debugging` gated-investigation shape.

[0.5.0]: https://github.com/kgohil/trace-my-code/releases/tag/v0.5.0
