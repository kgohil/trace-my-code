---
type: adr
id: ADR-0001
title: Cite by symbol, not line number
status: proposed
date: 2026-06-28
deciders: []
governs: [skills/trace-my-code/hooks/doc-drift.sh, skills/trace-my-code/hooks/trace-eval.sh, skills/trace-my-code/templates]
tags: [adr]
---

# ADR-0001: Cite by symbol, not line number

> Related: [[DOMAIN]] · [[ARCHITECTURE|hooks ARCHITECTURE]]

## Context

A trace is only trustworthy if its references survive edits. A raw `path:line` citation
rots on every insertion above it — the doc silently points at the wrong code. The trace
needs a reference that an automated drift check can verify is still valid.

## Decision

Cite by symbol — a backtick reference of the form _path arrow symbol_ (e.g. a file path,
` › `, then the symbol name); a line number, if given, is a hint only (`~:NN`). The drift
hook and meter both resolve the citation by grepping the **last identifier** of the symbol
in the cited file, ignoring the trailing `(...)`
(`skills/trace-my-code/hooks/doc-drift.sh › check_citations`, and the `trace-eval.sh`
citation loop). A missing file or a
symbol that no longer appears is flagged as broken.

## Consequences

- **Positive:** citations survive line shifts; drift detection catches the high-value
  changes (renames/removals) instead of cosmetic line drift.
- **Trade-offs:** verification is substring grep — a same-named symbol or a mention in a
  comment passes (no scoping). _TODO: confirm_ this looseness is acceptable vs an AST check.
- **Gotchas future changes must respect:** the parser is **duplicated** in
  `skills/trace-my-code/hooks/doc-drift.sh` and `skills/trace-my-code/hooks/trace-eval.sh` —
  change both. Member access (`Foo.bar`) resolves on the last identifier (`bar`), by design.

## References

- Code: `skills/trace-my-code/hooks/doc-drift.sh › check_citations`
- Code: `skills/trace-my-code/hooks/trace-eval.sh`
- Related: [[ARCHITECTURE]], [[DOMAIN]]
