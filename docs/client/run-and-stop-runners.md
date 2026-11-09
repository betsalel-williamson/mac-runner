# Run and stop runners

Start, stop, restart, and remove runners from the menu bar, the dashboard, or
the command line.

## From the menu bar

Each runner row has a play or stop button on the right. Right-click a row
for more:

- **Start** or **Stop**.
- **Open Current Job**, while the runner runs a job.
- **View Logs**, **Schedule…**, and **Duplicate**.
- **Remove**, which removes the runner at once, without asking.

Select a repository or organization heading to collapse or expand its
runners.

## From the dashboard

Select the window button at the top of the menu to open the dashboard. Pick a
runner in the list, then use the buttons at the top right:

- **Start** or **Stop**.
- **Logs**, which opens the runner's logs in their own window.
- The trash button, which asks before it removes the runner.

## From the command line

```bash
mac-runner list               # every runner, its status, isolation, and labels
mac-runner start my-runner
mac-runner stop my-runner
mac-runner remove my-runner
```

## Restart a runner

Stop it, then start it. From the command line:

```bash
mac-runner stop my-runner && mac-runner start my-runner
```

## Remove a runner

Removing a runner stops it, unregisters it from GitHub, and deletes its
workspace on your Mac. To remove every runner and every file Mac Runner created,
see [Uninstall the app and its runners](uninstall.md).

## Container runners from the command line

A container runner's Linux VM lives inside the process that started it.

- Started from the menu bar app, it keeps running in the background.
- Started with `mac-runner add`, `start`, or `apply`, the command stays in
  the foreground and prints the runner's output. Press Ctrl-C to stop the
  runner. Leave the terminal open while you want it to take jobs.

To stop a container runner that another Mac Runner process hosts, stop it
there: press Ctrl-C in that terminal, or use the menu bar app.

## Crash recovery

When a runner that the menu bar app started stops on its own, the app starts
it again after a growing delay, up to five times in 10 minutes. Change this in **Settings** with
the restart-on-crash toggle and **Max retries in 10 minutes**.

Details: [Runner lifecycle](../features/runner-lifecycle.md),
[Menu bar](../features/menu-bar.md), [Dashboard](../features/dashboard.md),
[Command line](../features/cli.md).
