---
name: trace-my-code
description: >-
    Build and maintain a living trace of a codebase — the domain flow plus the
    underlying code structure and patterns — as curated Markdown that gives a
    coding agent the right, always-current context to develop features, follow
    existing patterns, and refactor safely without re-reading the whole repo.
    Use this whenever you map or document how a feature/flow works end to end,
    author or update a DOMAIN/ARCHITECTURE/DATA_FLOW doc or an ADR, record an
    architecture decision, onboard to or trace an unfamiliar area, link a service's
    docs to the services it talks to, or refresh docs after code changed — even if
    the user does not say "trace-my-code" by name. Strongly prefer this over ad-hoc
    doc edits or crawling files blind whenever you need to understand or document how
    the system is built. Triggers on: "trace this flow", "how does X work end to end",
    "map the codebase", "document this module", "write an ADR", "record this decision",
    "the docs are stale", "keep docs in sync", "onboard me to this repo", "link this
    service to its dependencies". NOT for: in-code type/DDD value-object design, or
    prose unrelated to architecture/domain documentation.
license: MIT
metadata:
    author: kgohil
    version: "0.6.0"
    phase: understand
---

# Trace My Code

**What it is:** an agentic loop that keeps a **trace of your system** — the
**domain flow** (what happens, in what order, under which conditions) layered over
the **code structure and patterns** (where it lives, how it's built, why) — as
curated, navigable Markdown. The trace is the context a coding agent reads instead
of re-deriving the system from raw files on every task.

Inspired by [Andrej Karpathy's "LLM Wiki" idea](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
— an LLM-compiled, interlinked **knowledge-graph wiki** kept current by an agent —
applied here to a codebase instead of a research corpus.

**Why it pays off:**

- **Feature development** — an agent plans a change from the trace (flow + files +
  gotchas) in a couple of reads instead of crawling dozens of files and guessing.
- **Pattern adherence** — the trace records established patterns and the _why_ (ADRs),
  so new code follows them instead of inventing a parallel approach.
- **Refactor / restructure** — knowing the real end-to-end flow and its invariants up
  front makes large refactors safe; you change with the contract in view.
- **Always current** — a drift check (git hook or CI) flags or refreshes the trace
  when the code it describes changes, so it never quietly rots into a lie.

## The trace (what gets written)

1. **`docs/DOMAIN.md`** — the map: domains / bounded contexts, the aggregates and
   ubiquitous language, and how contexts connect.
2. **Per-area `ARCHITECTURE.md` / `DATA_FLOW.md`** (next to the code, from
   `templates/architecture-template.md`) — the flow, the **patterns & extension points**
   (the canonical example to copy + where to plug a new one in), the **invariants &
   absences** (limits, defaults, magic numbers, and what is _not_ enforced), the
   **external / out-of-repo** anchors, and the gotchas — with **symbol-anchored**
   citations.
3. **`docs/adrs/*.md`** — the _why_ behind non-trivial decisions.
4. A **routing rule** in the repo's `CLAUDE.md` / `AGENTS.md` telling agents to read
   the trace before touching an area (`references/routing-rule.md`).

Everything is plain Markdown, **stored hierarchically to mirror the codebase** and
**Obsidian-vault compatible** (YAML frontmatter + `[[wikilinks]]`), so `docs/` opens
as a visual, linked map — index -> context -> area -> decision. As the trace grows,
split oversized files behind an index (`references/doc-splitting.md`).

## Multi-repo / microservices

A trace is per-repo, but flows cross service boundaries. Each repo keeps its own trace
rooted at `docs/DOMAIN.md`; when service A calls service B, A's doc carries an **anchor
link to B's root trace doc** — a relative path when the repos sit side by side locally
(e.g. `[[../service-b/docs/DOMAIN.md]]`), or a URL otherwise. Following those anchors
lets an agent walk an **end-to-end cross-service flow** when the repos are checked out
together: no central index, just links between roots. See `references/multi-repo.md`.

## Modes

- **Mode 0 — bootstrap** (`references/bootstrap.md`): on a fresh repo, generate the
  initial trace (DOMAIN.md + per-area ARCHITECTURE.md skeletons + seed ADRs), grounded
  in code with `_TODO: confirm_` on anything unverified. A draft to curate — it kills
  the blank page.
- **Mode A — author / maintain**: write or update a doc/ADR from the **code + schema**,
  cite `path:line`, link related nodes with `[[wikilinks]]`. Capture the _why_ in ADRs.
- **Mode B — auto-update on drift** (`references/auto-update-contract.md`): **bootstrap
  wires this on by default** (CI workflow if the repo has `.github/`, else a local pre-push
  hook). It finds **code** changes in a traced area and **rewrites** the affected docs —
  grounded, surgical — committing to the **working/PR branch** (PR branch in CI, current
  branch locally), **never directly to `main`**. Degrades to **flag** (warn-only) if no
  Claude credential is available, or set `TRACE_MY_CODE_MODE=flag` to opt out of auto-commits.
- **Mode C — reuse-first development** (`references/reuse-first.md`): before writing any
  new code, consult the trace, then climb the reuse ladder — **YAGNI → reuse → extend →
  stdlib → native → installed dep → one line → (only then) minimum new** — while holding
  the **safety floor** (validation, error handling, security, accessibility, and anything
  explicitly requested are never cut). This is the payoff mode — it's what stops an agent
  reinventing a helper/component/flow the repo already has, or over-building what a native
  feature already does.

## The Iron Law (Mode C)

```
NO NEW CODE WITHOUT A REUSE INVESTIGATION FIRST
```

A coding agent's default is to reach for a blank file. Before creating a new file,
helper, component, hook, or abstraction, you MUST first read the trace and the closest
existing implementation, climb the reuse ladder, and justify _why reuse/extend doesn't
fit_. "I didn't find it in one grep" is not an investigation. The ladder cuts code, never
correctness — the safety floor is non-negotiable. Inspired by the "lazy senior dev" ladder
+ safety floor from [ponytail](https://github.com/DietrichGebert/ponytail) (MIT). See
`references/reuse-first.md` for the gated phases, the ladder, and the red flags that mean STOP.

## Guardrails (why the trace stays trustworthy)

- **Curated, not extracted.** The agent _writes_ the trace from code; it never trusts an
  auto-generated graph as the source of truth.
- **Grounded, not asserted.** Every claim cites code; unverifiable changes are flagged
  for review, not invented. **Name a 3rd-party system only from its import/SDK/config**
  (e.g. `@posthog/ai`), never from a code comment or a guess — comments rot and mislead.
- **Cite by symbol, not by line.** Use `` `path/to/file.ext › symbolName()` `` — a raw
  `:line` rots on every edit above it. A line number, if given, is a hint (`~:NN`); the
  agent locates by symbol and **confirms it before editing**. The drift hook checks cited
  symbols still exist.
- **Surgical + reversible.** Drift fixes edit only stale sections and land as one
  revertable commit — never a silent whole-file rewrite.
- **Hierarchical + linked.** Files mirror the code tree and link across areas (and across
  repos), so context stays navigable as the system grows.
