# Updates

Mac Runner checks GitHub for new releases of itself and, for a Homebrew
install, installs them from the menu bar. `UpdateChecker` finds releases and
`UpdateInstaller` runs Homebrew.

## Checking

The menu bar app checks the latest release of `omniaura/mac-runner` on GitHub
when it starts. It skips this automatic check when the last check ran less
than 24 hours ago, and doesn't check again while it keeps running.

- The Updates button in the popover footer and Check for Updates in Settings
  check right away. Within 5 minutes of a check, they reuse its answer.
- Check for Updates Automatically is on by default. When off, the app makes no
  automatic checks and hides any update it found.
- After a failed check, the app keeps showing the last known release, if any.
- The command line doesn't check for updates.

## When a release is newer

- The menu bar icon shows `arrow.down.circle.fill` while no job is running.
  See [Menu bar](menu-bar.md#status-item).
- The popover footer shows an update card. Its close button hides the card
  for that version until the app restarts.

## Installing

What the card offers depends on how Mac Runner came onto the Mac:

| Install                                                                         | Card button     | Does                                  |
| ------------------------------------------------------------------------------- | --------------- | ------------------------------------- |
| Homebrew formula, with the app running from a Homebrew `Cellar` folder          | Install Update  | Runs `brew upgrade mac-runner`        |
| Homebrew cask, with an app bundle named `Mac Runner.app` and a `Caskroom` entry | Install Update  | Runs `brew upgrade --cask mac-runner` |
| Anything else                                                                   | Download Update | Opens the release page on GitHub      |

After Homebrew upgrades the app, the footer asks to quit and reopen Mac
Runner. The running app keeps the old version until then, and runners keep
running.

## Related

- [Install](../client/install.md) in the client guide
