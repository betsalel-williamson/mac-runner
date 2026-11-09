#!/usr/bin/env bash
# Claude Code PreToolUse hook for Bash: stops an agent from skipping the git
# hooks in .githooks/, which run the same checks as CI.
# See docs/developer/local-checks.md.
set -euo pipefail

cmd="$(jq -r '.tool_input.command // empty')"

deny() {
  jq -n --arg r "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $r
    }
  }'
  exit 0
}

grep -qE '(^|[^[:alnum:]_.-])git([[:space:]]|$)' <<<"$cmd" || exit 0

why="The git hooks run the checks CI runs. Fix what they report instead of skipping them; if a check is wrong, tell the operator."

if grep -qE -- '--no-verify' <<<"$cmd"; then
  deny "Don't pass --no-verify. $why"
fi

# `git commit -n` is the short form of --no-verify.
if grep -qE 'git[[:space:]][^;&|]*commit[^;&|]*[[:space:]]-[[:alpha:]]*n[[:alpha:]]*([[:space:]]|$)' <<<"$cmd"; then
  deny "Don't pass -n to git commit; it skips the hooks. $why"
fi

if grep -qE 'core\.hooksPath' <<<"$cmd"; then
  # Allowed: reading the setting, and pointing it at .githooks (make hooks).
  if grep -qE -- '-c[[:space:]]*core\.hooksPath=|--unset(-all)?[[:space:]]+core\.hooksPath' <<<"$cmd"; then
    deny "Don't override or unset core.hooksPath. $why"
  fi
  if grep -qE 'core\.hooksPath[[:space:]]+[^-;&|[:space:]]' <<<"$cmd" &&
    ! grep -qE 'core\.hooksPath[[:space:]]+\.githooks([[:space:]]|$|[;&|])' <<<"$cmd"; then
    deny "core.hooksPath must stay .githooks. $why"
  fi
fi

exit 0
