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
  and ADRs, grounded in `path:line` citations.
- **Always current** — a git hook or CI workflow detects code changes in a traced area and
  **flags** (default) or **auto-refreshes** (grounded, surgical, revertable) the docs.
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
  SKILL.md                      # bootstrap + author/maintain + drift modes
  templates/                    # Obsidian-ready DOMAIN.md + ADR templates
  hooks/doc-drift.sh            # freshness hook (git pre-push or CI)
  hooks/doc-drift.yml.example   # CI workflow variant
  references/                   # bootstrap · auto-update contract · doc-splitting ·
                                #   obsidian format · multi-repo · routing rule
  install.md
```

## Design stance

Curated, not extracted. Grounded, not asserted. Surgical, not regenerative. Reversible,
not silent. The skill _writes and maintains_ the trace from your code — it never treats a
generated graph as the source of truth.

## Inspiration

Inspired by Andrej Karpathy's idea of building a personal **knowledge graph as an
interlinked wiki** — using an LLM to compile raw material into navigable, backlinked
notes. `trace-my-code` applies that shape to a codebase: the trace is a wiki of the
domain flow + code patterns, kept current by an agent rather than hand-tended.

License: MIT.
