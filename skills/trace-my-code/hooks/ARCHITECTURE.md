---
type: architecture
title: Hook machinery — Architecture
tags: [architecture, hooks]
updated: 2026-06-28
---

# Hook machinery — Architecture

> The detail layer for `skills/trace-my-code/hooks/`. Read before changing it.
> Companion: [[DOMAIN]] (the map) · [[README|ADRs]] (why).

The runtime of trace-my-code: four bash scripts + one hook-registration JSON. Two run
every turn (`UserPromptSubmit`), one runs on push/PR (drift), one is a read-only meter.
Pure bash 3.2 + git + awk/grep — no deps, no network ([[0003-pure-bash-zero-dep-hooks|ADR-0003]]).

## Flow

- **Every prompt** — the plugin registers two `UserPromptSubmit` hooks, in order
  (`reuse-first-hooks.json`): `trace-stats-command.sh` then `reuse-first-nudge.sh`.
- **`/trace-stats` typed** → `trace-stats-command.sh` matches the prompt prefix
  (`trace-stats-command.sh` case on `"prompt":"/trace-stats`), parses flags, runs
  `trace-eval.sh`, and **blocks** the prompt by emitting `{"decision":"block","reason":...}`
  — the meter output reaches the user, never the model (zero model tokens, [[0004-stats-via-userpromptsubmit-block|ADR-0004]]).
  Default flag when none given: `--usage` (`skills/trace-my-code/hooks/trace-stats-command.sh › args` fallback).
- **Any other prompt** → stats hook exits 0 silent; **nudge** fires: `reuse-first-nudge.sh`
  prints the reuse-ladder reminder to stdout (added to context, not blocking).
- **Both gate on a trace existing** (`docs/DOMAIN.md` or a 5-deep `ARCHITECTURE.md`) — no
  trace → silent exit. Same check copied in both scripts (`skills/trace-my-code/hooks/reuse-first-nudge.sh › has_trace`,
  `skills/trace-my-code/hooks/trace-stats-command.sh › has_trace`).
- **On push/PR** → `doc-drift.sh`: diff `merge-base..HEAD`, drop doc-only changes, map each
  remaining changed file to its governing doc(s), check cited symbols still resolve, then in
  rewrite mode shell out to the Claude CLI to refresh and commit; in flag mode just warn.

## Patterns & extension points

The reusable shapes here, so new work **extends** instead of reinventing.

- **Self-gating hook** — _every user-facing hook is silent in repos without a trace, so the
  plugin costs nothing where unused._ Canonical example: `` `skills/trace-my-code/hooks/reuse-first-nudge.sh › has_trace` ``
  (duplicated verbatim in `trace-stats-command.sh`). To add a new turn-level hook: copy the
  `has_trace` block, register it in `reuse-first-hooks.json` under `UserPromptSubmit`.
- **Prompt-prefix command via block** — _intercept a `/command`, run bash, return output to the
  user without spending model tokens._ Canonical example:
  `` `skills/trace-my-code/hooks/trace-stats-command.sh` `` (case-match on the `/...` prompt
  prefix → run → emit a `block` decision with the output as `reason`). To add a new slash
  command: clone this script, change the prefix and the inner command.
- **Citation resolver** — _parse a backtick path-arrow-symbol reference, drop the trailing
  `(...)`, grep the last identifier in the cited file._ Canonical example:
  `` `skills/trace-my-code/hooks/doc-drift.sh › check_citations` ``; the **same logic is
  duplicated** in the `trace-eval.sh` citation loop — change both together, or extract (see Gotchas).
- **Mode dispatch by env** — `TRACE_MY_CODE_MODE` (rewrite|flag) and `TRACE_MY_CODE_NUDGE`
  (on|off) read once at top; default is the safe option. New toggles follow the
  `${VAR:-default}` + `git config` fallback shape (`skills/trace-my-code/hooks/doc-drift.sh › MODE`).
- **`trace-eval` report sections** — each metric is an independent block computing a `_PCT`
  then printing a `bar`. To add a metric: compute it near the others, weight it into
  `skills/trace-my-code/hooks/trace-eval.sh › SCORE`, print a row.

## Invariants & absences

- **Invariant — drift only fires on CODE changes:** doc files (`ARCHITECTURE|CLAUDE|DATA_FLOW.md`
  and anything under `docs/`) are stripped from the trigger set so a doc PR can't flag its own
  docs (`doc-drift.sh`, the `grep -vE '/(ARCHITECTURE|CLAUDE|DATA_FLOW)\.md$|/docs/'`).
- **Invariant — auto-commits never land on `main`:** rewrite commits to the current/PR branch
  and **aborts the push with `exit 1`** so the doc commit is reviewed and pushed deliberately
  ([[0002-drift-hook-aborts-push|ADR-0002]], `doc-drift.sh` tail).
