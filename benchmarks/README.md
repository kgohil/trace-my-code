# Benchmarks

Does the trace change agent behavior? Here's how it's measured — and the honest state of the numbers.

**The claim:** given a maintained map of what exists, an agent plans from fewer reads, reuses instead of reinventing, and doesn't over-build — without dropping safety. Measurable. This directory says how.

## The result — cold vs trace, across repos

Same model, same planning task; the only variable is whether the agent can read the trace. The probe scores the **planning / discovery phase**, where the crawl-vs-map gap lives: a fresh agent plans a feature (files to create/modify + the pattern to follow), once **cold** (forbidden from the trace, derive from source) and once **with** it. Each arm is a real `claude -p --output-format json` run — full telemetry: input/output tokens, cost, wall time, turns, plan correctness.

Five fresh tasks, two repos — a ~100k-line Next.js app and [honojs/hono](https://github.com/honojs/hono) (25k-line TS framework, trace bootstrapped on just the two areas the tasks touch):

| Repo | Task | input tok | output tok | cost $ | wall time | turns |
|---|---|--:|--:|--:|--:|--:|
| multi-tool-app | UUID generator | −60% | −61% | −32% | −53% | 9→2 |
| multi-tool-app | Base64 encoder/decoder | −70% | −62% | −57% | −67% | 10→2 |
| multi-tool-app | JWT decoder | −59% | −54% | −53% | −49% | 7→2 |
| Hono | rate-limit middleware | −65% | −54% | −33% | −59% | 6→3 |
| Hono | geo helper | −64% | −61% | −20% | −76% | 6→3 |
| **median (n=5)** | | **−64%** | **−61%** | **−33%** | **−59%** | **7→2** |

_Raw per-task telemetry (absolute input/output/cost/time/turns per arm): [`runs/2026-06-cross-repo.csv`](runs/2026-06-cross-repo.csv)._

**−64% input, −33% cost, −59% time** (medians). Cold opened ~5 files over 6–10 turns; trace opened 1–2 over 2–3. All five reached the **same correct plan** — both arms picked the right canonical example and (in Hono) the non-obvious registration mechanism (`package.json` `exports`, no barrel). In a **discoverable** repo the win is pure **efficiency**: finding the pattern ~3× cheaper, not a different answer.

Input drops −64% but **cost only −33%** — most of the cold arm's extra input is *cached* reads (billed cheap). Wall time (−59%) and files/turns are the un-discounted wins. All three reported, not just the token count — that gap is the honest shape of the saving.

**Opaque domain → the trace also buys correctness.** A private-repo run (domain-jargon feature): cold built a **new parallel gate** (9 files, 127,808 tok, 118s); trace **extended** the existing one (4 files, 112,226 tok, 94s); a map-only variant **hallucinated a vendor** (said Langfuse; the repo uses PostHog). Discoverable repos test efficiency, opaque domains test correctness — the trace wins both, by different mechanisms.

**Honest limits:** 1 run per task (the five-task spread, not error bars, is the variance); planning phase, not a full build; cost Δ is the noisiest column (−20…−57%, cache economics); every task had a **real reuse target** — the trace's home turf. Greenfield with nothing to reuse → the map saves reading, not reinventing.

## Measure your own trace: `trace-stats`

Not a harness — a daily read. The skill ships an effectiveness meter (the `/ctx-stats` analog). From any repo with a trace:

```
bash skills/trace-my-code/hooks/trace-stats.sh         # report
bash skills/trace-my-code/hooks/trace-stats.sh --json  # for CI
```

It prints coverage, **map compression** (trace vs codebase tokens), **citation health** (how many `path › symbol` citations still resolve), **freshness** (auto-refreshes + open `_TODO_` debt), an **A–F quality grade**, and a **context footprint** (area doc vs area code). It scores the *map*; the cold-vs-trace **savings** come from the A/B above. On the ~100k-line app:

| Metric | Value |
|---|---|
| Map compression | trace **41k tok** : codebase **2.28M tok** → **1 : 55** |
| Coverage | 11 / 28 significant dirs (39%) — the meaningful areas, not the generated bulk |
| Citation health | 237 citations, **98% resolve** (233/237) |
| Quality grade | **77 / 100 (C)** — structure solid, 58 `_TODO_`s left to curate |
| Context footprint | ~**3.7k** tok / area doc vs ~**81k** / area → **map ~22× smaller** (compression, *not* a per-task token bill — the measured agent delta is **−64% input / −33% cost / −59% time**, above) |

In that session an agent built, tested, and shipped a **new tool** reading **only** the trace to plan it — _"Phase 0 genuinely replaced crawling… the trace gave me everything"_ — passed 14/14 tests, and the pipeline caught a real type bug a blind crawl ships.

## What to measure (the metrics)

Per task, run the same agent twice — **cold** (no trace) vs **trace** (trace present, Mode C on) — and score the plan/diff:

| Metric | Definition | How |
|---|---|---|
| **Source files read** | distinct non-doc files opened to produce a correct plan | count tool calls / agent self-report |
| **Reuse rate** | % of pieces that reuse/extend existing code vs new | classify each piece against the ladder |
| **Over-build avoided** | added a lib/component a native/stdlib/existing thing covered? | yes/no per task |
| **LOC of the diff** | lines the change adds (the ponytail metric) | `git diff --stat` on the applied change |
| **Citation accuracy** | cited symbols exist; lines (if given) resolve | grep each citation |
| **Safety floor kept** | validation / error-handling / authz / a11y retained | adversarial check, separate tier |
| **Tokens / cost / time** | from the agent's API telemetry | runner logs |

Reuse rate + over-build are the trace-specific signals; LOC/tokens/cost/time make it comparable to other "write less code" skills; safety floor scores on its **own adversarial tier**, so "less code" can never be bought by cutting a guard (the failure mode a naive "one-liner" prompt hits).

## Standard benchmarks you can run against

1. **SWE-bench / SWE-bench Verified** (external gold standard). Real GitHub issues, agent patches them, harness runs the repo's tests. Hypothesis: with the trace present, resolve rate rises and files-opened-per-task falls. Heaviest and most credible; needs the SWE-bench harness + real API spend. Use SWE-bench Lite for a cheaper signal.
2. **ponytail-style agentic git-diff harness** (portable, mid-cost). Pick a real OSS repo (ponytail uses [`fastapi/full-stack-fastapi-template`](https://github.com/fastapi/full-stack-fastapi-template)), write N feature tickets, run the agent with/without the skill, score the `git diff` on LOC + correctness + the safety tier, n≥4 for variance. See ponytail's [`benchmarks/agentic/`](https://github.com/DietrichGebert/ponytail/tree/main/benchmarks/agentic). trace-my-code adds the **files-read** and **reuse-rate** metrics.
3. **Context-efficiency probe** (cheapest, trace-native). One feature-planning task, cold vs trace, score files-read + plan correctness + citation accuracy. This produced the result above — one sub-agent per arm, fast but n=1 per task.

Pick by budget: probe for a quick check, agentic harness for a defensible blog number, SWE-bench for an external yardstick.

## Tasks

Seed task set in [`tasks.md`](tasks.md): **build** tasks (each with a known "right" reuse target — the over-build traps) and **explain** tasks (score the flow + citation accuracy). Add your repo's own; the trap is only a trap if the repo really has the thing to reuse.

## Reproduce the probe

No runner committed yet (contributions welcome — port ponytail's `agentic/run.py` shape). By hand:

1. In a repo **with** a bootstrapped trace, give a fresh agent a feature task, Mode C (`references/reuse-first.md`). Record: files read, ladder rung per piece, reuse/extend/new decision, citations, safety guards.
2. In the **same** repo, same task, but forbid reading `docs/`/`ARCHITECTURE.md` (cold arm). Record the same.
3. Verify the trace arm's citations against source (grep each `path › symbol`).
4. Diff the two: files read, reuse decision, over-build, safety.

The gap between the arms is the value of the trace.
