---
type: domain
title: <Project> — Domain Model
updated: YYYY-MM-DD
tags: [domain, architecture]
---

# <Project> — Domain Model

> The meaning layer. Read before changing an area. Each context links to its
> module docs and the ADRs that govern it.
> Companion: per-module `ARCHITECTURE.md` (detail) · [[adrs/README|ADRs]] (why).

One-paragraph product description.

---

## Bounded contexts

### <Context name>

- **Owns:** `<Aggregate>`, `<Aggregate>` … (the entities/tables it controls)
- **Modules:** `<frontend module>` · `<api module>` · `<package>`
- **Language:** _<term>_ (meaning), _<term>_ (meaning) — the ubiquitous language
- **Decisions:** [[adrs/000X-...|ADR-000X]]
- **Detail:** [[<module>/ARCHITECTURE|<module> ARCHITECTURE]]

<!-- repeat per context. Mark unknowns _TODO: confirm_ rather than inventing. -->

---

## Cross-context relationships

- **<A> → <B>:** how they connect, and the key invariant.

## External services (cross-repo)

<!-- Other services this repo talks to. Anchor to each one's root trace doc so an
     agent can follow the flow across repos. See references/multi-repo.md. -->

- **<service-b>** — <what we call it for>; caller: `path/to/client.ts:NN`.
  Trace: [[../service-b/docs/DOMAIN.md]] <!-- sibling repo; or use the repo URL if not local -->

## Ubiquitous language — glossary

| Term   | Means     | Not to be confused with |
| ------ | --------- | ----------------------- |
| <term> | <meaning> | <adjacent term>         |
