# Pause runners and set schedules

Free your Mac for your own work: pause every runner now, pause on low
battery, or pause during quiet hours each day.

## Pause and resume all runners

In the menu, select **Pause All**. Every running runner stops at once, a job
in progress included, and shows as paused. Select **Resume All** to start the
paused runners again. The dashboard has the same buttons.

## Pause on low battery

1. Open **Settings**.
2. Turn on **Pause Runners on Low Battery**.
3. Set **Pause below** to a percentage, from 5 to 95.

From the command line:

```bash
mac-runner battery on --threshold 25
mac-runner battery off
mac-runner battery            # show the setting and the battery level
```

While on battery below the threshold, runners finish their current job, then
pause. They resume when you plug in or the battery charges past the
threshold. The menu shows a line such as `On battery at 18% — runners paused
until charging`.

## Set quiet hours

Quiet hours pause runners during the same window every day. The window may
cross midnight.

1. Open **Settings**.
2. Turn on **Quiet Hours** and set **From** and **to**.

From the command line:

```bash
mac-runner schedule --start 22:00 --end 06:00
mac-runner schedule --off
mac-runner schedule           # show the schedules
```

Runners finish their current job, then pause, and resume when the window
ends. While the window is active, the menu shows
`Quiet hours active until 06:00`.

## Give one runner its own schedule

1. In the menu, right-click the runner and choose **Schedule…**.
2. Pick one:
   - **Use global** follows the quiet hours from Settings.
   - **Never pause** keeps the runner going through quiet hours.
   - **Custom window** sets this runner's own hours.
3. Select **Save**.

From the command line:

```bash
mac-runner schedule --runner my-runner --start 12:00 --end 13:00
mac-runner schedule --runner my-runner --never
mac-runner schedule --runner my-runner --global
```

Low-battery pausing always applies to every runner.

## Run a paused runner anyway

Start the runner by hand while it's paused for quiet hours or low battery,
and it keeps running for that condition. Another condition, such as low
battery during quiet hours, still pauses it.

## Keep the app running

The menu bar app does the pausing and resuming. Commands such as
`mac-runner schedule` only change the settings, and a running app picks them
up within a few seconds. `mac-runner status` shows the schedules, and which
runners Mac Runner paused and why.

Details: [Auto-pause](../features/auto-pause.md),
[Menu bar](../features/menu-bar.md).
