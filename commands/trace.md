---
description: Onboard to trace-my-code — set up the trace on a fresh repo, or show status + the highest-value next step on a traced one
argument-hint: ""
allowed-tools: Bash, Read, Edit, Write, Grep, Glob
---

Invoke the **trace-my-code** skill in its **onboarding router**
(`skills/trace-my-code/references/onboarding.md`). Do not dump the modes or guess what I want:

1. **Read the repo's trace state** in one pass (the table in `onboarding.md`): does
   `docs/DOMAIN.md` / any `ARCHITECTURE.md` exist, the `trace-eval` grade + broken citations +
   open `_TODO_`s, `--gaps`, whether the drift loop is wired, the mode, and the routing rule.
2. **Route:**
   - **No trace** → guide first-run setup (bootstrap → wire the loop, recommend the CI Action →
     routing rule → grade), doing each step.
   - **Trace exists** → show the `trace-eval` report, then propose the single highest-value next
     step from the real signals (fix broken citations / confirm `_TODO_`s worst-first / bootstrap
     the biggest gap / wire the loop / add the routing rule / else switch to reuse-first).
3. State what you'll do in one line before any file-changing step. Everything written is a draft to curate.
