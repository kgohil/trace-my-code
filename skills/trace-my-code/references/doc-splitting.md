# Doc splitting — keep the layer navigable as it grows

The docs are context, and context has a cost: a 1,500-line `DOMAIN.md` is as useless to
an agent as no docs — it can't find the relevant 20 lines. Keep every file focused and
let the **structure** carry the size. Same progressive-disclosure principle skills
themselves use (index → section → detail).

## Default structure already scales horizontally

- `docs/DOMAIN.md` — the **index/map**: one short entry per bounded context, linking out.
- per-module `ARCHITECTURE.md` / `DATA_FLOW.md` — the detail, next to the code.
- `docs/adrs/NNNN-*.md` — one decision per file.

Most growth needs **no split**: a new feature = a new module `ARCHITECTURE.md` or a new
ADR. Reach for splitting only when a _single_ file outgrows its job.

## When to split a file

Split when any holds:

- a file exceeds **~300–400 lines**, or
- a section covers **more than one cohesive sub-area** that's navigated independently, or
- a `DOMAIN.md` context has grown enough detail to deserve its **own page**.

## How to split (index + leaf, not shrapnel)

1. Move the overgrown section into a focused file under a folder for its area, e.g.
   `docs/domain/<context>.md`, `docs/<module>/<sub-flow>.md`.
2. Replace the original section with a **1–2 line summary + a `[[wikilink]]`** to the new
   file. `DOMAIN.md` stays the map; the detail moves out.
3. Keep/refresh an **index note** (the parent doc, or a folder `README`/`INDEX.md`) so the
   set stays a tree, not loose files.
4. Preserve `[[wikilinks]]` + frontmatter — Obsidian then renders the index→leaf graph and
   backlinks for free.

## Don't over-split

One concept per file is _too_ granular — it fragments context and multiplies upkeep. Split
at **natural seams** (a bounded context, a module, a distinct flow), never arbitrarily by
line count alone. If two files are always read together, they're one file.

## Heuristic, not a rule

The line thresholds are a nudge, not a gate. The real test: _can an agent land on the right
focused doc in one hop from the index, and is each doc about one thing?_ If yes, leave it.
If a file makes you scroll to find the relevant part, split it.
