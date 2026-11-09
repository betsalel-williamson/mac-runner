# Testing

The unit tests check Mac Runner's logic without GitHub, a real runner, or a
container. A change that touches isolation also needs the manual checks
below, on a Mac that can run that mode. How to run the suite:
[Build and test](build-and-test.md#run-the-tests).

## What the unit tests cover

| File                            | Covers                                                                                                                                                                                                                            |
| ------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `IsolationModeTests.swift`      | Encoding and decoding each isolation mode, display names and icons, and that an unknown mode reads as no isolation                                                                                                                |
| `RunnerModelTests.swift`        | The runner model, older saved runners without newer fields, and how a runner's own isolation, open file limit, and schedule override the global ones                                                                              |
| `AppSettingsTests.swift`        | App settings defaults, encoding, and older saved settings                                                                                                                                                                         |
| `RunnerConfigTests.swift`       | The saved configuration with runners in different isolation modes, round trips, and older files                                                                                                                                   |
| `ContainerRunnerTests.swift`    | Container runners: the default image, tool to package mapping, the registration environment, the boot script, Linux default labels, host names, and GUI displays                                                                  |
| `DeclarativeConfigTests.swift`  | `.mac-runner.yml`: parsing the documented example, defaults, rejected files, export round trips, and the plan `apply` makes for each kind of change                                                                               |
| `RunnerInstallerTests.swift`    | Choosing the runner version, download URLs, and the commands that install and launch a runner as the service user                                                                                                                 |
| `RunnerNamingTests.swift`       | Base names for numbered runners                                                                                                                                                                                                   |
| `AutoPauseTests.swift`          | Quiet hours, pausing on low battery, battery readings, the `schedule` and `battery` commands, and merging configuration edits made by another Mac Runner process                                                                  |
| `JobLogTrackerTests.swift`      | Reading jobs and their results from the runner's own log                                                                                                                                                                          |
| `RunnerLogsTests.swift`         | Log tails, filters, rotation, following, and diagnostics logs                                                                                                                                                                     |
| `ResourceMonitorTests.swift`    | CPU, memory, and disk measurements, and resource alerts                                                                                                                                                                           |
| `DashboardTests.swift`          | Job history in the dashboard window                                                                                                                                                                                               |
| `StatusItemIconTests.swift`     | The menu bar icon's animation and tooltip                                                                                                                                                                                         |
| `DiskCleanupServiceTests.swift` | Which caches cleanup removes and keeps                                                                                                                                                                                            |
| `UninstallServiceTests.swift`   | What `uninstall` finds and removes, including service user workspaces                                                                                                                                                             |
| `UpdateCheckerTests.swift`      | Version comparison, check caching, and spotting a Homebrew install                                                                                                                                                                |
| `UpdateInstallerTests.swift`    | The Homebrew upgrade command                                                                                                                                                                                                      |
| `MacRunnerTests.swift`          | Smaller areas: launch at login, finding the container kernel, detecting the service user, the version shown by the command line tool, runner environments and `PATH`, `gh` sign-in messages, tool provisioning, and notifications |

Add tests to the file for the area you change. A change to how a saved file
decodes needs a test that older files still load.

## Manual checks for isolation changes

Nothing in the suite registers a runner with GitHub, runs a job, creates the
service user, or boots a container. When a change touches an isolation mode,
run the checks for that mode, and the shared checks, before you merge.

### Before you start

- A repository where you can add self-hosted runners, with a workflow you can
  start by hand that prints `whoami`, `uname -a`, and the working directory.
- `gh auth status` reports a signed-in account.
- For the service user: macOS 15 or later, and `sudo mac-runner setup`
  completed.
- For containers: an Apple silicon Mac with macOS 26 or later, and a Linux
  kernel at `~/Library/Application Support/MacRunner/vmlinux`.
- A build of the change, either `make install` or `.build/debug/mac-runner`.

### No isolation

1. `mac-runner add owner/repo --name check-none --isolation none`, then
   `mac-runner start check-none`.
2. Run the workflow on the runner's labels. It prints your own user name.
3. `mac-runner stop check-none`. The runner shows as offline on GitHub.

### Service user

1. `mac-runner add owner/repo --name check-user --isolation user`, then
   start it.
2. Run the workflow. It prints `_macrunner`, and the working directory is under
   `/Users/_macrunner/.mac-runner/runners/`.
3. Add a step that reads a file in your `~/Documents`. The step fails with a
   permission error.
4. Stop the runner. No process owned by `_macrunner` remains
   (`ps -U _macrunner`).
5. `sudo mac-runner setup --teardown` removes the user and its `sudoers`
   entry. Run `sudo mac-runner setup` again afterward if you still need it.

### Container

1. `mac-runner add owner/repo --name check-linux --isolation container`. The
   runner's labels default to `linux` and `mac-runner`.
2. Start it. The first start pulls the image, so it takes longer than later
   starts.
3. Run a workflow with `runs-on: [self-hosted, linux]`. `uname -a` reports
   Linux on `aarch64`, and the job opens no windows or disk images on the Mac.
4. `mac-runner logs check-linux` shows the container's output.
5. Stop it, then start it again. It starts cleanly, without an error about an
   existing container.
6. Add a runner with `--image` set to another image that meets the image
   requirements in the README, and repeat steps 2 and 3.
7. Add a runner with `--enable-gui`. A job sees a `DISPLAY` variable. A runner
   without it sees `CI=true` and `HEADLESS=true` instead.
8. Move the kernel file away and start a container runner. The start fails
   with an error that names the kernel path and where to get a kernel. Put the
   kernel back.

On a Mac that can't run containers, older than macOS 26 or not Apple silicon,
starting a container runner fails with an error that says so. Mac Runner
doesn't fall back to another mode.

### Every mode together

1. Run one runner in each mode at once, and run a job on each. They don't
   interfere.
2. Leave one runner without its own isolation mode, so it follows the global
   one. Change the global mode with `settings.isolation` in `.mac-runner.yml`
   and `mac-runner apply`. The plan re-registers that runner, and its next job
   runs in the new mode. A runner with its own mode keeps it.
3. In the app's add runner dialog, choosing Container swaps the default labels
   to the Linux ones and shows the macOS 26 warning and the image field.
4. The dashboard window shows each runner's isolation mode, marked as global
   when it follows the global mode.
5. `mac-runner uninstall` removes runners from GitHub and deletes the service
   user's workspaces.
