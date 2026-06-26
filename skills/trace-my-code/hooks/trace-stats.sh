#!/usr/bin/env bash
# trace-my-code — effectiveness report (the /ctx-stats analog).
#
# Run from a repo root. Answers "is the trace earning its keep?" with the same
# numbers the skill is judged on: how much of the code the map covers, how
# trustworthy its citations are, whether the drift hook is keeping it fresh, a
# claude-md-style quality grade, and an estimate of the context it saves per task.
#
#   bash trace-stats.sh                 # the report
#   bash trace-stats.sh --citations     # also list every broken citation
#   bash trace-stats.sh --json          # machine-readable summary
#
# Pure bash (3.2+) + git + awk/grep — no deps, no network, reads only (never writes).
set -o pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$ROOT" || exit 1
LIST_CITATIONS=0; AS_JSON=0
for a in "$@"; do
  case "$a" in --citations) LIST_CITATIONS=1;; --json) AS_JSON=1;; esac
done

toks()  { wc -c | awk '{printf "%d", int($1/4)}'; }          # ~4 chars/token
pct()   { awk -v n="$1" -v d="$2" 'BEGIN{printf "%d", (d>0)? (100*n/d) : 0}'; }
bar()   { awk -v p="$1" 'BEGIN{f=int(p/10); s=""; for(i=0;i<10;i++) s=s (i<f?"#":"-"); printf "%s", s}'; }
comma() { printf '%d' "$1" | sed -e ':a' -e 's/\([0-9]\)\([0-9]\{3\}\)\b/\1,\2/;ta'; }

# ---- collect trace docs (the map) -------------------------------------------
DOCS=()
while IFS= read -r l; do [ -n "$l" ] && DOCS+=("$l"); done < <(
  { find docs -type f -name '*.md' 2>/dev/null
    find . \( -path ./node_modules -o -path ./.git \) -prune -o \
      \( -name 'ARCHITECTURE.md' -o -name 'DATA_FLOW.md' -o -name 'CATALOG.md' \) -print 2>/dev/null
  } | sed 's#^\./##' | grep -v '/node_modules/' | sort -u )
