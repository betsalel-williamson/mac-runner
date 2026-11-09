# Architecture

Mac Runner is one Swift executable that is both a menu bar app and a command
line tool. This shard describes its parts at component level. The code is the
reference for how each part works.

## Entry points

The executable decides what to be from its arguments:

- **No arguments:** it starts `MacRunnerApp`, the menu bar app. The app has no
  Dock icon until one of its windows opens, and hides it again when the last
  window closes.
- **Any arguments:** it hands them to `CLIHandler`, runs one command, and
  exits. See [Command line](cli.md).

The app bundle is `MacRunner.app`. The Homebrew cask also links the
executable into the `PATH` as `mac-runner`.

## Main services

| Service                                              | Job                                                                                               |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `RunnerManager`                                      | Owns the runner list and settings, and drives add, start, stop, remove, and apply                 |
| `ConfigService`                                      | Reads and writes `config.json`                                                                    |
| `RunnerInstaller`                                    | Downloads the GitHub Actions runner and runs its `config.sh`                                      |
| `GHCLIService`                                       | Makes every GitHub call through `gh`: sign-in, repositories, tokens, runner lists, and jobs       |
| `ProcessManager`, `PIDFileManager`                   | Start and stop macOS runner processes and record their process IDs                                |
| `UserIsolationService`, `SetupWizard`                | Create and remove the service user, as [User isolation](isolation/user.md) describes              |
| `ContainerIsolationService`, `ContainerRunnerScript` | Run Linux runners in virtual machines, as [Container isolation](isolation/container.md) describes |
| `ToolProvisioningService`                            | Installs `gh` and detected toolchains for new runners                                             |
| `PowerSourceMonitor`                                 | Reports battery state for [Automatic pausing](auto-pause.md)                                      |
| `ResourceMonitor`                                    | Measures CPU, memory, and workspace size for [Resource monitoring](resource-monitoring.md)        |
| `JobLogTracker`, `JobNotificationService`            | Follow job activity and post [Job notifications](job-notifications.md)                            |
| `RunnerLogs`                                         | Reads, follows, and rotates runner logs                                                           |
| `UpdateChecker`, `UpdateInstaller`                   | Find and install new Mac Runner releases, as [Updates](updates.md) describes                      |
| `DiskCleanupService`                                 | Reclaims space, as [Disk cleanup](disk-cleanup.md) describes                                      |
| `UninstallService`                                   | Removes Mac Runner, as [Uninstall](uninstall.md) describes                                        |
| `DeclarativeConfig`, `ConfigPlanner`                 | Read `.mac-runner.yml` and plan changes for [Declarative config](declarative-config.md)           |

## Where things live on disk

| Path                                                       | Holds                                                              |
| ---------------------------------------------------------- | ------------------------------------------------------------------ |
| `~/Library/Application Support/MacRunner/config.json`      | Runners and settings                                               |
| `~/Library/Application Support/MacRunner/pids/`            | One process ID file per running runner                             |
| `~/Library/Application Support/MacRunner/vmlinux`          | The Linux kernel for container runners, when not in the app bundle |
| `~/Library/Application Support/com.apple.containerization` | Container images and the guest init file system                    |
| `~/.mac-runner/runners/<runner-id>/`                       | A runner's workspace, for no isolation and container isolation     |
| `/Users/_macrunner/.mac-runner/runners/<runner-id>/`       | A runner's workspace under user isolation                          |
| `/etc/sudoers.d/mac-runner`                                | Commands that user isolation runs without a password               |
| `~/Library/Preferences/com.omniaura.mac-runner.plist`      | Update check state                                                 |

Each workspace holds the extracted runner release and its registration, the
`_work` folder where jobs check out code, the `_diag` diagnostics folder, and
`runner.log`. Workspaces live under a dot folder in the home folder because the
runner's scripts break on paths with spaces.

## How the app and the command line share state

The app and every command line run use the same files:

- Each command builds its own `RunnerManager` from `config.json`, does its
  work, saves, and exits.
- A macOS runner is a separate process. Its process ID file lets any Mac
  Runner process see that it's running and stop it. A runner started from the
  command line shows in the app, and the reverse.
- On every status poll the running app reads changes that a command wrote to
  `config.json`. It merges them with its own unsaved changes, so neither side
  overwrites the other.
- A container runner's virtual machine lives inside the process that started
  it, and only that process can stop it. See
  [Container isolation](isolation/container.md#lifetime).
- A command run with `sudo` still reads and writes the invoking user's
  `config.json`, and gives the file back to that user.

Only the app does background work: automatic pausing, job tracking from logs,
notifications, resource measurement, and update checks. A command leaves no
background work behind when it exits.

## Status polling

The app asks GitHub for each target's runner list every 10 seconds, one call
per target. The answer tells it which runners are online and busy. The same
loop also runs automatic disk cleanup and log upkeep, each at most once an
hour.
