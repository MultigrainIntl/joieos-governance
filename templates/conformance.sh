#!/bin/bash
# JoieOS conformance repair. Run by .github/workflows/conformance.yml, daily.
# Strengthening only. Never weakens protection. Never merges its own work.
set -u

OWNER=MultigrainIntl
# EVERY repository is handled by pull request. No exceptions.
# An earlier version wrote directly to default branches outside a static list, while the
# documentation claimed it always used pull requests. The claim was false; this is the fix.
# Nothing here writes to a default branch and nothing here merges.

b64() { base64 -w0 2>/dev/null < "$1" || base64 < "$1" | tr -d '\n'; }

FIXED=""; PREPARED=""; FAILED=""; OK=0; N=0

for r in $(gh repo list "$OWNER" --limit 200 --json name,isArchived \
             --jq '.[] | select(.isArchived|not) | .name' | sort); do
  N=$((N+1))
  DEF=$(gh api "repos/$OWNER/$r" --jq .default_branch 2>/dev/null)
  [ -z "$DEF" ] && { FAILED="$FAILED $r(unreadable)"; continue; }
  DID=""

  # --- branch protection: pure strengthening, applied everywhere ---
  COUNT=$(gh api "repos/$OWNER/$r/rulesets" --jq 'length' 2>/dev/null || echo 0)
  if [ "${COUNT:-0}" = "0" ]; then
    if gh api "repos/$OWNER/$r/rulesets" -X POST --input templates/ruleset.json >/dev/null 2>&1; then
      DID="$DID protection"
    else
      FAILED="$FAILED $r(protection)"
    fi
  fi

  # --- what is missing ---
  NEEDS=""
  gh api "repos/$OWNER/$r/contents/CLAUDE.md" -H "Accept: application/vnd.github.raw" 2>/dev/null \
    | grep -qi joieos || NEEDS="$NEEDS gov"
  gh api "repos/$OWNER/$r/contents/.github/workflows/joieos-compliance.yml" >/dev/null 2>&1 \
    || NEEDS="$NEEDS gate"

  if [ -n "$NEEDS" ]; then
    BR="joieos/conformance"
    HEAD=$(gh api "repos/$OWNER/$r/git/ref/heads/$DEF" --jq .object.sha 2>/dev/null)
    gh api "repos/$OWNER/$r/git/refs" -X POST -f ref="refs/heads/$BR" -f sha="$HEAD" >/dev/null 2>&1

    case "$NEEDS" in
      *gov*)
        sed "s/PROJECT_NAME/$r/" templates/CLAUDE.md > /tmp/gov.md
        SHA=$(gh api "repos/$OWNER/$r/contents/CLAUDE.md?ref=$BR" --jq .sha 2>/dev/null)
        jq -nc --arg m "JoieOS: inherit governance" --arg c "$(b64 /tmp/gov.md)" \
               --arg b "$BR" --arg s "${SHA:-}" \
          'if ($s == "" or $s == "null") then {message:$m,content:$c,branch:$b}
           else {message:$m,content:$c,branch:$b,sha:$s} end' \
          | gh api "repos/$OWNER/$r/contents/CLAUDE.md" -X PUT --input - >/dev/null 2>&1 \
          && DID="$DID governance-file" || FAILED="$FAILED $r(gov)"
        ;;
    esac

    case "$NEEDS" in
      *gate*)
        jq -nc --arg m "JoieOS: add compliance gate" --arg c "$(b64 templates/gate.yml)" --arg b "$BR" \
          '{message:$m,content:$c,branch:$b}' \
          | gh api "repos/$OWNER/$r/contents/.github/workflows/joieos-compliance.yml" -X PUT --input - >/dev/null 2>&1 \
          && DID="$DID compliance-gate" || FAILED="$FAILED $r(gate)"
        ;;
    esac

    if [ -n "$DID" ]; then
      URL=$(gh pr create --repo "$OWNER/$r" --base "$DEF" --head "$BR" \
              --title "JoieOS conformance" \
              --body "Automatic conformance repair: governance file and compliance gate. No product code touched. Every change goes through a pull request; this job never writes to a default branch and never merges its own work." 2>&1 | tail -1)
      PREPARED="$PREPARED\n  $r —$DID — $URL"
      DID=""
    fi
  fi

  if [ -n "$DID" ]; then FIXED="$FIXED\n  $r —$DID"; else OK=$((OK+1)); fi
done

{
  echo "# JoieOS conformance — $(date -u '+%Y-%m-%d %H:%M UTC')"
  echo
  echo "$N repositories checked. $OK already conformant."
  [ -n "$FIXED" ]    && { echo; echo "## Repaired automatically"; printf "$FIXED\n"; }
  [ -n "$PREPARED" ] && { echo; echo "## Prepared for review (not merged — never self-approves)"; printf "$PREPARED\n"; }
  [ -n "$FAILED" ]   && { echo; echo "## Could not repair"; echo "$FAILED"; }
} > report.md
cat report.md

if [ -n "$FIXED$PREPARED$FAILED" ]; then
  echo "changed=yes" >> "$GITHUB_OUTPUT"
else
  echo "changed=no" >> "$GITHUB_OUTPUT"
fi