N_DOCS=${#DOCS[@]}
if [ "$N_DOCS" -eq 0 ]; then
  echo "trace-my-code: no trace found (no docs/ or *ARCHITECTURE.md). Bootstrap one first."
  exit 0
fi
N_ADR=$(printf '%s\n' "${DOCS[@]}" | grep -cE '/adrs/[0-9]'); N_ADR=${N_ADR:-0}
N_ARCH=$(printf '%s\n' "${DOCS[@]}" | grep -cE 'ARCHITECTURE\.md$'); N_ARCH=${N_ARCH:-0}
DOC_LINES=$(cat "${DOCS[@]}" 2>/dev/null | wc -l | tr -d ' ')
DOC_TOK=$(cat "${DOCS[@]}" 2>/dev/null | toks)

# ---- the codebase the map indexes -------------------------------------------
CODE=()
while IFS= read -r l; do [ -n "$l" ] && CODE+=("$l"); done < <(
  find . \( -path ./node_modules -o -path ./.git -o -path ./.next -o -path ./dist -o -path ./build \) -prune -o \
  -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' -o -name '*.py' \
  -o -name '*.go' -o -name '*.rb' -o -name '*.rs' -o -name '*.java' -o -name '*.php' -o -name '*.ex' \
  -o -name '*.c' -o -name '*.cpp' -o -name '*.cs' -o -name '*.kt' -o -name '*.swift' \) -print 2>/dev/null \
  | grep -v '/node_modules/' )
N_CODE=${#CODE[@]}
CODE_LINES=0; CODE_TOK=0; SIG_DIRS=0
if [ "$N_CODE" -gt 0 ]; then
  CODE_LINES=$(cat "${CODE[@]}" 2>/dev/null | wc -l | tr -d ' ')
  CODE_TOK=$(cat "${CODE[@]}" 2>/dev/null | toks)
  SIG_DIRS=$(printf '%s\n' "${CODE[@]}" | sed 's#/[^/]*$##' | sort | uniq -c | awk '$1>=3' | wc -l | tr -d ' ')
fi
RATIO=$(awk -v c="$CODE_TOK" -v d="$DOC_TOK" 'BEGIN{printf "%.1f", (d>0)? c/d : 0}')
MAP_PCT=$(pct "$DOC_TOK" "$CODE_TOK")
COV_PCT=$(pct "$N_ARCH" "$SIG_DIRS")

# ---- citation health (reuses the drift-hook check) --------------------------
CIT=0; CIT_OK=0; BROKEN=()
while IFS= read -r line; do
  [ -n "$line" ] || continue
  doc="${line%%::*}"; cite="${line#*::}"
  inner="${cite#\`}"; inner="${inner%\`}"
  path="${inner%% › *}"; sym="${inner##* › }"
  case "$path" in *"<"*|*"*"*|*" "*|"path"|"…") continue;; esac
  CIT=$((CIT+1))
  sym="$(printf '%s' "$sym" | sed 's/(.*//' | tr -cd '[:alnum:]_')"
  if [ "${path: -1}" = "/" ]; then
    [ -d "$path" ] && CIT_OK=$((CIT_OK+1)) || BROKEN+=("$doc: $cite (dir missing)"); continue
  fi
  if [ ! -f "$path" ]; then BROKEN+=("$doc: $cite (file missing)"); continue; fi
  if [ -z "$sym" ] || grep -Fq "$sym" "$path" 2>/dev/null; then CIT_OK=$((CIT_OK+1)); else BROKEN+=("$doc: $cite (symbol gone)"); fi
done < <(for d in "${DOCS[@]}"; do grep -oE '`[^`]+ › [^`]+`' "$d" 2>/dev/null | sed "s#^#${d}::#"; done)
CIT_PCT=$(pct "$CIT_OK" "$CIT")

# ---- freshness: drift-hook activity + curation debt -------------------------
AUTO_REFRESH=$(git log --oneline --grep 'auto-refresh architecture' 2>/dev/null | wc -l | tr -d ' ')
TODO_N=$(grep -rho '_TODO: confirm_' "${DOCS[@]}" 2>/dev/null | wc -l | tr -d ' ')
TODO_DOCS=$(grep -rl '_TODO: confirm_' "${DOCS[@]}" 2>/dev/null | wc -l | tr -d ' ')
HOOK="none"
{ [ -f .git/hooks/pre-push ] && grep -q doc-drift .git/hooks/pre-push 2>/dev/null; } && HOOK="pre-push"
[ -f .github/workflows/doc-drift.yml ] && { [ "$HOOK" = "none" ] && HOOK="CI" || HOOK="$HOOK+CI"; }

# ---- quality grade (claude-md rubric, weighted) -----------------------------
OVERSIZE=0
for d in "${DOCS[@]}"; do [ "$(wc -l < "$d")" -gt 400 ] && OVERSIZE=$((OVERSIZE+1)); done
CONCISE_PCT=$(pct $((N_DOCS-OVERSIZE)) "$N_DOCS")
GOTCHA=0
for d in "${DOCS[@]}"; do
  case "$d" in *ARCHITECTURE.md) grep -qiE '^## (Gotchas|Invariants)' "$d" && GOTCHA=$((GOTCHA+1));; esac
done
GOTCHA_PCT=$(pct "$GOTCHA" "$N_ARCH")
CURRENCY_PCT=$(awk -v t="$TODO_N" -v n="$N_DOCS" 'BEGIN{p=100-(n>0? 100*t/(n*4):0); printf "%d", (p<0)?0:p}')
SCORE=$(awk -v a="$CIT_PCT" -v b="$CURRENCY_PCT" -v c="$CONCISE_PCT" -v g="$GOTCHA_PCT" -v cov="$COV_PCT" \
  'BEGIN{printf "%d", 0.35*a + 0.25*b + 0.15*c + 0.15*g + 0.10*cov}')
GRADE=$(awk -v s="$SCORE" 'BEGIN{print (s>=90)?"A":(s>=80)?"B":(s>=70)?"C":(s>=50)?"D":"F"}')

# ---- estimated savings ------------------------------------------------------
AREA_CODE_TOK=$(awk -v c="$CODE_TOK" -v s="$SIG_DIRS" 'BEGIN{printf "%d", (s>0)? c/s : 0}')
AREA_DOC_TOK=$(awk -v d="$DOC_TOK" -v n="$N_ARCH" 'BEGIN{printf "%d", (n>0)? d/n : 0}')
SAVE=$((AREA_CODE_TOK - AREA_DOC_TOK)); [ "$SAVE" -lt 0 ] && SAVE=0
SAVE_X=$(awk -v c="$AREA_CODE_TOK" -v d="$AREA_DOC_TOK" 'BEGIN{printf "%.1f", (d>0)? c/d : 0}')

if [ "$AS_JSON" -eq 1 ]; then
  printf '{"docs":%d,"adrs":%d,"doc_tokens":%d,"code_tokens":%d,"compression_ratio":%s,"coverage_pct":%d,"citations":%d,"citation_ok_pct":%d,"auto_refresh_commits":%d,"open_todos":%d,"grade":"%s","score":%d,"est_tokens_saved_per_task":%d}\n' \
    "$N_DOCS" "$N_ADR" "$DOC_TOK" "$CODE_TOK" "$RATIO" "$COV_PCT" "$CIT" "$CIT_PCT" "$AUTO_REFRESH" "$TODO_N" "$GRADE" "$SCORE" "$SAVE"
  exit 0
fi

echo "trace-my-code · effectiveness · $(basename "$ROOT")"
echo "──────────────────────────────────────────────"
echo "COVERAGE"
echo "  trace docs        $N_DOCS  ($N_ADR ADRs, $N_ARCH ARCHITECTURE docs)"
echo "  areas documented  $N_ARCH / $SIG_DIRS significant dirs   ${COV_PCT}%"
echo
echo "MAP COMPRESSION   (read the map, not the territory)"
echo "  trace             $(comma "$DOC_TOK") tokens   ($(comma "$DOC_LINES") lines)"
echo "  codebase          $(comma "$CODE_TOK") tokens   ($(comma "$CODE_LINES") lines, $N_CODE files)"
echo "  ratio             1 : $RATIO   (the map is ${MAP_PCT}% of the code)"
echo
echo "CITATION HEALTH   (grounded, not asserted)"
echo "  citations         $CIT"
echo "  resolved          $CIT_OK   [$(bar "$CIT_PCT")] ${CIT_PCT}%"
echo "  broken            $((CIT-CIT_OK))$([ "$LIST_CITATIONS" -eq 0 ] && [ $((CIT-CIT_OK)) -gt 0 ] && echo "   (--citations to list)")"
echo
echo "FRESHNESS   (drift hook keeps it honest)"
echo "  drift hook        $HOOK"
echo "  auto-refreshes    $AUTO_REFRESH commits"
echo "  curation debt     $TODO_N open _TODO: confirm_  (in $TODO_DOCS docs)"
echo
echo "QUALITY   (claude-md rubric)"
echo "  citation accuracy [$(bar "$CIT_PCT")] ${CIT_PCT}%"
echo "  currency          [$(bar "$CURRENCY_PCT")] ${CURRENCY_PCT}%"
echo "  conciseness       [$(bar "$CONCISE_PCT")] ${CONCISE_PCT}%   ($OVERSIZE over 400 lines)"
echo "  gotcha coverage   [$(bar "$GOTCHA_PCT")] ${GOTCHA_PCT}%"
echo "  ── overall        ${SCORE}/100  ($GRADE)"
echo
echo "CONTEXT FOOTPRINT   (loading one area)"
echo "  the map           ~$(comma "$AREA_DOC_TOK") tok / area doc"
echo "  its code          ~$(comma "$AREA_CODE_TOK") tok / area   (the map is ~${SAVE_X}× smaller)"
echo "  ↳ ceiling, not a per-task saving: a capable agent greps rather than loading an area whole,"
echo "    so measured cold-vs-trace token deltas are smaller (~-15%). Files read & time are the"
echo "    robust wins (paired runs: ~-76% files, ~-45% time)."
if [ "$LIST_CITATIONS" -eq 1 ] && [ ${#BROKEN[@]} -gt 0 ]; then
  echo; echo "BROKEN CITATIONS"; printf '  ! %s\n' "${BROKEN[@]}"
fi
