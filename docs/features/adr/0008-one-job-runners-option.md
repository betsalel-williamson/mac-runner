# One-job runners as an option beside long-lived runners

## Status

Proposed. Not built, and not yet discussed with upstream.

Adds an option beside [ADR 0003](0003-persistent-registered-runners.md),
which stays the default.

## Context

Mac Runner's runners register once and take job after job
([ADR 0003](0003-persistent-registered-runners.md)). That suits a person who
runs a few runners on their own Mac and starts and stops each one by name.

A team that runs runners for many repositories needs something else: to
upgrade Mac Runner, the runner, or a runner's image at any time without
costing a running job. Today that isn't possible:

- A long-lived runner keeps the version and environment it started with
  until something restarts it, and a restart can stop the job it's running.
- A container runner's virtual machine runs inside the Mac Runner process
  ([ADR 0005](0005-container-isolation-with-apple-containerization.md)), so
  quitting or upgrading Mac Runner stops its jobs.
- Upgrading Mac Runner asks you to quit and reopen it, and nothing checks
  for running jobs first. Stopping or pausing a runner stops it even while
  it runs a job.

## Decision

Add three options. Each is off by default, so a runner set up today keeps
working as it does now.

- **One-job runners.** A runner registers for one job, with a just-in-time
  configuration or `--ephemeral`, and exits after it. Mac Runner then starts
  the runner again from the current version, so a new version reaches the
  next job without stopping the current one. The runner keeps its name and
  its place in the menu bar.
- **Virtual machines outside the app.** A container runner's virtual
  machine runs in Apple's `container` service, or another process outside
  Mac Runner, so quitting or upgrading Mac Runner leaves running jobs alone.
  Mac Runner finds its runners again by name and label when it starts.
- **Draining quit and upgrade.** Quitting or upgrading first stops runners
  taking jobs, then waits for running jobs to finish, then quits or
  relaunches. Stopping or pausing a runner works the same way: it never
  stops a job in progress unless you choose to stop it now.

## Alternatives

- **Replace long-lived runners outright.** Simpler to maintain, but it would
  change how existing setups behave and lose what
  [ADR 0003](0003-persistent-registered-runners.md) gives a single person.
- **Keep the difference in a fork.** Avoids the upstream discussion, but the
  fork would drift from upstream with every release.

## Consequences

- Teams can roll out a new version of Mac Runner, the runner, or an image
  at any time. Running jobs finish on the old version, and the next job uses
  the new one.
- With one-job runners, each job starts without what earlier jobs left
  behind, which also removes the carry-over risk that
  [ADR 0003](0003-persistent-registered-runners.md) describes.
- Mac Runner must tell a runner that is between jobs, restarting for its
  next job, from one that has stopped.
- Moving virtual machines out of the app needs the `container` service or
  another host process, and a way for Mac Runner to find runners it didn't
  start in this session.
- Each option needs its own upstream pull request, proposed one at a time.
