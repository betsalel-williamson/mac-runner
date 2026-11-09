# Menu bar

The menu bar item is Mac Runner's always-there view. It shows whether jobs
are running, and its popover lists every runner with the controls an owner
needs most. `MenuBarView` draws the popover and `StatusItemIcon` picks the
icon.

## Status item

The item shows an SF Symbol, drawn as a template so it follows the menu bar's
appearance:

| State                               | Icon                                                        |
| ----------------------------------- | ----------------------------------------------------------- |
| No job running                      | `figure.run`                                                |
| No job running, update available    | `arrow.down.circle.fill`                                    |
| At least one runner executing a job | Alternates `figure.run` and `figure.walk` every 0.4 seconds |
| Executing, with Reduce Motion on    | `figure.run.circle.fill`, still                             |

A running job takes priority over the update badge. The tooltip reads
`Mac Runner`, followed by the number of jobs running and `update available`
when they apply. Selecting the item opens or closes the popover, and selecting
anywhere else closes it.

## Popover layout

From top to bottom:

1. **Header:** the app name, an Open Dashboard button, and an Add Runner
   button that opens the Add Runner sheet.
2. **Pause banner:** shown when quiet hours exist or runners have paused on
   battery. It turns orange while a pause is in effect. See
   [Automatic pausing](auto-pause.md).
3. **Runner list:** see below. With no runners, an Add Runner prompt.
4. **Total resources:** `All runners:` with total CPU, memory, and disk, when
   Mac Runner has figures for more than one runner.
5. **Pause All and Resume All:** see below.
6. **Footer:** see below.

## Runner list

The list groups runners by target, and sorts groups by identifier and runners
by name. A group header shows a folder icon for a repository or a building
icon for an organization, the target, and how many runners it holds.
Selecting a header collapses or expands the group.

Each runner row shows:

- A status dot: green running, gray stopped, orange paused, red error.
- The name, with `EXECUTING` or `IDLE` while running, and the target.
- A `View` link to the current workflow run, when a job is running and Mac
  Runner knows its run.
- Chips for the isolation mode (or `Global` when the runner follows the
  global default), GUI access or headless, the runner's own quiet hours, and
  each label.
- CPU, memory, and workspace size while running.
- Pause status, such as a pause waiting for the current job, and the last
  restart event.
- A Start or Stop button.

## Context menu

The context menu of a row offers:

| Item             | Shown when                       | Does                                                                             |
| ---------------- | -------------------------------- | -------------------------------------------------------------------------------- |
| Stop or Start    | Always, by state                 | Stops or starts the runner                                                       |
| Open Current Job | Executing a job with a known run | Opens the run on GitHub                                                          |
| View Logs        | Always                           | Opens the runner's log window, as [Dashboard](dashboard.md#log-viewer) describes |
| Schedule…        | Always                           | Sets the runner's own quiet hours                                                |
| Duplicate        | Always                           | Adds a copy with the next free name                                              |
| Remove           | Always                           | Removes the runner at once, without asking                                       |

## Pausing and resuming every runner

Pause All stops every running runner at once and marks it paused, ending any
job in progress. Resume All starts every paused runner, including runners
that paused on their own. Each button is off when there is nothing to act on.
Pause All doesn't wait for jobs to finish, unlike
[automatic pausing](auto-pause.md), and runners it pauses stay paused until
resumed.

## Footer

- A red line when nobody has signed in to `gh`, with the command that fixes
  it.
- An update card when an update is available, with Install Update or Download
  Update and a button that hides the card for that version. See
  [Updates](updates.md).
- Settings, Updates (check now), and Quit buttons.
- The update status, such as when the last check ran.

Quitting the app stops container runners, whose virtual machines live in it.
macOS runners keep running as separate processes.

## Settings window

Settings has three tabs:

| Tab     | Holds                                                                                                                                                                                    |
| ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| General | Launch at Login, update checks, crash restarts, disk cleanup, pausing on battery and quiet hours, resource warnings, job notifications, the default open files limit, and Extra CI Tools |
| GitHub  | Whether someone has signed in to `gh`, and Sign in with GitHub, which runs `gh auth login --web`                                                                                         |
| About   | The version and Check for Updates                                                                                                                                                        |

## Related

- [Dashboard](dashboard.md)
- [Logs and status](../client/logs-and-status.md) in the client guide
