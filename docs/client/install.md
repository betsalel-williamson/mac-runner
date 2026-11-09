# Install the app

Install the app, sign in to GitHub with the GitHub CLI, and open Mac Runner
from the menu bar.

## Check what you need

- A Mac with macOS 15 or later.
- For container isolation: macOS 26 or later on Apple Silicon. See
  [Choose an isolation mode](choose-isolation.md).
- The [GitHub CLI](https://cli.github.com/) (`gh`), installed with Homebrew
  and signed in. Mac Runner makes every GitHub call through `gh`, so you
  never paste a personal access token into it.
- Admin access to each repository, or organization, you add a runner for.

You don't need Xcode to run Mac Runner. Install it only if your own jobs
build with it.

## Install and sign in to `gh`

```bash
brew install gh
gh auth login
```

Mac Runner looks for `gh` at `/opt/homebrew/bin/gh` or `/usr/local/bin/gh`,
where Homebrew puts it.

## Install with `brew`

```bash
brew install --cask omniaura/tap/mac-runner
```

The cask puts `MacRunner.app` in `/Applications` and links the
`mac-runner` command into your path.

## Install from a download

1. Download the latest disk image (`.dmg`) from the
   [releases page](https://github.com/omniaura/mac-runner/releases).
2. Open it and drag **MacRunner.app** to **Applications**.
3. To use the command line, link the app's binary into your path:

   ```bash
   sudo ln -s /Applications/MacRunner.app/Contents/MacOS/MacRunner /usr/local/bin/mac-runner
   ```

## Open the app the first time

1. Open **MacRunner** from Applications, or run
   `open /Applications/MacRunner.app`. A running-figure icon appears in the
   menu bar. Mac Runner has no Dock icon.
2. Select the icon. With no runners yet, the menu says **No runners
   configured** and offers **Add Runner**.
3. To check the GitHub sign-in, open **Settings**, then the **GitHub** tab.
   If it says **Not authenticated**, select **Sign in with GitHub**.

From the terminal, `mac-runner auth` shows the same sign-in status, and
`mac-runner version` shows the installed version.

## Start the app at login

In **Settings**, turn on **Launch at Login**. Mac Runner then starts when you
log in and starts again the runners that were running before.

Next: [Add a repository runner](add-a-runner.md).

Details: [Mac Runner overview](../features/overview.md),
[Menu bar](../features/menu-bar.md), [Command line](../features/cli.md).
