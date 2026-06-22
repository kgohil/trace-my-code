# Obsidian-compatible markdown

The point: `docs/` opens directly as an Obsidian vault — a visual, linked graph of the
architecture — with **no graph tool, no extraction, no build step**. Obsidian reads the
markdown; the links ARE the edges.

## Conventions

- **YAML frontmatter** on every doc (`type`, `title`, `tags`, `updated`/`date`). Obsidian
  indexes it; you can filter/query by `type: adr`, `tags: [thesis]`, etc.
- **`[[wikilinks]]`** for every cross-reference instead of relative `.md` paths:
    - a context → its ADRs and module docs: `[[adrs/0003-...|ADR-0003]]`, `[[thesis/ARCHITECTURE]]`
    - an ADR → what it governs / supersedes: `[[ADR-0002]]`
    - Obsidian resolves `[[Name]]` by filename; `[[path/Name|Label]]` for disambiguation + nicer text.
- A short **`docs/adrs/README.md`** acts as the ADR index (also the vault landing note).
- Keep headings stable — Obsidian deep-links to `[[Doc#Heading]]`.

## Using it

Open `docs/` as a vault in Obsidian → the **graph view** shows contexts ↔ ADRs ↔ modules,
backlinks panel shows what references the current doc. Same files Claude reads as prose.

## Compatibility note

Wikilinks render as plain text on GitHub (harmless). If you want both, keep wikilinks for
the vault and add a one-line standard-markdown index in `README.md`. Don't maintain two
link styles inline — pick wikilinks; the vault is the visual layer, GitHub is the diff view.
