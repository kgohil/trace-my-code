# Install — trace-my-code

The skill itself works as soon as it's in a skills dir (`/trace-my-code`, or auto-invoked
by description).

> **You usually don't need this page.** Running **Mode 0 bootstrap** wires the freshness
> hook for you (CI workflow if the repo has `.github/`, else a local pre-push hook),
> defaulting to **rewrite** committing to the working/PR branch — never `main`. The steps
> below are the manual override: change the mode, pick a different wiring, or set it up
> without re-bootstrapping.

## 1. Pick a mode

```bash
git config traceMyCode.mode flag      # default: just flag drift (safe)
# or
git config traceMyCode.mode rewrite   # auto-refresh docs (needs the Claude CLI)
```

Or per-invocation: `TRACE_MY_CODE_MODE=rewrite`. Rewrite mode also needs the Claude CLI
on PATH (override with `TRACE_MY_CODE_CLAUDE=/path/to/claude`).

## 2a. Local git hook (default) — fires once per push

**lefthook** (`lefthook.yml`):

```yaml
pre-push:
    commands:
        doc-drift:
            run: .claude/skills/trace-my-code/hooks/doc-drift.sh
```

**husky:** add the line to `.husky/pre-push`.
**plain git:** `ln -s ../../.claude/skills/trace-my-code/hooks/doc-drift.sh .git/hooks/pre-push`
(or append the call if you already have a pre-push hook).

In rewrite mode the hook creates a `docs: auto-refresh …` commit and aborts the push —
review with `git show HEAD`, then push again so the doc commit is included.

## 2b. CI workflow (optional) — fires on PR/merge, no local setup

Copy `hooks/doc-drift.yml.example` to `.github/workflows/` (it runs the same script with
`TRACE_MY_CODE_MODE=rewrite` and commits the refresh to the PR branch — no re-push).
Requires a Claude API credential in CI secrets.

## 3. Add the routing rule

Paste the snippet from `references/routing-rule.md` into your root `CLAUDE.md`/`claude.md`.

## 4. (one-time) bootstrap the docs

Run the skill's **Mode 0 (bootstrap)** to generate the initial trace — `docs/DOMAIN.md`,
an `ARCHITECTURE.md` skeleton per significant module, and seed ADRs — from the codebase
(optionally seeded by any existing code-graph or scan artifact, if present). Just ask, e.g. _"bootstrap
the architecture docs for this repo"_. It produces a **draft**: review the `_TODO: confirm_`
markers and curate before trusting it.

After that, Mode A handles edits and the drift hook keeps everything fresh. As the docs
grow, the skill splits oversized files behind an index (see `references/doc-splitting.md`).

## 5. Measure effectiveness (any time)

Run the bundled meter — the `/ctx-stats` analog — to see whether the trace is earning its keep:

```bash
bash hooks/trace-eval.sh          # coverage, compression, citation health, A–F grade + what-to-curate worklist
bash hooks/trace-eval.sh --gaps   # significant dirs with no ARCHITECTURE.md (bootstrap next)
bash hooks/trace-eval.sh --json   # machine-readable, for CI
```

A fresh bootstrap grades around **C** (structure solid, `_TODO_`s open); working the meter's
**what-to-curate** worklist — confirming `_TODO_`s, adding missing Patterns sections, fixing broken
citations — is what moves it toward **A**. Watch the grade — it's the one number
that says whether the trace is an asset or rotting into a lie.
