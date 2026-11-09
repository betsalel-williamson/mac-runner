# Display access

Runners are headless by default. With GUI access on, a runner's jobs can use
a display, for visual tests, browser tests in a window, Xcode UI tests, and
app automation.

## Headless

A headless runner starts without the display variables `DISPLAY`,
`WAYLAND_DISPLAY`, `XDG_SESSION_TYPE`, and `XDG_RUNTIME_DIR`, and with
`CI=true` and `HEADLESS=true`. Tools that read these variables run without a
window. The variables are hints to tools. On macOS they don't stop a process
from opening windows.

## With display access

| Mode                                | Display                                                       |
| ----------------------------------- | ------------------------------------------------------------- |
| [None](isolation/none.md)           | The signed-in user's desktop                                  |
| [User](isolation/user.md)           | The signed-in user's desktop                                  |
| [Container](isolation/container.md) | Its own virtual X display inside the runner's virtual machine |

### Separate displays for container runners

A container runner with GUI access starts `Xvfb` on display `:99` at
1920×1080 with 24-bit color and sets `DISPLAY` for its jobs. Each runner has
its own virtual machine, so windows, focus, and screenshots from one runner
never reach another. Linux GUI tests can run side by side.

The image needs `Xvfb`, or `apt-get` with a default user that's root or has
`sudo` without a password, so the container can install it. If the display
can't start, the runner doesn't start, so no GUI job runs without a display.

### Shared desktop for macOS runners

macOS gives a user a separate GUI session only when that user logs in at the
login window. `_macrunner` has no password, so Mac Runner can't create one.
macOS runners with GUI access therefore share the desktop of whoever has
logged in. For parallel macOS UI tests, keep one runner with GUI access per
Mac and target it with a label, or run Mac Runner in separate macOS virtual
machines.

## Turning it on

GUI access comes with adding a runner: `--enable-gui` on `mac-runner add`,
or the Enable GUI Access switch in the Add Runner sheet. To change it later,
set `enable-gui` in a [config file](declarative-config.md) and apply it. A
running runner restarts to pick up the change.

How to set it up: [GUI access](../client/gui-access.md) in the client guide.
