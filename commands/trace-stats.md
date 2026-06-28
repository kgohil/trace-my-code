---
description: Trace health + usage stats for this repo — coverage, citation health, A–F grade, and what the trace saved you
argument-hint: "[--usage|--gaps|--citations|--json]"
allowed-tools: Bash
---

Run the trace-my-code effectiveness meter and show its output **verbatim** — do not
summarize or re-format it. Default view (no flag) is `--usage` (what the trace saved);
pass `--gaps`, `--citations`, or `--json` for the health views.

!`args="$ARGUMENTS"; bash "${CLAUDE_PLUGIN_ROOT}/skills/trace-my-code/hooks/trace-eval.sh" ${args:---usage} 2>&1`

<!-- Discoverability surface for /trace-stats. When the on-by-default UserPromptSubmit hook
     (trace-stats-command.sh) is active, typing /trace-stats is intercepted and answered with
     zero model tokens; this command file makes it show in the palette and runs the same meter
     standalone if the hook is off. -->
