#!/usr/bin/env bash
# Claude Code SessionStart hook: tells the agent and the operator when the
# git hooks or the docs tools aren't set up in this clone.
# See docs/developer/local-checks.md.
set -euo pipefail

cd "${CLAUDE_PROJECT_DIR:-.}"

notes=()
if [ "$(git config --get core.hooksPath || true)" != ".githooks" ]; then
  notes+=("The git hooks aren't installed in this clone. Run \`make hooks\` before you commit, so commits and pushes run the same checks as CI.")
fi
if [ ! -d docs/node_modules ]; then
  notes+=("The docs tools aren't installed. Run \`npm --prefix docs ci\` before you change docs.")
fi

[ "${#notes[@]}" -gt 0 ] || exit 0

msg="${notes[*]}"
jq -n --arg m "$msg" '{
  systemMessage: $m,
  hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: $m}
}'
