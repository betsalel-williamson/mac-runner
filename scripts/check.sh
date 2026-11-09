#!/usr/bin/env bash
# Local checks that mirror CI, so a push doesn't fail there first.
# The git hooks in .githooks/ call this script; you can run it by hand too.
#
#   scripts/check.sh pre-commit         checks for the staged files
#   scripts/check.sh commit-msg FILE    Conventional Commits subject line
#   scripts/check.sh pre-push           what CI runs, plus commit subjects
#   scripts/check.sh all                every check, for a run by hand
#
# See docs/developer/local-checks.md.
set -euo pipefail

# Git GUIs and agents may start hooks without the Homebrew paths.
PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

say() { printf '\033[1m==> %s\033[0m\n' "$*"; }
fail() {
  printf '\033[31merror:\033[0m %s\n' "$*" >&2
  exit 1
}
need() { command -v "$1" >/dev/null 2>&1 || fail "$1 not found. Install it: $2"; }

# Build with Xcode's toolchain, as CI does. The Command Line Tools lack the
# plugin behind SwiftUI's #Preview macro, so the build fails with them.
use_xcode() {
  [ -n "${DEVELOPER_DIR:-}" ] && return
  xcode-select -p 2>/dev/null | grep -q CommandLineTools || return 0
  [ -d /Applications/Xcode.app/Contents/Developer ] ||
    fail "Swift checks need Xcode. Install it, or set DEVELOPER_DIR to its Developer folder."
  export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
}

# CI raises the open file limit before each Swift step.
raise_file_limit() {
  ulimit -n 65536 2>/dev/null || ulimit -n "$(ulimit -Hn)" 2>/dev/null || true
}

swift_build() {
  use_xcode
  raise_file_limit
  say "swift build --disable-sandbox"
  swift build --disable-sandbox
}

swift_test() {
  use_xcode
  raise_file_limit
  say "swift test --disable-sandbox"
  swift test --disable-sandbox
}

workflows() {
  need actionlint "brew install actionlint"
  say "actionlint"
  actionlint
}

shell_scripts() {
  need shellcheck "brew install shellcheck"
  say "shellcheck"
  shellcheck scripts/*.sh .githooks/* .claude/hooks/*.sh
}

json_files() {
  need jq "brew install jq"
  say "JSON syntax"
  local f
  for f in .claude/settings.json docs/merlon.config.json .releaserc.json; do
    jq empty "$f" || fail "$f is not valid JSON"
  done
}

docs() {
  [ -d docs/node_modules ] || fail "The docs tools aren't installed. Run: npm --prefix docs ci"
  say "docs check"
  npm --prefix docs run -s check
}

# semantic-release reads these subjects. See docs/developer/commit-conventions.md.
CC_RE='^(feat|fix|perf|revert|docs|style|refactor|test|chore|build|ci)(\([^)]+\))?!?: [^ ].*'
# Merge commits from syncing with upstream, `git revert`, and autosquash.
OTHER_RE='^(Merge |Revert "|(fixup|squash|amend)! )'

subject_ok() { [[ $1 =~ $CC_RE ]] || [[ $1 =~ $OTHER_RE ]]; }

commit_msg() {
  local subject
  subject="$(grep -v '^#' "$1" | sed -n '/[^[:space:]]/{p;q;}')"
  subject_ok "$subject" ||
    fail "The subject isn't a Conventional Commit: \"$subject\"
       Use <type>[(scope)][!]: <description>, such as \"fix: stop the crash on expired tokens\".
       Types: feat fix perf revert docs style refactor test chore build ci.
       See docs/developer/commit-conventions.md."
}

pre_commit() {
  local files
  files="$(git diff --cached --name-only --diff-filter=ACMR)"
  [ -n "$files" ] || return 0

  say "whitespace"
  git diff --cached --check

  if grep -qE '^\.github/(workflows/|actionlint\.ya?ml$)' <<<"$files"; then workflows; fi
  if grep -qE '(\.sh$|^\.githooks/)' <<<"$files"; then shell_scripts; fi
  if grep -qE '\.json$' <<<"$files"; then json_files; fi
  if grep -qE '(^docs/|\.md$)' <<<"$files"; then docs; fi
  if grep -qE '(\.swift$|^Package\.swift$)' <<<"$files"; then swift_build; fi
}

# Every commit being pushed that no remote-tracking branch has yet. Commits
# merged from upstream/main are already on a remote, so they're skipped.
check_new_subjects() {
  local tips="$1" bad="" sha subject
  # shellcheck disable=SC2086 # tips is a list of commit IDs
  while IFS=' ' read -r sha subject; do
    [ -n "$sha" ] || continue
    subject_ok "$subject" || bad="$bad
  ${sha:0:7} $subject"
  done < <(git log --format='%H %s' $tips --not --remotes)
  [ -z "$bad" ] || fail "These commits aren't Conventional Commits:$bad
       Reword them with git rebase before you push. See docs/developer/commit-conventions.md."
}

pre_push() {
  local zero=0000000000000000000000000000000000000000 tips="" local_ref local_sha remote_ref remote_sha
  if [ -t 0 ]; then
    tips="HEAD"
  else
    # shellcheck disable=SC2034 # git sends four fields; only the local SHA is needed
    while read -r local_ref local_sha remote_ref remote_sha; do
      [ "$local_sha" = "$zero" ] || tips="$tips $local_sha"
    done
  fi
  [ -n "$tips" ] || return 0 # Only deleting remote branches.

  say "commit subjects"
  check_new_subjects "$tips"
  all
}

all() {
  workflows
  shell_scripts
  json_files
  docs
  swift_build
  swift_test
  say "All checks passed"
}

case "${1:-}" in
  pre-commit) pre_commit ;;
  commit-msg) commit_msg "${2:?commit-msg needs the message file}" ;;
  pre-push) pre_push ;;
  all) all ;;
  *)
    sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
    exit 2
    ;;
esac
