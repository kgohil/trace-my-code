---
type: domain
title: trace-my-code — Domain Model
updated: 2026-06-28
tags: [domain, architecture]
---

# trace-my-code — Domain Model

> The meaning layer. Read before changing an area. Each context links to its
> module docs and the ADRs that govern it.
> Companion: per-module `ARCHITECTURE.md` (detail) · [[README|ADRs]] (why).

trace-my-code is an **agent skill + plugin**: it keeps a curated, self-refreshing
Markdown **trace** of a target codebase (domain map + per-area architecture + ADRs)
so a coding agent reads the map instead of re-crawling files. The product is itself
this repo — bash **hooks** (the runtime) + a Markdown **skill/instruction layer**
(what the agent does) + plugin **manifests** (how it ships) + **benchmarks** (the
evidence). This trace dogfoods the tool on its own code.

> **Self-referential caveat:** this DOMAIN describes the *trace-my-code product*, not
> a generic target repo. The skill itself, applied to some other codebase, would emit
> a DOMAIN about *that* codebase. Don't confuse the two layers.

---

## Bounded contexts

### Hook machinery — the runtime

- **Owns:** drift detection (Mode B), reuse-first nudge (Mode C), the `trace-eval`
  meter, the `/trace-stats` command, hook registration.
- **Modules:** `skills/trace-my-code/hooks/`
- **Language:** _drift_, _citation_, _self-gating_, _rewrite vs flag mode_ — see glossary.
- **Decisions:** [[0001-cite-by-symbol-not-line|ADR-0001]] · [[0002-drift-hook-aborts-push|ADR-0002]] · [[0003-pure-bash-zero-dep-hooks|ADR-0003]] · [[0004-stats-via-userpromptsubmit-block|ADR-0004]]
- **Detail:** [[ARCHITECTURE|hooks ARCHITECTURE]]

### Skill / instruction layer — what the agent does

- **Owns:** the four Modes, the guardrails, the doc templates the agent fills.
- **Modules:** `skills/trace-my-code/SKILL.md` · `references/` · `templates/`
- **Language:** _Mode 0/A/B/C_, _reuse ladder_, _safety floor_, _Iron Law_.
- **Detail:** read `SKILL.md` directly — this layer is prose the agent consumes, not
  code to re-document. `references/*` are the per-mode contracts; `templates/*` are the
  doc skeletons (`domain-template.md`, `architecture-template.md`, `adr-template.md`).
  _TODO: confirm_ whether this area warrants its own ARCHITECTURE.md or stays a stub.

### Packaging — how it ships

- **Owns:** plugin manifests for two hosts.
- **Modules:** `.claude-plugin/` (Claude Code marketplace + plugin) · `.codex-plugin/` (Codex)
- **Language:** the same skill ships to both; only the manifest shape differs.
- Both manifests point `hooks` at `skills/trace-my-code/hooks/reuse-first-hooks.json`
  (`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`). Version lives in both —
  keep in sync on release.

### Evidence — the benchmarks

- **Owns:** the cold-vs-trace measurements the README claims rest on.
- **Modules:** `benchmarks/README.md` · `benchmarks/tasks.md`
- **Language:** _no-priors / known-complex segment_, _multiplier_ — the `trace-eval --usage`
  modeled impact reads these numbers (hardcoded in `skills/trace-my-code/hooks/trace-eval.sh › SHOW_USAGE`).
  Active design: [[../superpowers/specs/2026-06-27-trace-benchmark-enrichment-design|benchmark-enrichment design]] (pre-implementation).

### Project CI — keeping the repo honest

- **Owns:** secret-scan (gitleaks), shellcheck on hooks, actionlint, release automation.
- **Modules:** `.github/workflows/ci.yml` · `.github/workflows/release.yml` · `.github/dependabot.yml`

---

## Cross-context relationships

- **Hook machinery → Skill layer:** `doc-drift.sh` (rewrite mode) shells out to the Claude
  CLI with a prompt telling it to invoke the skill in **Mode B** following
  `references/auto-update-contract.md`. The runtime triggers the agent; the agent edits docs.
- **Hook machinery → Skill layer:** `reuse-first-nudge.sh` re-states the **Mode C** contract;
  the full rules live in `references/reuse-first.md`.
- **`trace-eval` → any trace:** the meter reads `docs/` + `*ARCHITECTURE.md` of whatever repo
  it runs in (including this one) and grades them — it is the product's self-measurement.
- **Self-gate invariant:** both `reuse-first-nudge.sh` and `trace-stats-command.sh` stay silent
  unless a trace exists (`docs/DOMAIN.md` or a module `ARCHITECTURE.md`) — so installing the
  plugin costs zero tokens in untraced repos. Now that *this* repo has a trace, the nudge fires here.

## External services (cross-repo)

- **Anthropic Claude CLI** — `doc-drift.sh` rewrite mode invokes the `claude` binary
  (`TRACE_MY_CODE_CLAUDE`, default `claude`) with `--allowedTools "Read,Edit,Bash,Grep,Glob"`.
  The CI variant uses `ANTHROPIC_API_KEY` as a repo secret. No SDK import — it's a subprocess.

## Ubiquitous language — glossary

| Term | Means | Not to be confused with |
| --- | --- | --- |
| trace | the curated Markdown knowledge layer (DOMAIN + ARCHITECTURE + ADRs) | a stack trace |
| Mode 0/A/B/C | bootstrap / author-maintain / drift-update / reuse-first dev | — |
| drift | code in a documented area changed but its doc didn't | git drift |
| citation | a `` `path › symbol` `` anchored reference; line is an optional `~:NN` hint | a line-number reference |
| governs | ADR frontmatter listing code paths the decision constrains | — |
| reuse ladder | YAGNI→reuse→extend→stdlib→native→installed dep→one line→minimum new | the safety floor |
| safety floor | never-cut concerns: validation, error handling, security, accessibility | the reuse ladder |
| self-gating | a hook stays silent (zero tokens) in any repo without a trace | the on/off env switch |
| nudge | the per-turn `UserPromptSubmit` reuse-first reminder | the CLAUDE.md routing rule (read once) |
| rewrite / flag | drift mode: auto-refresh+commit vs warn-only | — |
