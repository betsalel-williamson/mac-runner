# Isolate macOS jobs with a dedicated service user

## Status

Accepted. Recorded after the fact from the code and history at 74c78d7.

## Context

By default a runner runs as the person signed in to the Mac, so every job
can read their files and credentials and act on their desktop. macOS jobs
need a real macOS environment, so a Linux container doesn't fit them.

## Decision

Offer a dedicated user isolation mode. `sudo mac-runner setup` creates one
hidden macOS account, `_macrunner`, with a user ID in the system range
(400 to 499), the `staff` group (ID 20), a home at `/Users/_macrunner`, and
no password that can sign in. It installs a `sudoers` entry at
`/etc/sudoers.d/mac-runner`, checked with `visudo`, that lets the signed-in
user, without a password:

- run `/bin/bash -l -c …` and `/bin/zsh -l -c …` as `_macrunner`,
- run `/bin/kill` as root,
- create directories under `/Users/_macrunner/` and give them to
  `_macrunner`.

Mac Runner starts each user-isolated runner as `_macrunner` through `sudo`,
with that user's home, `PATH`, and private temporary directory. Its files
live under `/Users/_macrunner/.mac-runner/runners/`. Setup also makes this
the global isolation mode, and `sudo mac-runner setup --teardown` removes the
account and the `sudoers` entry.

The mode works wherever Mac Runner runs, which is macOS 15 or later.

## Alternatives

- **No isolation.** Still offered as the `none` mode, for trusted
  repositories.
- **One account per runner.** Stronger separation between runners, at the
  cost of more accounts, setup, and `sudoers` entries.
- **Linux containers.** Isolate more strongly but can't run macOS jobs, as described in
  [ADR 0005](0005-container-isolation-with-apple-containerization.md).

## Consequences

- Jobs can't read the signed-in user's private folders, such as
  `~/Documents` and `~/Library`.
- `_macrunner` belongs to the `staff` group, so jobs can still read files
  that the group can read, such as the listing of a home folder with default
  permissions.
- Every user-isolated runner shares the one account and its home, so their
  jobs can reach each other's workspaces.
- Any process running as the signed-in user can run commands as `_macrunner`
  and send signals to any process as root, without a password.
- Setup and teardown need administrator rights, and removing service user
  workspaces needs `sudo`, which `mac-runner uninstall` handles.
