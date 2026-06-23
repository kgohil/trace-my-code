<h1 align="center">trace-my-code</h1>

<p align="center">
  <em>The senior who already read the codebase. Your agent reuses what's there instead of rebuilding it.</em>
</p>

<p align="center">
  <sub>An agent skill that keeps a living, navigable <strong>trace</strong> of your codebase — the domain flow over the code structure and patterns — and makes the agent <strong>read it and reuse before it writes</strong>. Works in Claude Code, Cursor, Codex, Copilot, and ~20 other agents.</sub>
</p>

<p align="center">
  <img src="assets/agentic-loop.jpg" width="900" alt="The trace-my-code agentic loop: every commit/merge auto-updates the trace via the drift hook; the trace is a live domain map (DOMAIN, ARCHITECTURE, patterns, ADRs); the agent reads the map to comprehend a domain-jargon request, analyze it, and reuse the pattern; it ships the right implementation (extend, not reinvent), which feeds the next commit. Measured: -56% files read, -12% tokens, -20% time.">
</p>

<p align="center"><sub>Set it up once. Every commit keeps the domain map current; every feature request reads it. Quality and accuracy up, tokens and time down.</sub></p>

---

You ask the agent to add a CSV export. It writes a new export module, pulls in a CSV library, and hand-rolls a date picker — none of which it needed, because the repo already has an export pattern, the platform has `<input type="date">`, and a one-line join covers the CSV. It reinvented because it never knew what was already there.

trace-my-code gives the agent that knowledge as a maintained map, and a discipline that makes it look before it builds.

## Before / after

A real request, phrased the way a domain expert actually says it — full of jargon a fresh agent has to decode from scratch:

> **"Tighten the conviction gate so weak-lens cards don't reach compilation."**

**Without the trace** — the agent crawls source to learn what a "card", "lens", "conviction gate", and "compilation" even are, then **builds a new parallel gate** from scratch:
> read **9 files** · _"I'll add a new `conviction-guard.ts` module…"_ · confidence 4/5

**With the trace** — the agent reads the map, comprehends the jargon, finds the gate that already exists, and **extends it**:
> read **4 files** · _"Rung 2 — extend `completion-guard.ts › evaluateCompletionGuard`; the per-card `confidence` / `sentiment` / `lensMode` it needs are already persisted — no new column. Safety floor: explicit thresholds + one runnable test kept."_ · confidence 5/5

Same request, same model. The trace agent read **56% fewer files**, spent **12% fewer tokens**, finished **20% faster**, and — the part that matters — **reused the existing gate instead of bolting a second one beside it**. (Measured run, n=1; method in [`benchmarks/`](benchmarks/).)

Another shape of the same win — a CSV export request, where a cold agent over-builds:
> **Without:** _"add a `csv-stringify` dependency + a new `ExportService`"_ (a date-picker lib too).
> **With:** _"rung 4 — native `<input type=\"date\">`, no lib; rung 7 — one-line CSV join; extend the existing export procedure. Validation + auth-scoping kept."_

## How it works

Two pieces, and the second only works because of the first:

1. **The map** (persistent, kept current). Curated Markdown next to the code: `DOMAIN.md` (the contexts + language), per-module `ARCHITECTURE.md` (the flow, the **patterns & extension points**, the **invariants & absences**, the **external/out-of-repo** systems), and `ADRs` (the _why_). Symbol-anchored citations, Obsidian-vault compatible.
2. **The discipline** (reuse-first). Before writing code, the agent reads the map and climbs a ladder, stopping at the first rung that holds:

```
1. Does this need to exist at all?   → no: skip it (YAGNI)
2. Already in this codebase?         → reuse / extend it   (the map names the canonical example)
3. Standard library does it?         → use it
4. Native platform feature?          → use it
5. Installed dependency?             → use it
6. One line?                          → one line
7. Only then: the minimum new code that works
```

