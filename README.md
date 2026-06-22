# domain-architect

A small agent skill that keeps a codebase's **curated architecture + domain docs** accurate
and fresh, so a coding agent can plan features and fixes **from docs instead of crawling the
codebase** — and so humans get an Obsidian-visualizable knowledge map for free.

## Why this exists

Tested head-to-head on a real feature-planning task: hand-written architecture docs + ADRs
let an agent produce a correct senior plan with **zero source-file reads**, catching the
implementation gotchas that knowledge-graph tools (graphify, Understand Anything,
`/understand-domain`) **miss or get wrong** (graphs are lossy, structural, can't encode the
"why" or the traps). Curated prose is the load-bearing layer. Its only failure mode is going
**stale** — which is exactly what this skill prevents.

## What you get

- **Author/maintain** mode: write/keep `DOMAIN.md`, per-module `ARCHITECTURE.md`, and ADRs,
  grounded in code, in **Obsidian-vault format** (frontmatter + `[[wikilinks]]`) so `docs/`
  opens as a visual graph with no extra tooling.
- **Freshness hook**: a pre-push (or CI) hook that detects when committed changes touch a
  documented area and either **flags** the stale docs (default, safe) or **auto-refreshes**
  them (grounded surgical edits, landed as a visible, revertable commit).
- A one-line **routing rule** for your root `CLAUDE.md` that makes the agent read docs first.

## Layout

```
domain-architect/
  SKILL.md                      # the skill (author mode + auto-update mode)
  templates/                    # Obsidian-ready DOMAIN.md + ADR templates
  hooks/doc-drift.sh            # pre-push freshness hook
  hooks/doc-drift.yml.example   # optional CI workflow
  references/                   # auto-update contract · obsidian format · routing rule
  install.md
```

## Quick start

See `install.md`. TL;DR: drop into your skills dir, paste the routing rule into `CLAUDE.md`,
seed `DOMAIN.md`/ADRs from `templates/`, wire `hooks/doc-drift.sh` as a pre-push hook.

## Design stance

Curated, not extracted. Grounded, not asserted. Surgical, not regenerative. Reversible,
not silent. The skill _assists and maintains_ human-authored docs; it never treats a
generated graph as the source of truth.

License: MIT.
