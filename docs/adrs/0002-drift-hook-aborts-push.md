---
type: adr
id: ADR-0002
title: Drift hook commits off-main and aborts the push
status: proposed
date: 2026-06-28
deciders: []
governs: [skills/trace-my-code/hooks/doc-drift.sh]
tags: [adr]
---

# ADR-0002: Drift hook commits off-`main` and aborts the push

> Related: [[DOMAIN]] · [[ARCHITECTURE|hooks ARCHITECTURE]]

## Context

Mode B auto-refreshes stale docs by invoking the Claude CLI. Two risks: (1) an unreviewed
machine edit landing silently on `main`; (2) the refresh racing the push so the doc commit
isn't part of what's pushed. The fix must keep the human in the loop without losing the edit.

## Decision

Rewrite mode commits the refresh as its **own visible commit** on the current/PR branch,
then **`exit 1` to abort the push** (`doc-drift.sh` tail) so the author reviews with
`git show HEAD` and pushes again — the doc commit rides the next push. Auto-commits never
go directly to `main`: locally to the current branch, in CI to the PR branch
(`doc-drift.yml.example`). Without a Claude credential or with `TRACE_MY_CODE_MODE=flag`,
it degrades to warn-only and never commits.

## Consequences

- **Positive:** no silent doc rewrites on `main`; the refresh is always a revertable commit.
- **Trade-offs:** a push that triggers a refresh fails once and must be re-run — surprising
  the first time. _TODO: confirm_ this friction is acceptable vs a non-blocking warning.
- **Gotchas future changes must respect:** the `exit 1` is load-bearing, not an error — don't
  "fix" it to `exit 0`. Doc-only diffs are excluded from triggers, so refreshing docs can't
  re-trigger itself.

## References

- Code: `skills/trace-my-code/hooks/doc-drift.sh`
- Config: `skills/trace-my-code/hooks/doc-drift.yml.example`
- Related: [[ARCHITECTURE]], [[DOMAIN]]
