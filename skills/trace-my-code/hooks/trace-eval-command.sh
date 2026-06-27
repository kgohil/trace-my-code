#!/usr/bin/env bash
# trace-my-code — /trace-eval slash command (UserPromptSubmit hook).
#
# When the submitted prompt is "/trace-eval [flags]", run the trace-eval meter and
# return its output directly — blocking the prompt so it never reaches the model
# (zero model tokens), the same pattern as /caveman-stats. Any other prompt: silent.
#
# Pure bash + its trace-eval.sh sibling — no deps. Opt out with TRACE_MY_CODE_NUDGE=off.
set -o pipefail

[ "${TRACE_MY_CODE_NUDGE:-on}" = "off" ] && exit 0

event="$(cat 2>/dev/null || true)"
# Fast path: only act when the submitted prompt carries the /trace-eval command.
case "$event" in
  *'"prompt"'*'/trace-eval'*) : ;;
  *) exit 0 ;;
esac

# Pull "/trace-eval [flags]" out of the event (flags are alnum / space / dash / underscore).
cmd="$(printf '%s' "$event" | grep -oE '/trace-eval[A-Za-z0-9 _-]*' | head -1)"
[ -n "$cmd" ] || exit 0
argstr="${cmd#/trace-eval}"; argstr="${argstr# }"
read -r -a args <<< "$argstr"

# Self-gate: only report when a real trace exists (docs/DOMAIN.md or a module
# ARCHITECTURE.md) — same check as the reuse-first nudge. A docs-only repo isn't a trace.
root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
has_trace=0
if [ -f "$root/docs/DOMAIN.md" ]; then
  has_trace=1
elif find "$root" -maxdepth 5 -name ARCHITECTURE.md -not -path '*/node_modules/*' -print -quit 2>/dev/null | grep -q .; then
  has_trace=1
fi
if [ "$has_trace" -ne 1 ]; then
  printf '%s\n' '{"decision":"block","reason":"trace-my-code: no trace in this repo yet. Bootstrap one with the trace-my-code skill, then /trace-eval reports its health."}'
  exit 0
fi

here="$(cd "$(dirname "$0")" && pwd)"
out="$(bash "$here/trace-eval.sh" "${args[@]}" 2>&1 || true)"

# JSON-escape the output (backslash, quote, CR, tab, then newlines) — BSD/GNU-sed safe.
esc="$(printf '%s' "$out" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\r//g' -e 's/\t/\\t/g' -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g')"
printf '{"decision":"block","reason":"%s"}\n' "$esc"
