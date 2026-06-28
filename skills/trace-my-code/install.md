# Install — trace-my-code

The skill works as soon as it's in a skills dir: `/trace` to onboard, `/trace-my-code` to
invoke directly, or it auto-triggers by description. **New here? just run `/trace`** — it reads
the repo's state and either guides first-run setup or shows your status + next step
(`references/onboarding.md`).

> **You usually don't need this page.** Running **Mode 0 bootstrap** (or `/trace` on a fresh
> repo) wires the freshness hook for you. The steps below are the manual override: change the
> mode, pick a different wiring, or set it up without re-bootstrapping.

## 1. Wire the freshness loop — the whole point

The trace is only worth keeping if it stays current. Pick **one** wiring. Both run the same
`doc-drift.sh`; both default to **rewrite** (auto-refresh the affected docs, commit to the
working/PR branch — **never `main`**) and degrade to **flag** (warn-only) with no Claude credential.

### Recommended — CI Action (fires on every PR, no local setup, team-shared)

_Refreshes the docs automatically on each PR for everyone, with nothing for teammates to
install — the hands-off agentic loop. Costs: one repo secret._

```bash
cp skills/trace-my-code/hooks/doc-drift.yml.example .github/workflows/doc-drift.yml
```

Then **add `ANTHROPIC_API_KEY` as a repo secret** (Settings → Secrets → Actions) to enable
rewrite; without it the workflow safely degrades to flag (warn-only). It commits the refresh to
the **PR branch** (reviewed in the PR, never pushed to `main`).

> The example references the installed-plugin path `.claude/skills/...`. If you're wiring it in
> **this source repo** (or the plugin lives elsewhere), fix the path in the workflow to point at
> the actual `doc-drift.sh`.

### Fallback — local pre-push hook (fires at push time, per-clone, no API key needed)

_Same refresh, but at `git push` and only on your machine — use when you can't add a CI secret.
Not shared: every clone re-wires._

**plain git** (`.git/hooks/pre-push`, then `chmod +x`):

```bash
#!/usr/bin/env bash
set -euo pipefail
root="$(git rev-parse --show-toplevel)"
exec "$root/skills/trace-my-code/hooks/doc-drift.sh" "$@"   # adjust path to where the hook lives
```

**lefthook** (`lefthook.yml`) / **husky** (`.husky/pre-push`): call the same `doc-drift.sh`.

In rewrite mode the hook creates a `docs: auto-refresh …` commit and **aborts the push** — review
with `git show HEAD`, then push again so the doc commit is included.

## 2. Pick a mode (optional — rewrite is the default)

```bash
git config traceMyCode.mode rewrite   # default: auto-refresh docs (needs the Claude CLI / API key)
git config traceMyCode.mode flag      # warn-only: just flag drift, never auto-commit
```

Or per-invocation: `TRACE_MY_CODE_MODE=flag`. Rewrite needs the Claude CLI on PATH for the local
hook (override with `TRACE_MY_CODE_CLAUDE=/path/to/claude`), or `ANTHROPIC_API_KEY` in CI.

## 3. Add the routing rule

Paste the snippet from `references/routing-rule.md` into your root `CLAUDE.md`/`AGENTS.md` so
agents read the trace before crawling. (`/trace` does this for you on first run.)

## 4. (one-time) bootstrap the docs

Run **Mode 0 (bootstrap)** — or just `/trace` on a fresh repo — to generate the initial trace
(`docs/DOMAIN.md`, an `ARCHITECTURE.md` per significant module, seed ADRs) from the codebase. It
produces a **draft**: review the `_TODO: confirm_` markers and curate before trusting it. After
that, Mode A handles edits and the drift loop keeps everything fresh; oversized files split behind
an index (`references/doc-splitting.md`).

## 5. Measure effectiveness (any time)

Type **`/trace-stats`** (discoverable command + zero-model-token hook) for the trace's **usage
stats** — what it saved you. Pass `--gaps` / `--citations` / `--json` for the health views. Or run
the meter directly:

```bash
bash skills/trace-my-code/hooks/trace-eval.sh          # coverage, compression, citation health, A–F grade + worklist
bash skills/trace-my-code/hooks/trace-eval.sh --gaps   # significant dirs with no ARCHITECTURE.md (bootstrap next)
bash skills/trace-my-code/hooks/trace-eval.sh --json   # machine-readable, for CI
```

A fresh bootstrap grades ~**C**; working the **what-to-curate** worklist moves it toward **A**.
The grade is the one number that says whether the trace is an asset or rotting into a lie.

## Troubleshooting — seeing duplicate `/trace-my-code` versions?

Claude Code caches plugins per version under `~/.claude/plugins/cache/<repo>/<plugin>/<version>/`
and **never auto-prunes** old ones, so after an update you can have e.g. `0.5.0` and `0.9.0` side
by side. To collapse to one:

```bash
/plugin marketplace update          # refresh the marketplace to the latest version
/plugin                             # inspect installed plugins / versions
# then remove stale cached versions (keep the newest):
rm -rf ~/.claude/plugins/cache/trace-my-code/trace-my-code/<old-version>
```

If you added the marketplace more than once (e.g. both a local clone and the GitHub URL), remove
the duplicate marketplace entry — same plugin name from two marketplaces shows as two plugins.