A **safety floor** is never on the chopping block: input validation, error handling that prevents data loss, security, accessibility, and anything explicitly requested. The ladder cuts code, never correctness.

The map keeps the trace from rotting (a drift hook flags or refreshes docs when the code they describe changes, and warns when a cited symbol is renamed). The discipline keeps the agent from reinventing. Together: the agent plans from a couple of reads, reuses what exists, and fixes shared code once.

## Early signal

Measured on a real monorepo (Next.js + Hono + Prisma), headless sub-agents, same model and task per pair, **n=1 per arm — illustrative, not a controlled benchmark** (the harness for rigorous numbers is in [`benchmarks/`](benchmarks/)):

The "tighten the conviction gate" request above, cold vs trace, as actually measured:

| Arm | Files read | Agent tokens | Wall time | Approach | Confidence |
|---|--:|--:|--:|---|:--:|
| No trace (cold) | 9 | 127,808 | 118s | **new** parallel gate | 4/5 |
| trace + reuse-first | **4** | **112,226** | **94s** | **extend** existing gate | **5/5** |
| **Δ** | **−56%** | **−12%** | **−20%** | reuse, not reinvent | +1 |

Across other tasks the same pattern holds: an earlier map-only version still mis-cited lines and **hallucinated a vendor** (said Langfuse; the repo uses PostHog); the current reuse-first version cites by symbol, finds callers a single grep misses, and chose a native feature over adding a library — without dropping a safety guard. Full method + how to reproduce: [`benchmarks/`](benchmarks/).

## Install

Any agent, via an agent-skills CLI (detects your installed agents and copies the skill into each):

```bash
npx skillfish add kgohil/trace-my-code trace-my-code
# or
npx skills add kgohil/trace-my-code --skill trace-my-code
```

Then, in a repo: ask your agent to **"bootstrap the trace"** (Mode 0) to seed `DOMAIN.md` + per-module `ARCHITECTURE.md` + seed ADRs from the code, wire the drift hook ([`skills/trace-my-code/install.md`](skills/trace-my-code/install.md)), and curate the `_TODO` markers. From then on the agent reads the trace before building, and the hook keeps it fresh.

## What you get

- **Bootstrap** a first-draft trace on a fresh repo — grounded in code, `_TODO`-flagged where unverified. Never a blank page.
- **Author / maintain** `DOMAIN.md`, per-module `ARCHITECTURE.md`/`DATA_FLOW.md`, and ADRs, with symbol-anchored citations.
- **Reuse-first development** — the iron-law'd ladder + safety floor above.
- **Always current** — drift hook (git pre-push or CI) flags or surgically refreshes docs, and checks citations still resolve.
- **Obsidian-native** — frontmatter + `[[wikilinks]]`, so `docs/` opens as a navigable graph (no extra tooling). [How to view it](skills/trace-my-code/references/obsidian-format.md).
- **Multi-repo** — a service's trace links to the traces of services it calls, so the agent can walk a flow across microservices.

Full skill reference: [`skills/trace-my-code/README.md`](skills/trace-my-code/README.md).

## Design stance

Curated, not extracted. Grounded, not asserted. Surgical, not regenerative. Reversible, not silent. The skill _writes and maintains_ the trace from your code; it never treats an auto-generated graph as the source of truth.

## Inspiration

- **[Andrej Karpathy's "LLM Wiki"](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)** — compile raw material into a navigable, interlinked wiki instead of re-deriving it every query. trace-my-code applies that shape to a codebase.
- **[ponytail](https://github.com/DietrichGebert/ponytail)** (MIT) — the "lazy senior dev" reuse ladder + safety floor. trace-my-code supplies the map that makes its "already in this codebase? reuse it" rung reliable in a large repo.
- **[superpowers:systematic-debugging](https://github.com/anthropics/claude-code)** — the gated-investigation shape (iron law, phases, red flags) the reuse-first mode borrows.

License: [MIT](LICENSE).
