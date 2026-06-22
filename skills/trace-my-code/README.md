# trace-my-code

An agent skill that keeps a **living trace of your codebase** — the **domain flow**
layered over the **code structure and patterns** — as curated Markdown, so a coding
agent always has the right, current context to build features, follow patterns, and
refactor safely without re-reading the whole repo.

## Why this exists

Coding agents waste most of their effort re-deriving how a system works from raw files,
and get it subtly wrong — missing the real flow, the established pattern, or the
invariant that makes a refactor safe. A **curated trace** fixes that: an agent reads the
flow + the files + the gotchas in a couple of docs and plans correctly. The catch is
that docs rot — so this skill makes the trace a **maintained loop**, not a one-off:
bootstrap it, keep it grounded in code, and auto-flag/refresh it when the code changes.

What it improves:

- **Feature development** — plan from the trace, not a blind crawl.
- **Pattern adherence** — new code follows the recorded patterns + the _why_ (ADRs).
- **Refactor / restructure** — change with the end-to-end flow and its invariants in view.
- **Always current** — drift detection keeps the trace honest as the code moves.

## What you get

- **Bootstrap** — on a fresh repo, generate the initial trace (`DOMAIN.md` + per-area
  `ARCHITECTURE.md` skeletons + seed ADRs), grounded in code with `_TODO` markers for
  anything unverified. A draft to curate — never a blank page.
- **Author / maintain** — write and keep `DOMAIN.md`, per-area `ARCHITECTURE.md`/`DATA_FLOW.md`,
  and ADRs, grounded in **symbol-anchored** citations.
- **Reuse-first development** — before writing new code, an iron-law'd, gated loop makes the
  agent read the trace's **patterns & extension points** and climb a reuse ladder (**YAGNI →
  reuse → extend → stdlib → native → installed dep → one line → minimum new**) instead of
  reinventing a helper or over-building what a native feature already does — while a
  **safety floor** keeps validation, error handling, security, and a11y off the chopping block.
- **Always current** — a git hook or CI workflow detects code changes in a traced area and
  **flags** (default) or **auto-refreshes** (grounded, surgical, revertable) the docs, and
  warns when a doc cites a symbol that's been renamed/removed.
- **Hierarchical + Obsidian-native** — docs mirror the code tree, use frontmatter +
  `[[wikilinks]]`, and **split** behind an index as they grow, so `docs/` opens as a visual,
  navigable map.
- **Multi-repo** — a service's trace links to the root trace of the services it calls, so an
  agent can walk an end-to-end flow across microservices checked out side by side.

## Install (any agent: Claude Code, Cursor, Codex, Copilot, …)

```bash
npx skillfish add kgohil/trace-my-code trace-my-code
# or
npx skills add kgohil/trace-my-code --skill trace-my-code
```

## Layout

```
trace-my-code/
  SKILL.md                      # bootstrap + author/maintain + drift + reuse-first modes
  templates/                    # Obsidian-ready DOMAIN.md + ARCHITECTURE.md + ADR templates
  hooks/doc-drift.sh            # freshness hook (git pre-push or CI) + citation check
  hooks/doc-drift.yml.example   # CI workflow variant
  references/                   # bootstrap · auto-update contract · reuse-first · doc-splitting ·
                                #   obsidian format · multi-repo · routing rule
  install.md
```

## View the graph

The trace is plain Markdown, but it's also a graph: open the repo's `docs/` as a vault in
[Obsidian](https://obsidian.md) (free, no plugins) and the `[[wikilinks]]` render as a
navigable graph — contexts ↔ ADRs ↔ modules — with a backlinks pane for "what depends on
this?". Multi-repo: open the parent folder of your sibling repos as one vault to get a
single graph spanning all services. Step-by-step: [`references/obsidian-format.md`](skills/trace-my-code/references/obsidian-format.md).

## Does it work?

Early signal on a real monorepo: the trace + reuse-first cut an agent's source-file crawl
roughly in half, made it **extend an existing function instead of writing a new one**, and
stopped it adding a library for something the platform does natively — safety guards kept.
Method, metrics, the standard benchmarks to run (SWE-bench, a ponytail-style git-diff
harness, the context-efficiency probe), and the honest n=1 results table:
[`../../benchmarks/`](../../benchmarks/).

## Design stance

Curated, not extracted. Grounded, not asserted. Surgical, not regenerative. Reversible,
not silent. The skill _writes and maintains_ the trace from your code — it never treats a
generated graph as the source of truth.

## Inspiration

Inspired by Andrej Karpathy's **["LLM Wiki"](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)**
(shared on X, Apr 2026) — using an LLM to *compile* raw material into a navigable,
backlinked, interlinked wiki instead of re-deriving it on every query. `trace-my-code`
applies that shape to a codebase: the trace is a wiki of the domain flow + code patterns,
kept current by an agent rather than hand-tended.

The reuse-first mode's decision ladder and safety floor are adapted from
**[ponytail](https://github.com/DietrichGebert/ponytail)** (MIT) — the "lazy senior dev"
who reuses before he writes and never cuts a safety guard. trace-my-code supplies the map
that makes its "already in this codebase? reuse it" rung reliable in a large repo. The
gated-investigation shape borrows from `superpowers:systematic-debugging`.

License: MIT.