- **Default mode is `flag` (safe) in the script, `rewrite` in CI:** `skills/trace-my-code/hooks/doc-drift.sh › MODE`
  defaults to `flag`; the CI example (`doc-drift.yml.example`) sets `TRACE_MY_CODE_MODE: rewrite`.
  Don't assume one from the other.
- **Magic number — `trace-eval` token estimate:** `~4 chars/token` (`skills/trace-my-code/hooks/trace-eval.sh › toks`).
  All token/compression figures derive from this crude divisor, not a real tokenizer.
- **Magic number — significant dir threshold:** `≥3 source files` (`trace-eval.sh`, the
  `awk '$1>=3'`). Dirs under that are invisible to coverage + `--gaps`.
- **Magic numbers — modeled-impact multipliers:** `~4 files`, `210000` input tok, `28`s,
  `$0.77`/task are **hardcoded** in `skills/trace-my-code/hooks/trace-eval.sh › SHOW_USAGE` from the no-priors A/B; they
  are *modeled, not measured*, and 1 task/session is assumed. The benchmark-enrichment design
  intends to replace this blend.
- **Absence — `trace-eval` counts no bash/markdown as "code":** the `CODE` find-list is
  source extensions only (`.ts .py .go …`, `skills/trace-my-code/hooks/trace-eval.sh › CODE`). So in *this* repo the hooks
  (bash) don't register as significant dirs — coverage/compression read ~0 codebase. The meter
  under-measures shell/markdown projects.
- **Absence — quality grade can't see prose quality:** `SCORE` checks for the *presence* of
  `## Patterns` / `## Gotchas` headings (`skills/trace-my-code/hooks/trace-eval.sh › PATTERNS`, `GOTCHA`), not whether
  they're any good. An empty section with the right heading scores full marks.
- **Absence — citation check is grep-for-substring:** a symbol "resolves" if the file contains
  that identifier *anywhere* — a comment mention or a different symbol of the same name passes.
  No scoping (`skills/trace-my-code/hooks/doc-drift.sh › check_citations`, `trace-eval.sh` citation loop).

## External / out-of-repo

- **Claude CLI** — rewrite mode runs `"$CLAUDE_BIN" -p "$PROMPT" --allowedTools "Read,Edit,Bash,Grep,Glob"`
  (`doc-drift.sh`, after the `command -v` guard). Binary from `TRACE_MY_CODE_CLAUDE` (default
  `claude`); missing binary → degrade to flag, push continues.
- **Local Claude Code transcripts** — `skills/trace-my-code/hooks/trace-eval.sh › SHOW_USAGE` greps
  `$HOME/.claude/projects/<root-with-slashes-as-dashes>/*.jsonl` for `file_path` reads of the
  trace docs to count real activity. Reads private session logs; never writes.
- **Hook contract (host-defined)** — `UserPromptSubmit` block protocol
  (`{"decision":"block","reason":...}`) and `${CLAUDE_PLUGIN_ROOT}` are provided by the Claude
  Code / Codex host, not this repo. `reuse-first-hooks.json` is the registration surface.
- **CI variant** — `doc-drift.yml.example` references `.claude/skills/trace-my-code/hooks/doc-drift.sh`
  (the *installed-plugin* path). In **this source repo** the hook lives at
  `skills/trace-my-code/hooks/doc-drift.sh` — the dogfood workflow must use that path.

## Gotchas

- **Two copies of the citation resolver** drift apart: `skills/trace-my-code/hooks/doc-drift.sh › check_citations` and the
  `trace-eval.sh` citation loop parse the same `` `path › symbol` `` format with subtly different
  code. Fix a parsing bug in one → fix the other. Not yet extracted (intentional — two callers,
  no shared lib in bash).
- **`set -euo pipefail` vs no-match grep:** `skills/trace-my-code/hooks/doc-drift.sh › doc_for` wraps its `grep`/`awk`
  in `|| true` + process substitution precisely so a zero-match (no ADR has `governs:` yet)
  can't abort drift detection under `pipefail`. `trace-eval.sh` deliberately uses only
  `set -o pipefail` (no `-e`) so a missing-file grep can't kill the report mid-way.
- **`comma()` / `sed -e ':a'`** loops are written BSD+GNU-safe (no `\b`) — keep it portable;
  these run on macOS dev machines and Ubuntu CI both.
- **Stats default flag is `--usage`, not the health report:** typing `/trace-stats` shows usage;
  health/grade needs `/trace-stats --json` or running `bash trace-eval.sh` directly. Easy to
  expect the grade and get activity instead.
- **`areas_used` counts distinct `ARCHITECTURE.md` reads via a second grep** of the same files —
  the comment "no extra grep" refers to `reads`, not `areas_used` (`skills/trace-my-code/hooks/trace-eval.sh › SHOW_USAGE`).
