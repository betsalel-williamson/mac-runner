# Add a repository runner

Add a self-hosted runner for one repository. Mac Runner downloads the GitHub
Actions runner, registers it with the repository, and starts it.

You need admin access to the repository and a signed-in `gh`. See
[Install the app](install.md).

## Add a runner from the menu bar

1. Select the Mac Runner icon in the menu bar, then **Add Runner** (the `+`
   button).
2. Leave **Target Type** on **Repository**.
3. Type `owner/repo` under **Repository**, or select **Browse** to pick one of
   your repositories.
4. Optional: fill in the other fields.
   - **Runner Name**: leave it empty for a generated name.
   - **Labels (comma-separated)**: the labels your workflows use in
     `runs-on`. See [Pick labels](#pick-labels).
   - **Isolation Mode**: see [Choose an isolation mode](choose-isolation.md).
   - **Enable GUI Access**: see [Give a runner a display](gui-access.md).
   - **Open Files Limit**: leave it blank to use the default from Settings.
   - **Number of Instances**: add up to 20 runners at once. They're named
     `<name>-1`, `<name>-2`, up to `<name>-20`.
5. Select **Add Runner**.

To add another runner with the same settings, right-click a runner in the
menu and choose **Duplicate**.

## Add a runner from the command line

```bash
mac-runner add owner/repo --name my-runner --labels macos,mac-runner
```

`add` takes these options:

| Option               | What it sets                                              |
| -------------------- | --------------------------------------------------------- |
| `--name <name>`      | The runner name, generated when you leave it out          |
| `--labels <l1,l2>`   | Comma-separated labels                                    |
| `--isolation <mode>` | `none`, `user`, or `container`, the default when left out |
| `--enable-gui`       | GUI access, headless when left out                        |
| `--image <ref>`      | The container image, for `--isolation container` only     |
| `--open-files <n>`   | The open files limit for this runner                      |

Runners you add or start from the command line keep running after you close
the terminal, except container runners. See
[Run and stop runners](run-and-stop-runners.md#container-runners-from-the-command-line).

## Pick labels

A workflow job runs on your Mac when its `runs-on` lists `self-hosted` and
labels your runner has. GitHub adds `self-hosted`, the OS, and the
architecture to every self-hosted runner on its own.

- Without labels, a macOS runner gets `macos` and `mac-runner`, and a
  container runner gets `linux` and `mac-runner`.
- Add a label of your own to send a job to one runner, for example `gui`
  for the runner with GUI access.

```yaml
jobs:
  build:
    runs-on: [self-hosted, macos, mac-runner]
```

## What happens when you add a runner

1. Mac Runner checks your GitHub sign-in and that you can reach the
   repository.
2. It installs `gh` and the toolchains the repository looks like it needs,
   such as Node, Python, Go, Ruby, or Rust, plus any **Extra CI Tools** from
   Settings.
3. It downloads the GitHub Actions runner and registers it with the
   repository. A container runner registers from inside its container when
   it starts.
4. It starts the runner. The runner shows up under the repository in the
   menu and in the repository's **Settings > Actions > Runners** page on
   GitHub.

To check it from the terminal, run `mac-runner list`.

Details: [Runner lifecycle](../features/runner-lifecycle.md),
[Command line](../features/cli.md).
