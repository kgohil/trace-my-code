#!/usr/bin/env bash
# trace-my-code — UserPromptSubmit nudge (on by default via the plugin).
#
# Re-states the reuse-first contract every turn so it survives long sessions and
# compaction (a routing rule in CLAUDE.md is read once and drifts). It's a soft
# reminder, not a hard gate — it biases the agent to read the trace, it can't force it.
#
# Self-gating: only fires in a repo that actually HAS a trace (docs/DOMAIN.md or a
# module ARCHITECTURE.md), so it's silent (zero tokens) everywhere else. Opt out with
# TRACE_MY_CODE_NUDGE=off.
set -euo pipefail

[ "${TRACE_MY_CODE_NUDGE:-on}" = "off" ] && exit 0

root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

has_trace=0
if [ -f "$root/docs/DOMAIN.md" ]; then
  has_trace=1
elif find "$root" -maxdepth 5 -name ARCHITECTURE.md -not -path '*/node_modules/*' -print -quit 2>/dev/null | grep -q .; then
  has_trace=1
fi
[ "$has_trace" -eq 1 ] || exit 0

cat <<'EOF'
[trace-my-code] Before writing code in a documented area, read its ARCHITECTURE.md + docs/DOMAIN.md first, then climb the reuse ladder (YAGNI -> reuse/extend -> stdlib -> native -> installed dep -> one line -> only then minimum new). Never cut validation, error handling, security, or accessibility. Full contract: the trace-my-code skill (reuse-first).
EOF
