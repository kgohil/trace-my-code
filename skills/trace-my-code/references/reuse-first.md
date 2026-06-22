# Reuse-first development (Mode C)

The problem this solves: a coding agent's default is to **reinvent** — write a new helper,
component, or flow the repo already has — because it lacks context on what exists, what the
pattern is, and what's meant to be extended. The trace supplies that context; this mode
forces the agent to **read it before reaching for a blank file**.

Modeled on the discipline of `superpowers:systematic-debugging` (iron law, gated phases, a
written decision, red-flag rationalizations) and the "lazy senior dev" decision ladder +
safety floor from [ponytail](https://github.com/DietrichGebert/ponytail) (MIT). The twist
trace-my-code adds: ponytail's "already in this codebase? reuse it" rung assumes the agent
can _find_ what exists — the trace is the map that makes that rung reliable in a large repo
instead of a blind grep that misses callers.

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
- **If you'll modify a shared symbol, enumerate every caller first.** Grep all call sites
  before changing it — fix the shared function once rather than patching the one path the
  task names (which leaves sibling callers broken). The trace's flow + the grep together
  give the full caller set; trust the grep, not the trace alone (a doc can miss a caller).

### Phase 2 — Pattern analysis
Read the **closest existing implementation completely** — every line, not a skim. Identify:
the established pattern, its **extension point** (the seam you'd plug into), its
dependencies/conventions, and exactly what's different about your case.
- Output: "The pattern is X (`path › symbol`); it's extended by doing Y; my case differs in Z."

### Phase 3 — Decide: climb the ladder, stop at the first rung that holds
Don't jump to "write it." Walk these in order and stop at the first that applies — the
trace tells you where you are on rung 2:

```
1. Does this need to exist at all?      → no: skip it (YAGNI)
2. Already in this codebase?            → reuse / extend it (the trace's Patterns &
                                          extension points names the canonical example)
3. Standard library does it?           → use it
4. Native platform feature does it?    → use it (e.g. `<input type="date">`, not a lib)
5. An already-installed dependency?     → use it (don't add a new one)
6. Can it be one line?                  → one line
7. Only then: the minimum new code that works
```

State the decision in one line with the rung and justification, like a hypothesis:
> "Rung 2 — **extend** `path › symbol` because Z."
**Reaching rung 7 (new code) requires stating why rungs 1–6 don't apply.** "Cleaner to
start fresh" is not a reason. The ladder runs _after_ Phases 0–2 (understand + locate),
never instead of them — a small diff in the wrong place is a second bug, not laziness.

### Phase 4 — Implement following the pattern
Build along the established seam. Match its conventions (naming, error handling, file
placement, tests). Cite the trace anchors you followed.
- **Honor the safety floor below** — the ladder cuts code, never correctness.
- **Leave one runnable check** for any non-trivial logic — the smallest thing that fails if
  the logic breaks (an assert-based self-check or one small test; no new frameworks/fixtures).
  Trivial one-liners need none.
- **Mark intentional simplifications.** A shortcut with a known ceiling (global lock, O(n²)
  scan, naive heuristic, unhandled edge) gets an inline `trace-my-code:` comment that names
  the ceiling **and** the upgrade path — and is recorded in the module doc's **Invariants &
  absences** so the next agent inherits the limitation instead of trusting a gap.
- If the pattern was wrong/missing, that's a trace update (Mode A) — note it, don't silently diverge.

## The safety floor (the ladder is lazy, never negligent)

"Reuse / minimum code" is about the **solution**, never the **safeguards**. These are NEVER
cut, simplified away, or skipped to make a diff smaller — doing so is the one way reuse-first
turns reckless:

- **Input validation at trust boundaries** (user input, network, file, env).
- **Error handling that prevents data loss** (don't swallow, don't leave half-written state).
- **Security** (authz/scoping, injection, secrets, the existing auth pattern).
- **Accessibility** (labels, roles, keyboard, contrast — match the design system).
- **Anything the user explicitly requested**, even if it looks optional.

Lazy about understanding the problem is also forbidden: read the code the change touches and
trace the real flow before picking a rung (Phases 0–2). A small diff you don't understand is
laziness dressed up as efficiency.

## Red flags — STOP and return to Phase 0/1

If you catch yourself thinking:
- "I'll just write a quick helper for this"
- "Didn't find it in one grep, so it doesn't exist" → search the trace + by capability
- "Simpler to build fresh than to understand the existing one"
- "The pattern says X but I'll do it my own way here"
- "Let me create the new file first, I'll wire it up after"
- "I'll add `<library>` for this" — when stdlib, a native feature, or an installed dep covers it
- "I'll just patch the path the ticket names" — when the symbol has other callers (Phase 1)
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
