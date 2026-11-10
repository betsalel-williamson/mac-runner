# Runners registered once and kept between jobs

## Status

Accepted. Recorded after the fact from the code and history at 74c78d7.

[ADR 0008](0008-one-job-runners-option.md) proposes one-job runners as an
option beside this default.

## Context

A self-hosted runner can register for a single job and remove itself
afterward, or register once and take job after job. Mac Runner manages
runners that a person adds, names, starts, and stops from the menu bar or
the command line, and shows their status and jobs.

## Decision

Register each runner once with the GitHub Actions runner's `config.sh`,
passing `--unattended` and `--replace`, then run its `run.sh` as a
long-lived process that takes job after job. The registration and the
runner's directory, under `~/.mac-runner/runners/<id>/`, stay until you
remove the runner. A container runner registers again each time its
container starts, under the same name, and its job workspace stays on the
host.

Mac Runner downloads the latest runner release when it installs a runner,
and falls back to a known version when that lookup fails or returns an
older one.

## Alternatives

- **Ephemeral runners.** Each runner registers for one job with
  `--ephemeral`, and Mac Runner replaces it afterward. Every job would start clean, but
  Mac Runner would need to re-register after each job, and a runner's name
  and history would no longer map to one long-lived thing to start and stop.

## Consequences

- Jobs run on a machine that earlier jobs used. Workspaces, caches, and
  anything else a job leaves behind persist, so a job can affect later jobs
  on the same runner. Use runners only for repositories whose workflows you
  trust, and use an isolation mode to keep jobs away from your own account.
- Workspaces and caches grow, so Mac Runner has `mac-runner cleanup` and
  automatic disk cleanup.
- Removing a runner must remove it from GitHub, not only from disk, or it
  stay listed as offline. `mac-runner remove` and `mac-runner uninstall` do
  this.
- Mac Runner restarts a runner that exits unexpectedly.
- GitHub rejects runner versions that fall too far behind, so the fallback
  version needs regular updates.
- Pausing a runner, for quiet hours or low battery, stops it taking jobs
  without removing its registration.
