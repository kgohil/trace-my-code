# Onboarding router — the entry point

When the skill is invoked **without a clear task** (a bare `/trace-my-code`, `/trace`, "set
this up", "where do I start", or first install), DON'T dump the modes and guess. **Derive the
repo's state, then route.** The state is the repo itself — nothing is stored; you read it fresh
each run (the agentic loop). This is what a first-time user (guide setup) and a returning user
(next steps) each need.

## Step 1 — read the state (one pass, cheap)

| Signal | How to read it | Means |
| --- | --- | --- |
| Trace exists? | `docs/DOMAIN.md` present, or any `**/ARCHITECTURE.md` | bootstrapped vs blank |
| Health + grade | `bash skills/trace-my-code/hooks/trace-eval.sh` (or `${CLAUDE_PLUGIN_ROOT}/...`) | grade, broken citations, open `_TODO_`s |
| Coverage gaps | `bash …/trace-eval.sh --gaps` | significant dirs still undocumented |
| Drift loop wired? | `.github/workflows/doc-drift.yml` exists, **or** `.git/hooks/pre-push` mentions `doc-drift` | self-refresh on vs off |
| Mode | `git config --get traceMyCode.mode` (else `flag`) | rewrite vs flag |
| Routing rule | root `CLAUDE.md`/`AGENTS.md` tells agents to read the trace first | agents pointed at the trace or not |

Run `trace-eval` once; it already computes grade, citations, `_TODO_`s, and (with `--gaps`) the
worklist. That single report **is** the returning-user dashboard.

## Step 2 — route

### A. First run — no trace (`docs/DOMAIN.md` absent AND no `ARCHITECTURE.md`)

Guide setup, in order, doing each step (don't just describe it):

1. **Bootstrap** (Mode 0, `references/bootstrap.md`) — generate `DOMAIN.md` + per-area
   `ARCHITECTURE.md` + seed ADRs, grounded, `_TODO: confirm_` on the unverified. Kills the blank page.
2. **Wire the loop** — this is the whole point; pick one (see `install.md` for the what/why):
   - **CI Action (recommended)** — refreshes the docs on every PR, no per-clone setup, shared by
     the whole team; needs `ANTHROPIC_API_KEY` as a repo secret. The agentic loop, hands-off.
   - **Local pre-push (fallback)** — same refresh at push time, works with no API key in `flag`
     mode; but per-clone, not shared. Use when you can't add a CI secret.
3. **Routing rule** — paste `references/routing-rule.md` into root `CLAUDE.md`/`AGENTS.md` so
   agents read the trace before crawling.
4. **Grade it** — run `trace-eval`; a fresh bootstrap lands ~C. Show the **what-to-curate**
   worklist and offer to start curating worst-first.

### B. Returning — a trace exists

Show the `trace-eval` report, then propose the **single highest-value next step** from the real
signals (don't list all of them — pick the top one):

- **Broken citations** (`--citations`) → fix them; the grounding metric is the first thing to protect.
- **Open `_TODO: confirm_`** → confirm worst-first per the what-to-curate worklist (the C→A path).
- **`--gaps` non-empty** → bootstrap the biggest undocumented dir (most code first).
- **Drift loop not wired** → wire it (recommend the CI Action) so it stops rotting silently.
- **Routing rule missing** → add it, or the trace is written but never read.
- **All healthy** → switch to **Mode C (reuse-first)** for the actual coding task.

## Step 3 — confirm before doing the expensive thing

Bootstrap and rewrite-mode edits change files. State what you'll do in one line and proceed on
the obvious default; only ask when a fork genuinely changes the outcome (which area first, CI vs
local). Everything you write is a **draft to curate** — say so.
