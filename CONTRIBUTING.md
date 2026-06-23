# Contributing to trace-my-code

Thanks for helping. trace-my-code is a portable agent skill (Markdown + a small
shell hook), so most contributions are doc/prompt edits, template tweaks, or hook
fixes. The bar is simple: keep it grounded, keep it surgical, keep it honest.

## Ground rules

- **No direct pushes to `main`.** Every change lands via a pull request that passes
  CI. `main` is protected.
- **One focused change per PR.** A prompt tweak, a template field, a hook fix — not
  a grab-bag.
- **Claims must be grounded.** If you add a benchmark number, say how it was measured
  and label the sample size. Don't assert what you didn't run. (This is the same rule
  the skill itself enforces on the docs it writes.)
- **Match the voice.** Concrete, terse, no hype. See the README and `SKILL.md`.

## What lives where

```
skills/trace-my-code/
  SKILL.md         # the skill: bootstrap / author / drift / reuse-first modes
  references/      # the detailed contracts each mode follows
  templates/       # DOMAIN / ARCHITECTURE / ADR templates
  hooks/           # doc-drift.sh (git hook or CI) + .yml.example
benchmarks/        # methodology + tasks + results
assets/            # mascot + diagrams
```

If you change a mode's behavior, update its `references/*.md` contract in the same PR.

## Developing

1. Fork and branch off `main` (`git checkout -b my-change`).
2. Make the change. If you touch `hooks/*.sh`, run `shellcheck` on it locally —
   CI runs it too.
3. Bump `version:` in `skills/trace-my-code/SKILL.md` for any behavior change, and
   add a `CHANGELOG.md` entry under a new version heading.
4. Open a PR. Describe what changed and, for behavior changes, how you verified it
   (a probe run, a before/after, command output).

## CI / checks

Every PR runs:

- **gitleaks** — secret scan (no credentials in commits).
- **shellcheck** — lints `hooks/*.sh`.
- **actionlint** — lints the workflow files.

All must be green before merge.

## Reporting issues

- **Bugs / ideas** — open a GitHub issue.
- **Security** — do not open a public issue; see [`SECURITY.md`](SECURITY.md).

By contributing you agree your work is licensed under the repo's [MIT license](LICENSE)
and that you'll follow the [Code of Conduct](CODE_OF_CONDUCT.md).
