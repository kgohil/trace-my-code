# Real-feature re-implementation A/B — argo-events #4018

The strongest validation in this repo: take a **real, recently-shipped feature**, check out the
commit **before** it, re-implement it cold-vs-trace, and score each arm against the **actual merged
PR** (ground truth). No synthetic task — real code, real reuse target, a known-right answer.

## Setup

- **Repo / feature:** [argoproj/argo-events#4018](https://github.com/argoproj/argo-events/pull/4018)
  — "GitHub App authentication for Sensor git triggers" (merged 2026-05-01). Adds a `githubApp`
  option to the git artifact and wires it into the git auth path, **mirroring the existing GitHub-App
  auth in EventSources**. A pure *reuse-not-reinvent* test.
- **Why this feature:** **post-training-cutoff** (2026-05) — the model can't have memorized the
  solution — on a **model-known** repo (argo is heavily in training). So the cold arm knows argo's
  *conventions* but not *this feature's code*. Classifies as **known-complex**.
- **Parent commit:** `32ee3c1d` (the commit before the PR). Both arms re-implement from there.
- **Trace:** minimal area trace bootstrapped at the parent commit (leakage-safe — it documents the
  existing extension point + the EventSource reuse target, never the new feature). Trace lived
  outside the worktree so it never polluted the captured diff.
- **Harness note:** the `claude -p` harness OAuth token expired mid-session → ran the two arms as
  **fresh in-session subagents** instead (live auth, isolated worktrees, no knowledge of the gold).
  Trade-off: total-token telemetry only (no input/output split), structural validation (no `go`
  toolchain available → no compile/test).
- **Validation:** diff each arm vs the gold PR — files touched, approach, reuse.

## Result

| Arm | files opened | tool calls | tokens (total) | wall time | plan correct? | reused right pattern? |
|---|--:|--:|--:|--:|:--:|:--:|
| **cold** (no trace) | **5** | 12 | **91,885** | **748s** | ✓ matches gold | ✓ `GithubAppCreds` + `ghinstallation` |
| **trace** | 8 (6 src + 2 trace docs) | 17 | 97,268 | 826s | ✓ matches gold | ✓ same |

Both arms changed the **same two core files** the humans did (`sensor_types.go`, `git.go`), reused
the existing `GithubAppCreds` type and the `ghinstallation` library, and produced the gold approach
(installation token → `BasicAuth{Username: "x-access-token"}`). Correctness: **tie, both right.**

## Finding — the trace did not help here (and that's the point)

On this **known, discoverable** repo the trace was **neutral-to-slightly-negative**: +6% tokens,
+10% time, more files opened, same answer. Two honest causes:

1. **Known + well-structured → cheap discovery.** The cold agent found the reuse target on its own
   in *fewer* files. There was no discovery cost for the trace to remove — the model already knows
   argo's layout and conventions.
2. **An imprecise trace citation cost a read.** The (quickly-authored) trace pointed at
   `github/start.go › getGithubAppAuthStrategy`; the real impl is in `appauth.go`. The trace arm
   read start.go per the trace, *then* found appauth.go. Citation accuracy is load-bearing — the
   exact thing `trace-eval` scores.

## Why this strengthens, not weakens, the case

It confirms the **two-segment thesis empirically and the benchmark's honesty** — the trace *loses*
this one:

- **known-complex** (this run): the model already knows the repo → trace ≈ neutral/negative.
- **unknown / opaque** (the private-repo run): the model is lost → cold built a **wrong parallel
  gate** while trace **extended** the right one, and a map-only variant hallucinated a vendor. There
  the trace buys **correctness**, not just speed.

The trace earns its keep where the agent has **no priors** (private/niche/opaque codebases) — not on
well-trodden public projects a model has effectively memorized. A usage tracker's modeled multiplier
must therefore be **segmented**, not a single number.

## Limits

n=1; structural validation only (no compile/test — no Go toolchain); total-token telemetry (in-session
subagents, not `claude -p`); one quickly-authored area trace (its imprecise citation is a confound —
a curated trace would not have it). Directional, honestly reported.
