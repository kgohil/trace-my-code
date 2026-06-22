# Benchmark tasks

Two kinds. **Build** tasks each have a known-right reuse target in the repo (the over-build
trap) — a cold agent tends to reinvent; a trace agent should reuse. **Explain** tasks score
whether the agent reconstructs the real flow with accurate citations.

A trap is only a trap if the repo actually has the thing to reuse — adapt these to your repo,
or use them as a template for writing your own. The "expected (trace)" column is the behavior
that scores as a win.

## Build tasks (reuse / over-build)

| # | Task | Over-build trap | Expected (trace) |
|---|------|-----------------|------------------|
| B1 | Add a CSV export of a list to a new endpoint | new export subsystem + CSV library | extend the existing export/endpoint pattern; one-line CSV if no writer exists |
| B2 | Add a date-range filter + picker to a table | a date-picker component / library | native `<input type="date">`; reuse the existing client-side filter pattern |
| B3 | Add a "minimum N items" rule to a generation flow | a new validation module | extend the single function where the count is already derived; enumerate its callers |
| B4 | Add a toast/notification on an action | a new toast system | reuse the repo's existing toast convention |
| B5 | Add a new report/variant to a reporting feature | a parallel report pipeline | follow the catalogue → param → builder extension point the module documents |
| B6 | Debounce an expensive handler | hand-rolled timer plumbing | reuse an existing debounce util / stdlib-equivalent if present |

Score each: ladder rung chosen, reuse/extend/new, over-build avoided (y/n), files read, LOC,
safety floor kept (validation/authz/a11y where relevant).

## Explain tasks (flow + citation accuracy)

| # | Task | Scored on |
|---|------|-----------|
| E1 | "Explain how <core feature> is generated end-to-end" | correct order + branches/conditions; every claim cites `path › symbol`; no hallucinated externals |
| E2 | "Where is <X> decided, and what limits/gates affect it?" | finds the real decision point + invariants/absences (no-floor, silent-drop class) |
| E3 | "What external systems does <module> depend on?" | names each from its import/SDK, not a comment; no wrong-vendor guess |

Score each: files read, citation accuracy (grep each), invariants surfaced, externals correct.

## Arms

For every task run two arms in the **same** repo:

- **cold** — fresh agent, forbidden from reading `docs/` and any `ARCHITECTURE.md`/`DATA_FLOW.md`.
- **trace** — fresh agent, trace present, instructed to follow Mode C (`references/reuse-first.md`).

The delta (files read, reuse decision, over-build, citation accuracy, safety) is the result.
