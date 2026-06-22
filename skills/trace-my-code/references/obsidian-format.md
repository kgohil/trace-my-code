# Obsidian-compatible markdown

The point: `docs/` opens directly as an Obsidian vault — a visual, linked graph of the
architecture — with **no extra tooling, no build step**. Obsidian reads the
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

## Viewing the graph

The trace is plain Markdown — readable in any editor. To see it *as a graph*, use any
wiki that understands `[[wikilinks]]`. Obsidian (free) is the reference:

1. **Install** [Obsidian](https://obsidian.md) (or any `[[wikilink]]`-aware editor —
   Logseq, Foam-in-VS-Code, etc.).
2. **Open the trace as a vault:** `Open folder as vault` → pick the repo's `docs/`
   (the folder holding `DOMAIN.md`, `adrs/`, and the per-module docs). No build, no
   server, no plugins required.
3. **Graph view:** click the graph icon (or `Ctrl/Cmd-G`). Each doc is a node; every
   `[[wikilink]]` is an edge — you see contexts ↔ ADRs ↔ modules at a glance. Use
   **Group** colors by `tags`/`type` frontmatter to tint domains differently.
4. **Backlinks:** open any doc → the backlinks pane lists every doc that links *to* it
   ("what depends on this decision?"). This is the inbound half the graph view shows.
5. **Local graph:** with a doc open, the local-graph view shows just that node and its
   immediate neighbors — handy for "what touches the thesis flow?"
6. **Navigate:** `Cmd/Ctrl-O` quick-switch by title; `[[` autocompletes links while
   editing. Headings are addressable as `[[Doc#Heading]]`.

These are the same files the coding agent reads as prose — the graph is just a second
view over them, never a separate artifact to keep in sync.

### Multi-repo / microservices

Open the **parent folder that contains the sibling repos** as one vault (e.g. a
`~/work/` that holds `service-a/`, `service-b/`). Obsidian indexes every `docs/` under
it, so cross-repo anchor links — `[[service-b/docs/DOMAIN|service-b]]` — resolve and
appear as edges in a single graph spanning all services. See [`multi-repo.md`](multi-repo.md)
for the anchor-linking convention that makes this work.

## Compatibility note

Wikilinks render as plain text on GitHub (harmless). If you want both, keep wikilinks for
the vault and add a one-line standard-markdown index in `README.md`. Don't maintain two
link styles inline — pick wikilinks; the vault is the visual layer, GitHub is the diff view.
