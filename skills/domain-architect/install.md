# Install — domain-architect

The skill itself works as soon as it's in a skills dir (`/domain-architect`, or auto-invoked
by description). The optional **freshness hook** is what you wire below.

## 1. Pick a mode

```bash
git config domainArchitect.mode flag      # default: just flag drift (safe)
# or
git config domainArchitect.mode rewrite   # auto-refresh docs (needs the Claude CLI)
```

Or per-invocation: `DOMAIN_ARCHITECT_MODE=rewrite`. Rewrite mode also needs the Claude CLI
on PATH (override with `DOMAIN_ARCHITECT_CLAUDE=/path/to/claude`).

## 2a. Local git hook (default) — fires once per push

**lefthook** (`lefthook.yml`):

```yaml
pre-push:
    commands:
        doc-drift:
            run: .claude/skills/domain-architect/hooks/doc-drift.sh
```

**husky:** add the line to `.husky/pre-push`.
**plain git:** `ln -s ../../.claude/skills/domain-architect/hooks/doc-drift.sh .git/hooks/pre-push`
(or append the call if you already have a pre-push hook).

In rewrite mode the hook creates a `docs: auto-refresh …` commit and aborts the push —
review with `git show HEAD`, then push again so the doc commit is included.

## 2b. CI workflow (optional) — fires on PR/merge, no local setup

Copy `hooks/doc-drift.yml.example` to `.github/workflows/` (it runs the same script with
`DOMAIN_ARCHITECT_MODE=rewrite` and commits the refresh to the PR branch — no re-push).
Requires a Claude API credential in CI secrets.

## 3. Add the routing rule

Paste the snippet from `references/routing-rule.md` into your root `CLAUDE.md`/`claude.md`.

## 4. (one-time) seed the docs

Use the skill (Mode A) + `templates/` to write `docs/DOMAIN.md` and your first ADRs, and
ensure each significant module has an `ARCHITECTURE.md`. The hook keeps them fresh after that.
