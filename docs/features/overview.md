# Overview

Mac Runner runs and manages GitHub Actions self-hosted runners on a Mac. One
app holds three ways in: a menu bar item for a glance and quick controls, a
dashboard window for detail and logs, and a `mac-runner` command line for
scripts and terminals. All three work on the same runners.

## Who it's for

Mac Runner is for developers and small teams who want CI jobs to run on a Mac
they already use, without a separate build server. It suits a Mac that is also
someone's work machine. Runners pause on battery or at night, and the owner
can pause them all at once from the menu bar.

## What it does

- Runs many runners on one Mac, each in its own workspace. GitHub's runner
  tooling sets up one runner per folder, and Mac Runner manages the folders.
- Registers runners through the GitHub CLI (`gh`), so nobody pastes a
  personal access token into the app.
- Downloads, configures, registers, and starts each runner in one step.
- Keeps jobs away from the owner's files, either as a dedicated macOS user or
  in a Linux virtual machine.
- Keeps runners running across app restarts and restarts runners that crash.
- Pauses runners for low battery and quiet hours, after the current job ends.
- Shows each runner's current job, recent jobs, resource use, and logs.
- Reads a whole setup from a file and makes it real with `mac-runner apply`.

## Runner targets

Every runner registers with one target:

| Target       | Identifier   | Who can send it jobs                                      |
| ------------ | ------------ | --------------------------------------------------------- |
| Repository   | `owner/repo` | Workflows in that repository                              |
| Organization | `org`        | Repositories that the organization's runner group lets in |

See [Organization runners](organization-runners.md).

## Requirements

- macOS 15 or later. Container isolation needs macOS 26 and Apple silicon.
- The GitHub CLI, installed and signed in with `gh auth login`.
- Homebrew, for the tools Mac Runner installs for macOS runners.

## Feature map

| Area                      | Shards                                                                                                                                                                     |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| How it works              | [Architecture](architecture.md)                                                                                                                                            |
| Runners                   | [Runner lifecycle](runner-lifecycle.md), [Organization runners](organization-runners.md), [Declarative config](declarative-config.md), [Cloud fallback](cloud-fallback.md) |
| Isolation                 | [Isolation modes](isolation-modes.md), [Display access](gui-access.md)                                                                                                     |
| The app                   | [Menu bar](menu-bar.md), [Dashboard](dashboard.md), [Command line](cli.md)                                                                                                 |
| Running in the background | [Automatic pausing](auto-pause.md), [Resource monitoring](resource-monitoring.md), [Job notifications](job-notifications.md)                                               |
| Maintenance               | [Disk cleanup](disk-cleanup.md), [Updates](updates.md), [Uninstall](uninstall.md)                                                                                          |

To get started, see [Install](../client/install.md) and
[Add a runner](../client/add-a-runner.md) in the client guide.
