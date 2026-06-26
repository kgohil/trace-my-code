# Benchmarks

How to measure whether the trace actually changes agent behavior — and the honest
state of the numbers so far.

trace-my-code makes one claim: **given a maintained map of what exists, an agent plans
from fewer reads, reuses instead of reinventing, and doesn't over-build — without dropping
safety.** That is measurable. This directory says how.

## What to measure (the metrics)

Per task, run the same agent twice — **cold** (no trace) vs **trace** (trace present, Mode C
on) — and score the plan/diff it produces:

| Metric | Definition | How |
|---|---|---|
| **Source files read** | distinct non-doc files opened to produce a correct plan | count tool calls / agent self-report |
| **Reuse rate** | % of pieces that reuse/extend existing code vs new | classify each piece against the ladder |
| **Over-build avoided** | added a lib/component a native/stdlib/existing thing covered? | yes/no per task |
| **LOC of the diff** | lines the change adds (the ponytail metric) | `git diff --stat` on the applied change |
| **Citation accuracy** | cited symbols exist; lines (if given) resolve | grep each citation |
| **Safety floor kept** | validation / error-handling / authz / a11y retained | adversarial check, separate tier |
| **Tokens / cost / time** | from the agent's API telemetry | runner logs |

Reuse rate + over-build are the trace-my-code-specific signals; LOC/tokens/cost/time make it
comparable to other "write less code" skills; safety floor is scored on its **own adversarial
tier** so "less code" can never be bought by cutting a guard (the failure mode a naive
"one-liner" prompt hits).

## Standard benchmarks you can run against

1. **SWE-bench / SWE-bench Verified** (the external gold standard). Real GitHub issues, agent
   patches them, harness runs the repo's tests. Hypothesis: with the trace present for the
   target repo, resolve rate rises and files-opened-per-task falls. Heaviest and most credible;
   needs the SWE-bench harness + meaningful API spend. Use a fixed subset (e.g. SWE-bench Lite)
   for a cheaper signal.
2. **ponytail-style agentic git-diff harness** (portable, mid-cost). Pick a real OSS repo
   (ponytail uses [`fastapi/full-stack-fastapi-template`](https://github.com/fastapi/full-stack-fastapi-template)),
   write N feature tickets, run the same agent with/without the skill, score the resulting
   `git diff` on LOC + correctness + the safety tier, n≥4 for variance. See ponytail's
   [`benchmarks/agentic/`](https://github.com/DietrichGebert/ponytail/tree/main/benchmarks/agentic)
   as a reference runner. trace-my-code adds the **files-read** and **reuse-rate** metrics on top.
3. **Context-efficiency probe** (cheapest, trace-my-code-native). One feature-planning task,
   cold vs trace, score files-read + plan correctness + citation accuracy. This is what produced
   the early signal below; it's a single sub-agent per arm, so it's fast but n=1.

Pick by budget: probe for a quick check, agentic harness for a defensible blog number,
SWE-bench when you need an external yardstick.

## Tasks

The seed task set is in [`tasks.md`](tasks.md): a mix of **build** tasks (each with a known
"right" reuse target in a real repo — the over-build traps) and **explain** tasks (score the
flow + citation accuracy). Add your repo's own tasks; the trap is only a trap if the repo
really has the thing to reuse.

## Measure it in one command: `trace-stats`

You don't need a full harness for a daily read — the skill ships an effectiveness meter, the
`/ctx-stats` analog. From any repo with a trace:

```
bash skills/trace-my-code/hooks/trace-stats.sh         # report
bash skills/trace-my-code/hooks/trace-stats.sh --json  # for CI
```

It prints coverage, **map compression** (trace tokens vs codebase tokens), **citation health**
(how many `path › symbol` citations still resolve), **freshness** (drift-hook auto-refreshes +
open `_TODO_` debt), a claude-md-style **A–F quality grade**, and **estimated tokens saved per
task** — turning "is the trace any good?" into a number you watch move toward A as you curate.

## Real result: a full feature session

Run on a ~100k-line Next.js multi-tool app — bootstrapped trace, one working session that added
two tools, repaired a red test suite, ran SEO, and upgraded a scaffolding command, **every task
planned from the trace**. `trace-stats` on that repo:

| Metric | Value |
|---|---|
| Map compression | trace **41k tok** : codebase **2.28M tok** → **1 : 55** |
| Coverage | 11 / 28 significant dirs (39%) — the meaningful areas, not the generated bulk |
| Citation health | 237 citations, **92% resolve** |
| Quality grade | **75 / 100 (C)** — structure solid, 58 `_TODO_`s left to curate |
| Map vs area code | ~**3.7k** tok / area doc vs ~**81k** / area → **map ~22× smaller** (compression — *not* a per-task token bill; the measured agent delta is −15%, see the A/B) |

The near-controlled point inside that session: an agent built, tested, and shipped a **new tool**
on a trace-driven pipeline, reading **only** the trace in its planning phase. Its own words:
_"Phase 0 genuinely replaced crawling… the trace docs gave me everything."_ It passed 14/14
tests and the pipeline caught a real type bug — the kind a blind crawl ships.

## Controlled A/B — cold vs trace (n=1)

Same model, same planning task — _"plan adding a UUID Generator tool"_ — on the **same repo as the
real result above**, with vs without the trace:

| Arm | Files read | Agent tokens | Wall time | Plan |
|---|--:|--:|--:|:--|
| Cold (no trace) | 17 | 99,402 | 70s | correct — crawled 17 files to re-derive the two-tier pattern |
| Trace + reuse-first | **4** | **84,148** | **38s** | correct — read the trace, same plan |
| Δ | **−76%** | **−15%** | **−45%** | identical plan (copy `password-generator`; 4 new, 3 modified) |

Both arms reached the same correct plan, so here the win is **pure efficiency** — the trace agent
read a quarter of the files and finished in half the time for the same answer. The trace doesn't
make a well-structured repo's pattern *more* discoverable; it makes discovering it far cheaper.

The token column is **−15% total**, much smaller than the −76% files — because the agent's total
is mostly arm-independent: a large fixed input (system prompt + tool schemas) plus a ~constant
output (the plan). The trace cuts the **variable input** (files read); that delta is real but
diluted in the total. The harness reports only total `subagent_tokens`, so **files read** is the
cleaner proxy for the context saving.

Where the domain is opaque, the trace also buys **correctness**. A separate private-repo run
(a domain-jargon feature) had the cold agent build a **new parallel gate** (9 files, 127,808
tokens, 118s) while the trace agent **extended** the existing one (4 files, 112,226 tokens, 94s) —
and a map-only version even **hallucinated a vendor** (said Langfuse; the repo uses PostHog) and
cited stale lines. The **discipline** fixes that: symbol-anchored citations, vendors named only
from the import, the reuse ladder. Map **and** discipline — and `trace-stats` scores both.

## Reproduce the probe

No runner is committed yet (contributions welcome — port ponytail's `agentic/run.py` shape).
To reproduce method (3) by hand:

1. In a repo **with** a bootstrapped trace, give a fresh agent a feature task and instruct it
   to follow Mode C (`references/reuse-first.md`). Record: source files read, the ladder rung
   per piece, reuse/extend/new decision, citations, safety guards.
2. In the **same** repo, give an identical fresh agent the same task but forbid reading
   `docs/`/`ARCHITECTURE.md` (cold arm). Record the same.
3. Verify the trace arm's citations against source (grep each `path › symbol`).
4. Diff the two: files read, reuse decision, over-build, safety.

The gap between the two arms is the value of the trace.
