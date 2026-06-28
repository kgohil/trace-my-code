# Changelog

All notable changes to this project are documented here. Format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/); this project versions
the skill via `version:` in `skills/trace-my-code/SKILL.md`.

## [0.8.0] - 2026-06-26

### Added

- **`trace-eval` — effectiveness + curation meter** (`hooks/trace-eval.sh`, the `/ctx-stats` analog).
  Reports coverage, map compression, citation health, freshness, a context footprint, and a
  claude-md-style **A–F quality grade** over citation accuracy, currency, conciseness, **patterns
  coverage** (the reuse-first section that stops reinvention), and gotcha coverage. Plus a
  **what-to-curate worklist** — the weakest docs worst-first, each tagged with the criterion it's
  missing (assess-before-you-edit) — and **`--gaps`**, the undocumented-significant-dirs bootstrap
  list. `--json` for CI, `--citations` to list broken ones. Pure bash (3.2+), reads only.
- **`/trace-stats` slash command + `--usage` view** — a `UserPromptSubmit` hook
  (`hooks/trace-stats-command.sh`) runs the meter when you type `/trace-stats [flags]` and prints it
  inline, **zero model tokens** (the `/caveman-stats` pattern). Defaults to the new **`--usage`**
  view — what the trace saved you: activity (trace-doc reads / areas / sessions / drift, from local
  transcripts + git) plus modeled impact (the no-priors A/B multiplier). Self-gates on a real trace;
  pure bash.
- **Cross-repo benchmark.** `benchmarks/` now leads with a cold-vs-trace A/B over **5 planning
  tasks across 2 repos** (multi-tool-app + honojs/hono): median **−64% input / −33% cost / −59%
  time**, same correct plan; raw per-task telemetry in `benchmarks/runs/`. Plus measured
  `trace-eval` numbers from a ~100k-line app (1:55 compression, **98% citation accuracy**).

### Changed

- **SKILL.md** documents the effectiveness meter and the proven-on-a-real-repo benefits.
- **Authoring discipline** folds in `/claude-md-improver` + `revise-claude-md` learnings: an explicit
  **avoid-list** (don't restate the code, DOMAIN content, or generic advice — in SKILL Guardrails +
  the ARCHITECTURE template), a **structured Mode-A reflection** that routes each harvested learning to
  its doc section (pattern→Patterns, gotcha→Gotchas, invariant→Invariants, vendor→External), and a
  **report-before-edit** curation flow driven by `trace-eval`'s worklist (the `#`-key reflex applied
  to architecture docs). Adds a **caveman compression discipline** for doc prose — write dense (drop
  filler), but never compress away the precision (invariants/absences, branch conditions, magic numbers,
  citations): "compress the prose, not the precision."
- **benchmarks/README** swaps opaque private-project anecdotes for the `trace-eval` meter and the
  real-session numbers; keeps the controlled cold-vs-trace A/B (generalized).

## [0.7.0] - 2026-06-24

### Added

- **Reuse-first nudge, on by default.** The plugin now ships a `UserPromptSubmit` hook
  (`hooks/reuse-first-hooks.json` → `hooks/reuse-first-nudge.sh`, wired in both
  `.claude-plugin` and `.codex-plugin`) that re-states the reuse-first contract each turn —
  so it survives long sessions and compaction where a CLAUDE.md routing rule (read once)
  drifts. It's a soft reminder, not a hard gate. **Self-gating:** silent (zero tokens) in
  any repo without a trace; ~100 input tokens/turn where one exists. Opt out with
  `TRACE_MY_CODE_NUDGE=off`. Makes trace-my-code a whole package out of the box — the
  reuse-first behavior is active without a manual routing-rule step.

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
