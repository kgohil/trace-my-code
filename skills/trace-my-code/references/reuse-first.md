# Reuse-first development (Mode C)

The problem this solves: a coding agent's default is to **reinvent** — write a new helper,
component, or flow the repo already has — because it lacks context on what exists, what the
pattern is, and what's meant to be extended. The trace supplies that context; this mode
forces the agent to **read it before reaching for a blank file**.

Modeled on the discipline of `superpowers:systematic-debugging`: an iron law, gated phases
you complete in order, a written decision, and red-flag rationalizations that mean STOP.

## The Iron Law

```
NO NEW CODE WITHOUT A REUSE INVESTIGATION FIRST
```

You may not create a new file, helper, component, hook, type, or abstraction until Phases
0–3 are done **and written down**. Skipping the investigation because the task "looks
simple" or "it's faster to build fresh" is the exact failure this mode exists to prevent.

## The phases (complete in order — one TodoWrite item each)

Create a todo per phase before starting. Do not collapse them.

### Phase 0 — Load the map
Read `docs/DOMAIN.md` (which context owns this) and the target module's `ARCHITECTURE.md`,
specifically its **Patterns & extension points** and **Invariants & absences** sections.
This is what the trace is _for_ — it's 2 cheap reads, not a crawl.
- Output: which bounded context + module owns this, and the patterns it already uses.

### Phase 1 — Locate what exists
Answer "does this already exist, in whole or in part?" Search the trace's pattern catalog
**and** the code (sibling modules, shared/`lib`, `@repo/*` packages). One grep that misses
is not an answer — search by capability, by symbol, by similar feature.
- Output: a list of candidates as `` `path/to/file › symbol` `` with one line each on how
  close they are. If genuinely nothing exists, say so explicitly with what you searched.

### Phase 2 — Pattern analysis
Read the **closest existing implementation completely** — every line, not a skim. Identify:
the established pattern, its **extension point** (the seam you'd plug into), its
dependencies/conventions, and exactly what's different about your case.
- Output: "The pattern is X (`path › symbol`); it's extended by doing Y; my case differs in Z."

### Phase 3 — Decide: reuse → extend → new (in that order)
State the decision in one line with justification, like a hypothesis:
> "I will **reuse** `X` / **extend** `Y` because Z."
**Choosing `new` requires stating why reuse and extend both fail.** "Cleaner to start fresh"
is not a reason. If you can't justify `new`, you don't get to write it.

### Phase 4 — Implement following the pattern
Build along the established seam. Match its conventions (naming, error handling, file
placement, tests). Cite the trace anchors you followed. If you discover the pattern was
wrong/missing, that's a trace update (Mode A) — note it, don't silently diverge.

## Red flags — STOP and return to Phase 0/1

If you catch yourself thinking:
- "I'll just write a quick helper for this"
- "Didn't find it in one grep, so it doesn't exist" → search the trace + by capability
- "Simpler to build fresh than to understand the existing one"
- "The pattern says X but I'll do it my own way here"
- "Let me create the new file first, I'll wire it up after"
- Listing new files/abstractions before listing existing candidates
- "This is too small to need an investigation" (small additions are how parallel
  implementations of the same thing get born)

All of these mean: STOP. You have not completed the reuse investigation.

## Human signals you're reinventing

Watch for these redirections — each means go back to Phase 1:
- "Don't we already have that?" / "Didn't we build this?"
- "Why a new component — what about `<existing>`?"
- "Follow the existing pattern."
- "Reuse, don't rewrite."

## Why it depends on the trace

Phases 0 and 2 only work if the module's `ARCHITECTURE.md` actually carries a **Patterns &
extension points** section (the canonical example + the seam to extend) and an **Invariants
& absences** section (what's enforced, what's _not_). If those are missing, fill them first
(Mode A / bootstrap) — the discipline is only as good as the map it reads.
