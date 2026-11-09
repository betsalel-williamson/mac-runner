# Automatic pausing

Mac Runner stops runners on its own while the Mac's owner needs the Mac or
its battery, and starts them again afterwards. It pauses for two reasons: low
battery or quiet hours. A runner in the middle of a job finishes the job
first.

## Reasons

| Reason      | Applies when                                                                           | Scope                             |
| ----------- | -------------------------------------------------------------------------------------- | --------------------------------- |
| Low battery | Pause on battery is on, the Mac runs on battery, and the charge is below the threshold | Every runner                      |
| Quiet hours | The time falls inside the runner's quiet hours window                                  | Global, with per-runner overrides |

Low battery takes precedence when both apply. Pause on battery is off by
default, with a threshold of 20 percent that Settings can change to any value
from 5 to 95. `PowerSourceMonitor` reads the internal battery. On a Mac
without one, low battery never applies.

## Quiet hours

A quiet hours window is a daily start and end time, `HH:mm` in 24-hour time,
in the Mac's time zone. A window can cross midnight, such as 22:00 to 06:00.
A window whose start equals its end covers the whole day.

Each runner has one of three schedules:

| Schedule      | Comes from                                                                                                |
| ------------- | --------------------------------------------------------------------------------------------------------- |
| Follow global | The default                                                                                               |
| Own window    | Schedule… in the runner's context menu, `mac-runner schedule --runner`, or `quiet-hours` in a config file |
| Never pause   | The same places, with Never pause, `--never`, or `never`                                                  |

The global window comes from Settings, `mac-runner schedule`, or a config
file. A runner that never pauses for quiet hours still pauses for low
battery.

## How a pause works

Only the menu bar app pauses and resumes runners. It checks every runner on
each status poll, every 10 seconds, and whenever the power source changes:

- **A reason applies to an idle runner:** the app stops it, marks it paused
  with the reason, and writes the event to its log.
- **A reason applies to a busy runner:** the app waits. The runner shows
  "Pausing for … after the current job" and pauses once its job ends.
- **The reason clears:** the app starts each runner that it paused. If that
  start fails, the runner goes to the error state.

When notifications are on, the app posts one notification per reason for the
runners it paused, saying when they resume, and one for the runners it
resumed.

## Starting a paused runner by hand

A runner that the owner starts while paused for a reason keeps running until
that reason clears, and its row says so. A different reason still applies,
such as low battery during quiet hours. Mac Runner saves this choice, so a
start from the command line holds too.

Runners that Pause All stopped stay out of this. Mac Runner doesn't pause
them for a reason or resume them when it clears. See
[Menu bar](menu-bar.md#pausing-and-resuming-every-runner).

## Where it shows

- The menu bar banner and the dashboard sidebar show quiet hours, active or
  not, or runners paused on battery.
- Each runner's row shows why it paused and until when, or that it will pause
  after its job.
- `mac-runner status` and `mac-runner schedule` show the global settings,
  each runner's own schedule, and runners paused now.

## Related

- [Pause and schedules](../client/pause-and-schedules.md) in the client guide
- [Command line](cli.md)
