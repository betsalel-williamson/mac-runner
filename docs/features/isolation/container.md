# Container isolation

Container isolation runs a runner as a Linux runner inside its own lightweight
virtual machine, using Apple's Containerization framework. Jobs see only the
container, not the Mac, which suits Linux workflows and untrusted code.

## Requirements

- macOS 26 or later on Apple silicon.
- A Linux kernel file named `vmlinux`, in `MacRunner.app/Contents/Resources/`
  or `~/Library/Application Support/MacRunner/`. The Kata Containers static
  release for `arm64` ships one that works. Without it, a container runner
  fails to start, and the message says where to put the file.
- Network access to the image registry on first use.

Mac Runner checks the kernel and prepares the Containerization store when it
starts. It also downloads the guest init image the first time.

## Images

| Item          | Value                                                                                    |
| ------------- | ---------------------------------------------------------------------------------------- |
| Default image | `ghcr.io/actions/actions-runner:latest`                                                  |
| Own image     | `--image` on `mac-runner add`, the Container Image field, or `image:` in a config file   |
| Registries    | Any public registry of Open Container Initiative images, such as `ghcr.io` or Docker Hub |
| Cache         | Pulled on first use, then kept in the Containerization store                             |

An image works when it's `linux/arm64` and has `bash`, and either:

- has the GitHub Actions runner in `/home/runner`, `/actions-runner`, or
  `/runner`, or
- has `curl` and `tar`, so the container can download the runner when it
  starts.

Automatic tool installation needs `apt-get`. Images without it still run, but
without the tools.

## Resources

Each container runner gets fixed resources:

| Resource         | Value                                 |
| ---------------- | ------------------------------------- |
| CPUs             | 2                                     |
| Memory           | 4 GiB                                 |
| Root file system | 16 GiB, taking disk space as it fills |
| Open files       | The runner's open files limit         |

## Mounts and logs

The container shares only two host folders from the runner's workspace:

| Host folder  | In the container    | Holds                         |
| ------------ | ------------------- | ----------------------------- |
| `<id>/_work` | `/mac-runner/_work` | Job checkouts and outputs     |
| `<id>/_diag` | `/mac-runner/_diag` | The runner's diagnostics logs |

The container's output goes to `runner.log` in the workspace on the host, so
logs work as in the other modes. Jobs can't see `runner.log` itself.

## Networking and hostname

Containers use `vmnet` in shared mode. They reach the network through the
Mac, behind its address. Each container's hostname is the runner's name,
lowercased, with other characters turned into hyphens.

## What happens at start

Each start creates a fresh container from the image, so nothing but `_work`
and `_diag` carries over from the last run. Inside the container a start
script:

1. Finds the Actions runner in the image or downloads the Linux `arm64`
   release.
2. Installs the tools that Mac Runner picked when it added the runner: `gh`
   from GitHub's apt repository, toolchains detected in the repository, and
   the Extra CI Tools from Settings. If installation fails, the runner doesn't
   start, so no job runs without the tools it expects.
3. Starts a virtual display when display access is on. See
   [Display access](../gui-access.md).
4. Runs `config.sh` with a registration token that Mac Runner fetches for this
   start, then starts the runner.

Mac Runner records the runner's GitHub ID once it shows as online, checking
every 5 seconds for up to 2 minutes.

## Lifetime

A container runner's virtual machine lives inside the Mac Runner process that
started it, and that process records itself in the runner's process ID file.

- When the menu bar app starts it, the runner runs in the background while
  the app is open.
- When `mac-runner add`, `start`, or `apply` starts it, the command stays in
  the foreground and streams the runner's output until Ctrl-C stops it.
- Another Mac Runner process can't stop it, and names the process to stop it
  from instead.

## Limits

- Resources are the same for every container runner.
- [Disk cleanup](../disk-cleanup.md) skips container runners' workspaces.
- CPU and memory figures show only in the process that hosts the virtual
  machine.
- Nested virtualization is off.

## Related

- [Isolation modes](../isolation-modes.md)
- [Choose isolation](../../client/choose-isolation.md) in the client guide
