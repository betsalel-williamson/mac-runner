# Local checks

Git hooks run the same checks as CI before code leaves your Mac, so a push
doesn't fail there first. Claude Code hooks stop a coding agent from skipping
them.

## Set up a clone

Run once in each clone:

```bash
make hooks
npm --prefix docs ci
```

`make hooks` sets the clone's `core.hooksPath` to `.githooks`. It changes
only this repository's git configuration. The checks also need Xcode,
`actionlint`, `shellcheck`, and `jq`:

```bash
brew install actionlint shellcheck jq
```

## What runs when

Every hook calls `scripts/check.sh`, so the hooks and a run by hand check the
same things.

| Hook         | Runs                                                                                                                              |
| ------------ | --------------------------------------------------------------------------------------------------------------------------------- |
| `pre-commit` | Checks picked by the staged files, listed below                                                                                   |
| `commit-msg` | Rejects a subject that isn't a [Conventional Commit](commit-conventions.md)                                                       |
| `pre-push`   | Checks the subject of every new commit, then every check: `actionlint`, `shellcheck`, JSON syntax, the docs check, build and test |

The `pre-commit` hook always checks the staged lines for whitespace errors.
Then it runs only the checks the staged files need:

| Staged files                                    | Check             |
| ----------------------------------------------- | ----------------- |
| `.github/workflows/`, `.github/actionlint.yaml` | `actionlint`      |
| Shell scripts and `.githooks/`                  | `shellcheck`      |
| JSON files                                      | `jq` syntax check |
| `docs/` and Markdown files                      | The docs check    |
| Swift files and `Package.swift`                 | `swift build`     |

The hook checks the files on disk, not only the staged copies, so stage
everything you changed before you commit.

The `pre-push` hook checks only commits that no remote-tracking branch has
yet. Commits merged from `upstream/main` are already there, so a sync with
upstream doesn't trip on its older subjects. Besides Conventional Commits,
it accepts merge commits, `git revert` subjects, and `fixup!`, `squash!`, and
`amend!` commits.

## Match CI

The build and test steps match [CI](ci.md):

- Xcode's toolchain. When the Command Line Tools are selected, the script
  sets `DEVELOPER_DIR` to `/Applications/Xcode.app/Contents/Developer` for
  its own commands. It doesn't change `xcode-select`.
- `--disable-sandbox` on `swift build` and `swift test`.
- The open file limit raised to 65536, or to the hard limit.

CI starts each run from clean SwiftPM state. The hooks reuse `.build` to stay
fast. When a local run passes and CI fails on package resolution, run
`swift package reset` and push again.

The hooks also run checks CI doesn't: `actionlint`, `shellcheck`, the docs
check, and commit subjects. They don't run `swift-format`, because the code
doesn't follow its style. See [Build and test](build-and-test.md#make-targets).

## Run the checks by hand

```bash
make check
```

This runs every check, the same as the `pre-push` hook. To run one hook's
checks, call the script with the hook's name, such as
`scripts/check.sh pre-commit`.

## Known findings

`.github/actionlint.yaml` ignores two `shellcheck` findings in the release
workflow's signing step, which upstream wrote. One of them is deliberate word
splitting of the keychain list. Remove the entries when that step changes.

## Agent hooks

`.claude/settings.json` adds two Claude Code hooks:

- **Before each shell command**, `.claude/hooks/guard-git.sh` blocks
  `--no-verify`, `git commit -n`, and any change to `core.hooksPath` other
  than `make hooks`. The agent must fix what a hook reports instead.
- **When a session starts**, `.claude/hooks/session-check.sh` tells the agent
  and you when this clone lacks the git hooks or the docs tools.

You can still pass `--no-verify` yourself in an emergency. Expect CI to catch
what you skipped.
