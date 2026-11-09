# Choose an isolation mode

The isolation mode decides what a runner's jobs can reach on your Mac. Pick
one default for all runners, and override it for single runners.

## Pick a mode

| Mode          | Jobs run as                       | Pick it when                                             | Needs                                   |
| ------------- | --------------------------------- | -------------------------------------------------------- | --------------------------------------- |
| **None**      | You, with access to your files    | You trust every workflow that can reach the runner       | Nothing more                            |
| **User**      | The hidden `_macrunner` user      | Jobs build for macOS and shouldn't see your files        | One-time `sudo mac-runner setup`        |
| **Container** | Linux (arm64) in a lightweight VM | Jobs build for Linux, or need a clean machine per runner | macOS 26, Apple Silicon, a Linux kernel |

**None** is the default. Don't use it for repositories where people you
don't trust can open pull requests that run workflows.

## Set up user isolation

User isolation needs the `_macrunner` user. Create it once:

```bash
sudo mac-runner setup
```

Setup creates the hidden user and its home at `/Users/_macrunner`, lets your
account run the runner as that user without a password, and makes **User**
the default for new runners. Setup doesn't move runners you added earlier.
Remove them and add them again to run them as `_macrunner`.

To undo it, stop every runner, then run `sudo mac-runner setup --teardown`.
Teardown deletes the user and its home, with any runner data in it, and sets
the default back to **None**.

## Set up container isolation

Container isolation needs macOS 26 or later on Apple Silicon, and a Linux
kernel at `~/Library/Application Support/MacRunner/vmlinux`. The
[Kata Containers](https://github.com/kata-containers/kata-containers/releases)
kernel works:

```bash
curl -fLO https://github.com/kata-containers/kata-containers/releases/download/3.17.0/kata-static-3.17.0-arm64.tar.xz
tar -xJf kata-static-3.17.0-arm64.tar.xz ./opt/kata/share/kata-containers/vmlinux.container
mkdir -p ~/Library/Application\ Support/MacRunner
cp -L opt/kata/share/kata-containers/vmlinux.container ~/Library/Application\ Support/MacRunner/vmlinux
```

A container runner uses GitHub's `ghcr.io/actions/actions-runner:latest`
image unless you give it another. Your own image must be linux/arm64 and have
`bash`, plus either the runner already installed or `curl` and `tar`. With
`apt-get` in the image, Mac Runner also installs the runner's tools each time
its container starts.

## Change the default for all runners

The default applies to every runner that doesn't override it.

- `sudo mac-runner setup` makes **User** the default, and
  `sudo mac-runner setup --teardown` sets it back to **None**.
- For any mode, set `isolation` under `settings` in `.mac-runner.yml` and
  run `mac-runner apply`. Runners that follow the default register again in
  the new mode. See [Configure runners with a file](configure-with-a-file.md).

`mac-runner status` shows the current default as **Global isolation**.

## Override it for one runner

- In **Add Runner**, set **Isolation Mode** to **None (no isolation)**,
  **User (dedicated user)**, or **Container (macOS 26+)**.
  **Global (from settings)** follows the default.
- From the command line, pass `--isolation`:

  ```bash
  mac-runner add owner/linux-project --isolation container
  mac-runner add owner/linux-project --isolation container --image ghcr.io/myorg/ci-image:latest
  mac-runner add owner/trusted-project --isolation none
  ```

- In `.mac-runner.yml`, set `isolation` on the runner.

The menu shows each runner's mode: 🔓 none, 👤 user, 📦 container, or
🌐 Global for a runner that follows the default.

Details: [Isolation modes](../features/isolation-modes.md),
[User isolation](../features/isolation/user.md),
[Container isolation](../features/isolation/container.md).
