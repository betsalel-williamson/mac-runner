# Dashboard

The dashboard is a full window for watching runners. It lists every runner
on the left, and shows the selected runner's status, settings, jobs, and logs
on the right. `DashboardView` draws it, and `LogViewerView` draws the log
viewer inside it.

## Opening it

- The Open Dashboard button in the menu bar popover.
- Opening Mac Runner again from Finder, Spotlight, or the Dock.

The window remembers its size and place. While it's open, Mac Runner shows a
Dock icon.

## Sidebar

The top of the sidebar sums up all runners:

- Counts of runners executing, idle, paused, stopped, and in error.
- Total CPU, memory, and disk across running runners.
- The pause summary, as in the menu bar.

Below it, the sidebar lists runners in sections by target. Each row shows the
name, a status badge (`EXECUTING`, `IDLE`, `PAUSED`, `STOPPED`, or `ERROR`),
and either the runner's resource use or its pause status.

The toolbar has Add Runner, Pause All, Resume All, and Settings.

## Runner detail

| Part          | Shows                                                                                                         |
| ------------- | ------------------------------------------------------------------------------------------------------------- |
| Header        | Name, target, status badge, Start or Stop, Logs (opens a separate window), and Remove                         |
| Configuration | Scope, isolation, image and tools for a container runner, display, labels, open files, quiet hours, GitHub ID |
| Activity      | Current job with a link to its run, CPU, memory, workspace size, processes, schedule status, last event       |
| Recent Jobs   | Up to 20 jobs since the app started, newest first, with their result and start time                           |
| Logs          | The log viewer for this runner                                                                                |

Remove asks for confirmation, then deregisters the runner and deletes its
workspace. Errors from Start, Stop, or Remove show under the header.

Recent Jobs keeps jobs in memory only, so the list starts empty each time the
app starts. See [Job notifications](job-notifications.md) for where jobs come
from.

## Log viewer

The log viewer shows one runner's logs and follows them as they grow. It
appears in the dashboard and in its own window, which View Logs or the Logs
button opens. Each runner has one log window.

| Source | File                                                          |
| ------ | ------------------------------------------------------------- |
| Output | `runner.log`, the runner's output and Mac Runner's own events |
| Runner | The newest `_diag/Runner_*.log`, one per runner start         |
| Job    | The newest `_diag/Worker_*.log`, one per job                  |

- It loads the last 5,000 lines and checks for new lines every second.
- When a newer diagnostics file appears, it switches to it.
- The filter keeps lines that contain the text, ignoring case.
- With Follow on, it scrolls to each new line.
- Buttons copy the shown lines, export them to a file, and show the log file
  in Finder.
- The status line shows how many lines match and the file's path.

## Log files

Mac Runner adds its own events to `runner.log`, such as crashes, restarts,
and pauses, as lines with a timestamp and `[mac-runner]`. It keeps the logs
from growing without limit:

| Log           | Kept                                                                                 |
| ------------- | ------------------------------------------------------------------------------------ |
| `runner.log`  | Past 10 MB, rotates into `runner.log.1` to `.3`, at each start and hourly while idle |
| `_diag/*.log` | Deleted after 7 days, at each start and hourly                                       |

`mac-runner logs` reads the same three sources from the command line. See
[Command line](cli.md).

## Related

- [Menu bar](menu-bar.md)
- [Logs and status](../client/logs-and-status.md) in the client guide
