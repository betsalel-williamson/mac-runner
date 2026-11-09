# Give a runner a display

Runners are headless by default: their jobs get no display, and get
`CI=true` and `HEADLESS=true`. Turn on GUI access for jobs that need a
screen, such as Xcode UI tests, iOS Simulator tests, browser end-to-end tests,
or screenshot comparisons.

## Turn it on for a new runner

- In **Add Runner**, turn on **Enable GUI Access**.
- From the command line:

  ```bash
  mac-runner add owner/repo --enable-gui --labels macos,mac-runner,gui
  ```

The menu shows 🖥️ GUI on the runner, or ⚫ Headless.

## Turn it on or off for an existing runner

Set `enable-gui` on the runner in `.mac-runner.yml` and run
`mac-runner apply`. Mac Runner restarts the runner if it's running. See
[Configure runners with a file](configure-with-a-file.md).

## Give each runner its own display

How displays work depends on the isolation mode.

- **Container runners** with GUI access each get their own virtual display
  (1920×1080) inside their VM, so windows, focus, and screenshots from one
  runner never touch another's. Linux GUI tests, such as headed browsers and
  Electron apps, run side by side. The image needs `Xvfb`, or `apt-get` with
  a root or passwordless-`sudo` default user so Mac Runner can install it.
  Without either, the runner doesn't start.
- **macOS runners**, with no isolation or user isolation, share the desktop
  of the current login session. The `_macrunner` user can't log in, so it
  gets no desktop of its own.

For macOS UI tests that must not share a screen, keep one GUI runner per Mac
and send those jobs to it with a label of its own, such as `gui`. To run more
in parallel, run Mac Runner in separate macOS VMs, each with one GUI runner.

```yaml
jobs:
  ui-tests:
    runs-on: [self-hosted, macos, gui]
```

Details: [GUI access](../features/gui-access.md),
[Container isolation](../features/isolation/container.md).
