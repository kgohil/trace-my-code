# Security Policy

## Scope

trace-my-code is an agent skill: Markdown instructions, templates, and one shell
hook (`skills/trace-my-code/hooks/doc-drift.sh`). The realistic security surface is:

- the **drift hook**, which in `rewrite` mode invokes your local Claude CLI and makes
  commits, and
- the skill **prompts**, which instruct an agent to read your code and write docs.

It ships no server, no network service, and no runtime dependency to exploit.

## Reporting a vulnerability

**Do not open a public issue for security reports.** Instead:

- Open a [private security advisory](https://github.com/kgohil/trace-my-code/security/advisories/new), or
- Contact the maintainer at [@kgohil](https://github.com/kgohil).

Please include what you found, how to reproduce it, and the impact. We'll
acknowledge within a few days and keep you posted on the fix.

## Hardening notes for users

- The drift hook defaults to **`flag`** mode (warns only). `rewrite` mode runs your
  Claude CLI and creates a commit — review it (`git show HEAD`) before pushing.
- The hook only edits files under `docs/` and the governing doc paths; it never
  touches source. Read `references/auto-update-contract.md` for the exact contract.
- CI secret-scans every PR (gitleaks) so credentials don't land in history.
