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

## Results so far (honest)

Run on a real monorepo (Next.js + Hono + Prisma + Trigger.dev), method (3) above, one task
per run, headless sub-agent, **n=1 per arm**. This is **early signal, not a controlled
benchmark** — single runs, one repo, self-reported counts. Treat directionally; the harness
above is what turns it into a defensible number.

| Arm | Source files read | Reinvented? | Over-built? | Citations | Safety floor |
|---|--:|:--:|:--:|:--:|:--:|
| Cold (no trace) | ~13–25 | — | — | — | — |
| Trace, v0.3 (map only) | ~13 | mixed | — | wrong line #s; **hallucinated vendor** (said Langfuse; real PostHog) | — |
| Trace + Mode C, v0.4 | **5** | **no** (extended `createCardsFromPlaybook`; found a 4th caller a grep missed) | — | symbol-anchored, accurate | — |
| Trace + ladder + floor, v0.5 | **8** | **no** | **no** (native `<input type="date">`, rejected a date-picker lib; one-line CSV, rejected a CSV lib) | symbol-anchored | **kept** (zod date validation, session-id scoping, a11y labels) |

Reading it: the map alone (v0.3) cut the crawl but still let the agent guess wrong (vendor
hallucination, stale lines). The discipline (v0.4) is what produced reuse-instead-of-reinvent
and accurate citations. The ladder + floor (v0.5) added over-build avoidance while keeping the
safety guards.

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
