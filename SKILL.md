---
name: domain-architect
description: >-
    Author and maintain a curated, Obsidian-compatible architecture + domain
    knowledge layer (DOMAIN.md, per-module ARCHITECTURE.md, and ADRs) so a coding
    agent can plan features and fixes from docs instead of crawling the codebase.
    Use this whenever you author or update a DOMAIN.md / ARCHITECTURE.md / DATA_FLOW.md
    / ADR, record or revisit an architecture decision, map a bounded context or
    business flow, set up the doc-freshness git hook, or when committed changes
    touched a documented area and its docs may now be stale — even if the user does
    not say "domain-architect" by name. Strongly prefer this over ad-hoc doc edits
    whenever architecture or domain documentation is being created or kept in sync
    with code. Triggers on: "update the architecture doc", "record this decision",
    "write an ADR", "map the domain", "document this module", "the docs are stale",
    "doc drift", "keep the docs in sync", "domain-architect review". NOT for: code
    type-design/DDD value objects (that's a separate concern), generating a graph,
    or general prose editing unrelated to architecture/domain docs.
license: MIT
metadata:
    author: vexton
    version: "0.1.0"
    phase: maintain
---

# Domain Architect

**Value:** Curated prose is the load-bearing context layer. Measured against
graph tools (graphify, Understand Anything, `/understand-domain`), hand-written
architecture docs + ADRs let an agent plan a real feature with **zero
source-file crawling** and catch the implementation gotchas that graph
extraction misses or gets wrong. This skill keeps that layer **accurate and
fresh** — the only thing that erodes its value is staleness.

## What this skill maintains (the "minimal setup")

1. **`docs/DOMAIN.md`** — bounded contexts, aggregates, ubiquitous language. The map.
2. **Per-module `ARCHITECTURE.md` / `CLAUDE.md` / `DATA_FLOW.md`** — patterns, flows,
   conditions, gotchas. The detail.
3. **`docs/adrs/*.md`** — the _why_ behind non-trivial decisions.
4. A **routing rule** in the repo's root `CLAUDE.md`/`claude.md` so the agent reads
   these before changing an area, instead of crawling files.

All four are plain Markdown, **Obsidian-vault compatible** (YAML frontmatter +
`[[wikilinks]]`) so `docs/` opens directly as a visual graph — no separate
graph tool needed. See `references/obsidian-format.md`.

## Mode A — author / maintain (human-invoked)

When asked to record a decision, map a context, or update a doc:

1. **Domain map / ADR:** copy the matching file from `templates/`. Fill it from the
   **code + schema**, not assumptions. Link related nodes with `[[wikilinks]]`
   (a context → its ADRs, an ADR → the files it governs).
2. **Ground every claim in code.** Cite `path/to/file.ts:NN`. If you can't point to
   the code, mark it `_TODO: confirm_` rather than inventing it.
3. **ADRs are decisions, not status.** Capture the _why_, the alternative rejected,
   and the consequence/gotcha future changes must respect.
4. Keep the root `CLAUDE.md` routing rule current (see `references/routing-rule.md`).

## Mode B — auto-update on drift (hook-invoked)

The pre-push hook (`hooks/doc-drift.sh`) runs once per push, finds files in
**documented areas** that changed, and invokes this skill to refresh the docs.
This mode **rewrites docs automatically** — so it MUST be grounded and bounded.
Follow `references/auto-update-contract.md` exactly. Summary:

1. **Input:** the hook passes the list of changed files + the docs that govern them
   (a module's `ARCHITECTURE.md`, ADRs referencing those paths, relevant `DOMAIN.md`
   sections).
2. **Read the actual diff/code first.** Never rewrite a doc without reading what
   changed. The whole failure mode of auto-docs is asserting without verifying.
3. **Edit only the stale sections.** Preserve everything still accurate verbatim.
   Do not regenerate whole files. A drift fix is a surgical edit, not a rewrite.
4. **Each changed claim must cite the code line it now reflects.** If you cannot
   ground a change in the diff, leave the section and flag it
   `<!-- domain-architect: review — could not verify -->` instead of guessing.
5. **Land as a visible commit** (`docs: auto-refresh architecture docs for <area>`)
   so the change is in git history and trivially revertable. Never amend silently.
6. **No-op cleanly.** If nothing material changed (formatting, internal-only), make
   no edit and exit 0.

## Guardrails (why this stays reliable)

- Curated, not extracted: the agent _writes_ the docs from code; it never trusts a
  generated graph as the source of truth (graphs are lossy copies of these docs).
- Grounded: every claim cites code; unverifiable changes are flagged, not invented.
- Bounded: surgical section edits, visible commits, pre-push (not per-commit).
- Reversible: the auto-update is one revertable commit, never an in-place silent overwrite.
