# Multi-repo / cross-service tracing

A trace lives **per repo**. Real flows cross service boundaries — so traces link to
each other the same way pages link in a wiki: by **anchor to the other repo's root
trace doc**. No central registry, no build step; just links between roots that an
agent can follow when the repos are checked out together.

## The convention
- Every repo's trace is rooted at **`docs/DOMAIN.md`** (its entry point).
- In a context/area that calls another service, add an **`## External services`**
  section listing each downstream/upstream service with a one-line role and an anchor
  to that service's root doc:
  - **Sibling repos checked out locally** (e.g. `~/work/service-a`, `~/work/service-b`):
    relative link — `[[../service-b/docs/DOMAIN.md]]` (or `../../service-b/docs/DOMAIN.md`
    depending on nesting). This is what lets an agent walk the flow end-to-end locally.
  - **Not local / unknown checkout path:** link the repo URL instead —
    `[service-b](https://github.com/org/service-b)` — and note the expected sibling path
    so a reader can clone it next to this one to enable local tracing.
- Make the link **bidirectional** where it matters: if A documents "calls B", B's trace
  should note "called by A" so the flow is traceable from either end.

## What it buys
When an agent is tracing an end-to-end flow (e.g. "what happens when a user checks out"),
it reads this repo's `DOMAIN.md`, hits the boundary, follows the anchor into service B's
`DOMAIN.md`, and continues — reconstructing the cross-service path from curated docs
instead of guessing at the wire. The same drift hook keeps each repo's half current; the
links keep the halves connected.

## Keep it honest
- An anchor is a **claim that a call exists** — ground it (cite the client/caller
  `path:line` that talks to the other service), same as any other trace claim.
- Don't duplicate the other service's internals here — link to its root and let its own
  trace own the detail. This repo documents *its* side of the boundary (what it sends,
  what it expects back) + the anchor.
- If the sibling repo isn't present locally, the agent simply can't follow the link —
  that's fine; it degrades to "boundary + URL", not a broken trace.

## Convention, not tooling
This is deliberately just Markdown links — portable across any agent/editor, visible in
an Obsidian vault that spans sibling repos, and impossible to "break" beyond a dangling
link. No service registry to maintain; the repo layout on disk is the index.
