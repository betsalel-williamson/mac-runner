# Watch status, resources, and logs

See what your runners are doing, how much of your Mac they use, and what
they printed.

## Read status in the menu

- The menu bar icon runs while any runner runs a job. With Reduce Motion
  on, it shows a filled icon instead.
- Each runner row has a status dot: green for running, gray for stopped,
  orange for paused, red for an error.
- A running runner shows **EXECUTING** during a job, with a link to the
  workflow run, and an idle badge between jobs.
- The menu shows the CPU and memory use of each running runner. With more
  than one running, an **All runners** line shows the total.

## Use the dashboard

Select the window button at the top of the menu to open the dashboard. Pick a
runner to see its settings, its current job, its CPU, memory, and workspace
size, and **Recent Jobs** since Mac Runner started. Select a job to open its
run on GitHub.

## Check status from the command line

```bash
mac-runner status
```

`status` shows how many runners run, stop, or pause, the GitHub sign-in,
the quiet hours and low-battery settings, and the default isolation mode.

```bash
mac-runner status --resources
```

`--resources` shows CPU, memory, workspace size, and process count for each
running runner, and the total. Mac Runner adds up CPU across processes, so
100% is one core.

## Get notified

- **Job Notifications**, on by default in **Settings**, shows a macOS
  notification when a runner starts a job and when the job finishes. Select
  the notification to open the run on GitHub.
- In **Settings**, turn on notifications for high resource usage, and set
  limits for total CPU and memory. Mac Runner notifies you once when all runners
  together pass a limit.

## Read logs in the app

Right-click a runner in the menu and choose **View Logs**, or select **Logs**
in the dashboard. The log window has:

- **Output**, **Runner**, and **Job**: the runner's output, its diagnostics
  log, and the newest job's diagnostics log.
- **Filter**, which shows only lines that contain the text.
- **Follow**, which keeps showing new lines as they arrive.
- Buttons to copy the shown lines, export them to a file, and show the log
  file in Finder.

## Read logs from the command line

```bash
mac-runner logs my-runner                # last 50 lines of output
mac-runner logs my-runner -n 200         # last 200 lines
mac-runner logs my-runner --follow       # keep printing; Ctrl-C to stop
mac-runner logs my-runner --diag         # the runner's diagnostics log
mac-runner logs my-runner --job          # the newest job's diagnostics log
```

Mac Runner keeps logs from filling your disk. It rotates the output log at
10 MB and keeps three older copies, and it deletes diagnostics logs older
than 7 days when the runner starts.

Details: [Resource monitoring](../features/resource-monitoring.md),
[Job notifications](../features/job-notifications.md),
[Dashboard](../features/dashboard.md), [Menu bar](../features/menu-bar.md),
[Command line](../features/cli.md).
