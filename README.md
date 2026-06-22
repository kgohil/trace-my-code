# domain-architect

An agent skill that keeps a codebase's **curated architecture + domain docs** accurate and
fresh, so a coding agent plans features and fixes **from docs instead of crawling the
codebase** — and humans get an Obsidian-visualizable knowledge map for free.

> Why: tested head-to-head, hand-written architecture docs + ADRs let an agent produce a
> correct senior plan with **zero source-file reads**, catching the gotchas that
> knowledge-graph tools miss. Curated prose is the load-bearing layer; its only failure mode
> is going **stale** — which this skill prevents.

## Install

Any agent (Claude Code, Cursor, Codex, Copilot, opencode, …) via an agent-skills CLI:

```bash
npx skillfish add kgohil/domain-architect domain-architect
# or
npx skills add kgohil/domain-architect --skill domain-architect
```

These detect your installed agents and copy the skill into each one's skills directory.

## What you get
- **Author/maintain** the curated layer: `DOMAIN.md`, per-module `ARCHITECTURE.md`, and ADRs —
  grounded in code, in **Obsidian-vault format** (frontmatter + `[[wikilinks]]`) so `docs/`
  opens as a visual graph with no extra tooling.
- **Freshness hook**: pre-push (or CI) detection of changes in documented areas — **flag**
  mode (safe default) or **rewrite** mode (grounded surgical edits, visible revertable commit).
- A one-line **routing rule** for your root `CLAUDE.md` / `AGENTS.md` that makes the agent read
  docs first.

## Layout
```
skills/domain-architect/
├── SKILL.md                      # the skill (author mode + auto-update mode)
├── templates/                    # Obsidian-ready DOMAIN.md + ADR templates
├── hooks/doc-drift.sh            # pre-push freshness hook (+ .yml.example CI variant)
├── references/                   # auto-update contract · obsidian format · routing rule
├── install.md
└── README.md
```

See [`skills/domain-architect/install.md`](skills/domain-architect/install.md) to wire the hook
and seed the docs.

## Design stance
Curated, not extracted. Grounded, not asserted. Surgical, not regenerative. Reversible, not
silent. The skill *maintains* human-authored docs; it never treats a generated graph as truth.

License: [MIT](LICENSE).
