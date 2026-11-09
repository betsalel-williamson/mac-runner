# Declarative runner configuration in `.mac-runner.yml`

## Status

Accepted. Recorded after the fact from the code and history at 74c78d7.

## Context

Setting up several runners, or the same runners on another Mac, took one
`mac-runner add` per runner and settings changed by hand. The saved
configuration, `config.json` in Application Support, holds internal state
such as run status and runner IDs, so it isn't a file to write or copy
between Macs.

## Decision

Describe the runners a Mac should have, and a few global settings, in a YAML
file, `.mac-runner.yml`. `mac-runner apply` makes the Mac match it, and
`mac-runner export` writes the current setup as such a file.

- The file holds a format version, optional global settings (isolation mode,
  quiet hours, and pausing on battery), and a list of runners. Each runner
  has a name, a repository or an organization, and optional labels,
  isolation mode, image, GUI access, open file limit, schedule, and `count`,
  which expands to numbered runners.
- `apply` reads `-f <path>`, else `./.mac-runner.yml`, else
  `~/.mac-runner/config.yml`.
- `apply` matches runners by name and plans additions, in-place updates,
  re-registrations when registration details change, removals, and settings
  changes. It restarts a running runner only when a change needs it.
- `apply` removes runners missing from the file, unless you pass
  `--no-prune`. It asks before it removes or re-registers anything, unless you
  pass `--yes`, and `--dry-run` shows the plan only.
- Unknown keys are errors, so a typo or a newer format can't read as an
  empty runner list and remove everything.

## Alternatives

- **Only commands and the app.** Every setup stays a sequence of manual
  steps.
- **Documenting `config.json` as the user-facing format.** It would freeze
  internal state as a public format.

## Consequences

- A Mac's runners can live in version control, and one command sets them up
  again.
- Renaming a runner in the file removes the old one and adds a new one.
- Changing the global isolation mode re-registers every runner that follows
  it.
- `config.json` stays internal and can change without breaking users.
- Mac Runner depends on Yams to read and write YAML.
