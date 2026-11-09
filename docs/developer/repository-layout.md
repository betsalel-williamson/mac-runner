# Repository layout

Mac Runner is one Swift package. Its one target builds the `mac-runner`
executable, which is both the menu bar app and the command line tool (see
[ADR 0001](../features/adr/0001-native-swift-menu-bar-app-and-cli.md)).

## Code

| Path                    | Holds                                                                                                                                                    |
| ----------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `Package.swift`         | The package: the `mac-runner` product, the `MacRunner` target built from every file in `Sources/`, the `MacRunnerTests` target, and the two dependencies |
| `Package.resolved`      | Locked dependency versions                                                                                                                               |
| `Sources/MacRunner/`    | The entry point (`main.swift`), which sends a run with arguments to the command line tool and a run without them to the app, and the SwiftUI app itself  |
| `Sources/Models/`       | `Runner.swift`: runners, app settings, isolation modes, quiet hours, and the saved configuration                                                         |
| `Sources/Services/`     | Everything the app and the command line tool share, listed below                                                                                         |
| `Sources/Views/`        | SwiftUI views: the menu bar menu and settings, the add runner dialog, the dashboard window, the log viewer, schedules, and the animated status item icon |
| `Sources/Utilities/`    | Process helpers: running a command and collecting its output, and walking a process tree                                                                 |
| `Sources/Utils/`        | Process helpers, the open file limit, and the system requirement checks for container isolation                                                          |
| `Tests/MacRunnerTests/` | XCTest unit tests, one file per area, described in [Testing](testing.md)                                                                                 |

`Sources/Utilities/` and `Sources/Utils/` both hold small shared helpers. No
rule separates them. Put a new helper next to the code it resembles.

The services in `Sources/Services/`:

| File                                              | Does                                                                                             |
| ------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| `RunnerManager.swift`                             | Runner lifecycle: add, start, stop, restart, status polling, automatic pausing, and job tracking |
| `CLIHandler.swift`, `CLICommands.swift`           | The command line tool: argument parsing and each command                                         |
| `GHCLIService.swift`                              | Every GitHub call, made through the `gh` command                                                 |
| `RunnerInstaller.swift`                           | Downloads the GitHub Actions runner and registers it with `config.sh`                            |
| `UserIsolationService.swift`, `SetupWizard.swift` | The `_macrunner` service user, its `sudoers` entry, and `mac-runner setup`                       |
| `ContainerIsolationService.swift`                 | Linux containers through Apple's Containerization framework                                      |
| `ContainerRunnerScript.swift`                     | The shell script that boots the runner inside a container                                        |
| `ToolProvisioningService.swift`                   | Which tools to install for a runner                                                              |
| `DeclarativeConfig.swift`                         | `.mac-runner.yml`, `mac-runner apply`, and `mac-runner export`                                   |
| `ConfigService.swift`                             | Reads and writes the saved configuration and resolves runner directories                         |
| `RunnerEnvironment.swift`                         | The environment and `PATH` a runner process starts with                                          |
| `RunnerLogs.swift`, `JobLogTracker.swift`         | Runner logs, rotation, following, and reading jobs from the runner's own log                     |
| `JobNotificationService.swift`                    | Notifications about job activity                                                                 |
| `ResourceMonitor.swift`                           | Per-runner CPU, memory, and disk use                                                             |
| `PowerSourceMonitor.swift`                        | Battery state for pausing on low battery                                                         |
| `DiskCleanupService.swift`                        | `mac-runner cleanup` and automatic disk cleanup                                                  |
| `UninstallService.swift`                          | `mac-runner uninstall`                                                                           |
| `UpdateChecker.swift`, `UpdateInstaller.swift`    | Checking for a new release and upgrading through Homebrew                                        |
| `PIDFileManager.swift`, `ProcessManager.swift`    | Tracking runner processes across app and command line runs                                       |

## Build, release, and repository files

| Path                             | Holds                                                                                                       |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `Makefile`                       | Build, run, test, lint, and packaging targets, described in [Build and test](build-and-test.md)             |
| `justfile`                       | One recipe, `dev`, which builds and starts the app                                                          |
| `scripts/generate-info-plist.sh` | Writes the app bundle's `Info.plist`, taking the version from `VERSION`                                     |
| `scripts/MacRunner.entitlements` | The virtualization entitlement that container isolation needs                                               |
| `scripts/notarize.sh`            | Submits an artifact to Apple's notary service and prints Apple's log when it fails                          |
| `Casks/mac-runner.rb`            | The Homebrew cask, which the release workflow updates and copies to the tap                                 |
| `.github/workflows/ci.yml`       | Pull request checks, described in [Continuous integration](ci.md)                                           |
| `.github/workflows/release.yml`  | The release pipeline, described in [Releasing](releasing.md)                                                |
| `.releaserc.json`                | semantic-release configuration                                                                              |
| `CHANGELOG.md`                   | Release notes, written by semantic-release                                                                  |
| `CONTRIBUTING.md`                | The contributor entry point GitHub links to                                                                 |
| `AGENTS.md`                      | Rules for coding agents working in this repository                                                          |
| `README.md`                      | The project's front page                                                                                    |
| `docs/`                          | Merlon Docs shards, configuration, and Vale styles, described in [Documentation workflow](docs-workflow.md) |
| `.claude/skills/merlon-docs/`    | The Merlon Docs agent skill                                                                                 |
| `skills-lock.json`               | Source and hash of installed agent skills                                                                   |

## Files outside the repository

Mac Runner keeps its state on the Mac, not in the repository:

| Path                                                        | Holds                                                                |
| ----------------------------------------------------------- | -------------------------------------------------------------------- |
| `~/Library/Application Support/MacRunner/config.json`       | Runners and app settings                                             |
| `~/.mac-runner/runners/<id>/`                               | One runner's files, logs, and job workspace                          |
| `/Users/_macrunner/.mac-runner/runners/<id>/`               | The same, for runners that run as the service user                   |
| `~/Library/Application Support/MacRunner/vmlinux`           | The Linux kernel for container isolation, when not in the app bundle |
| `~/Library/Application Support/com.apple.containerization/` | The Containerization framework's image and file system store         |

Runner directories sit outside Application Support because the runner's
scripts break on paths that contain spaces.
