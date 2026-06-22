# Bootstrap (Mode 0) — generate the initial architecture trace

Goal: on a repo with no docs yet, produce a **first draft** of the whole knowledge
layer so the team isn't staring at a blank page. This is a draft for human curation,
not trusted output — ground what you can, flag the rest.

## Step 1 — get source material (cheap first)

- **If a knowledge/domain graph exists** (`.understand-anything/domain-graph.json`,
  `.understand-anything/knowledge-graph.json`, or `graphify-out/graph.json`): derive
  from it — it already clusters modules/flows. It's a lossy draft (it can't encode the
  _why_ or gotchas), but it's a fast skeleton. Treat it as a starting outline only.
- **Otherwise, lightweight scan** — do NOT read every file. Read: `README`, the package
  manifest(s), the top 2 levels of the dir tree, detected entry points (routes, CLI,
  jobs, `main`), the DB schema (Prisma/SQL/ORM models = the aggregates), and each
  top-level module/package dir name + its index file.

## Step 2 — emit the initial set

1. **`docs/DOMAIN.md`** (from `templates/domain-template.md`): one bounded context per
   coherent module group; list its aggregates (from the schema), modules, and the
   ubiquitous-language terms you can name from the code. Add the glossary.
2. **Per significant module: `<module>/ARCHITECTURE.md`** skeleton: purpose, key
   files/entry points, the main flow (only as far as you can verify), and a
   `## Gotchas` stub. Don't fabricate flows — outline what's evident, `_TODO_` the rest.
3. **Seed ADRs** (`docs/adrs/`, from `templates/adr-template.md`) for the _obvious_
   decisions only — framework choice, deployment topology, persistence/ORM, any
   pattern that's clearly deliberate. Status `proposed`; fill Context/Decision from
   code; leave Consequences/gotchas as `_TODO: confirm_` for a human.
4. **Routing rule** into `CLAUDE.md`/`AGENTS.md` (see `references/routing-rule.md`).

## Step 3 — discipline

- **Ground or flag.** Every concrete claim cites code (`path:NN`); everything inferred
  is marked `_TODO: confirm_`. Inventing a flow is worse than leaving a stub — a wrong
  doc is trusted and misleads.
- **Apply the split heuristic from the start** (`references/doc-splitting.md`): emit an
  index + focused files, not three giant docs.
- **Obsidian format** throughout (frontmatter + `[[wikilinks]]`).
- **Tell the user it's a draft** and point them at the `_TODO_` markers to curate. The
  measured value of curated docs comes _after_ a human verifies them.

## Scope control

On a large monorepo, bootstrap the **top-level contexts + the 3–5 highest-traffic
modules** first, not all 50 at once. Leave the rest as named-but-stub entries in
`DOMAIN.md` so coverage is visible and can be filled incrementally (the drift hook and
Mode A grow it over time).
