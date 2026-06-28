# Bootstrap (Mode 0) — generate the initial architecture trace

Goal: on a repo with no docs yet, produce a **first draft** of the whole knowledge
layer so the team isn't staring at a blank page. This is a draft for human curation,
not trusted output — ground what you can, flag the rest.

## Step 1 — get source material (cheap first)

- **If a prior code-graph/scan artifact exists** (any generated structural graph or
  index your repo happens to have): use it as a rough outline only. Such artifacts are
  lossy — they cluster files but don't encode the _why_, conditions, or gotchas — so
  treat it as a skeleton to flesh out from code, never as the trace itself.
- **Otherwise, lightweight scan** — do NOT read every file. Read: `README`, the package
  manifest(s), the top 2 levels of the dir tree, detected entry points (routes, CLI,
  jobs, `main`), the DB schema (Prisma/SQL/ORM models = the aggregates), and each
  top-level module/package dir name + its index file.

## Step 2 — emit the initial set

1. **`docs/DOMAIN.md`** (from `templates/domain-template.md`): one bounded context per
   coherent module group; list its aggregates (from the schema), modules, and the
   ubiquitous-language terms you can name from the code. Add the glossary.
2. **Per significant module: `<module>/ARCHITECTURE.md`** from
   `templates/architecture-template.md`. Fill every section, `_TODO: confirm_` what you
   can't verify — do not drop sections:
   - **Flow** — what happens, in what order, **under which conditions** (branches/gates),
     only as far as you can verify.
   - **Patterns & extension points** — the reusable shapes the module follows, each with a
     **canonical example** (`path › symbol`) and **how to add a new one**. This is what
     reuse-first (Mode C) reads; a module doc without it can't stop reinvention.
   - **Invariants & absences** — limits, defaults, **magic numbers cited to their source**,
     and what is _not_ enforced (no floor/cap, silent drops, defaults). The blind spots an
     agent will otherwise guess wrong about.
   - **External / out-of-repo** — prompt registries, feature flags, env-gated branches,
     3rd-party SDKs — named **from the import/SDK**, not a comment.
   - **Gotchas** — including stale comments that could mislead.
   Don't fabricate flows — outline what's evident, `_TODO_` the rest.
3. **Seed ADRs** (`docs/adrs/`, from `templates/adr-template.md`) for the _obvious_
   decisions only — framework choice, deployment topology, persistence/ORM, any
   pattern that's clearly deliberate. Status `proposed`; fill Context/Decision from
   code; leave Consequences/gotchas as `_TODO: confirm_` for a human.
4. **Routing rule** into `CLAUDE.md`/`AGENTS.md` (see `references/routing-rule.md`).
5. **Wire the drift hook — on by default.** Don't leave the freshness loop as a manual
   step; turn it on now so the trace stays current without anyone remembering to. Pick by
   what the repo already has, default mode **rewrite** (auto-refresh + commit), always on a
   **non-`main` branch**:
   - **Repo has `.github/`** → copy `hooks/doc-drift.yml.example` to
     `.github/workflows/doc-drift.yml`. On each PR it refreshes the affected docs and
     commits them **to the PR branch** (reviewed in the PR; never pushed to `main`).
     Tell the user: add `ANTHROPIC_API_KEY` as a repo secret to enable rewrite — without
     it the workflow safely degrades to flag (comment-only).
   - **No CI** → wire the local pre-push hook (`hooks/doc-drift.sh`) via lefthook/husky/
     plain git (see `install.md`). Rewrite commits the refresh **to the current branch**
     and aborts the push so you review (`git show HEAD`) and push again.
   Either way, auto-commits land on the working/PR branch, never directly on `main` — that
   stays human/PR-gated. A user who wants warn-only sets `TRACE_MY_CODE_MODE=flag`.

## Step 3 — discipline

- **Ground or flag.** Every concrete claim cites code; everything inferred is marked
  `_TODO: confirm_`. Inventing a flow is worse than leaving a stub — a wrong doc is
  trusted and misleads.
- **Cite by symbol, not line.** `` `path/to/file.ext › symbolName()` `` (line optional as
  `~:NN`). Line numbers rot on the next edit; symbols survive.
- **Vendors from imports, never comments.** Name a 3rd-party system (prompt host, queue,
  payment, analytics) only from its `import`/SDK/config. A comment saying "Langfuse" next
  to a `@posthog/ai` import is the comment lying — cite the import and flag the stale comment.
- **Magic numbers carry their source.** Never write a bare threshold/limit; write the value
  _and_ where it's defined (`` `path › CONST` ``).
- **Apply the split heuristic from the start** (`references/doc-splitting.md`): emit an
  index + focused files, not three giant docs.
- **Obsidian format** throughout (frontmatter + `[[wikilinks]]`).
- **Tell the user it's a draft**, then curate **worst-first** with `trace-eval` (run
  `bash hooks/trace-eval.sh` — its _what to curate_ worklist ranks the weak docs and names the exact
  criterion each is missing; `--gaps` lists significant dirs still to bootstrap). The measured value
  of curated docs comes _after_ a human verifies them.

## Scope control

On a large monorepo, bootstrap the **top-level contexts + the 3–5 highest-traffic
modules** first, not all 50 at once. Leave the rest as named-but-stub entries in
`DOMAIN.md` so coverage is visible and can be filled incrementally (the drift hook and
Mode A grow it over time).
