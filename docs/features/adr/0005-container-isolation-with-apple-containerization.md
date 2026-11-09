# Linux runners in lightweight virtual machines

## Status

Accepted. Recorded after the fact from the code and history at 74c78d7.

## Context

Many workflows target Linux, and a Linux job running directly on the Mac
can't run at all. Even macOS jobs that run as a service user share the Mac's
kernel, file system, and desktop session. Apple's Containerization framework
runs each Linux container in its own lightweight virtual machine on Apple
silicon, from an Open Container Initiative (OCI) image, without Docker.

## Decision

Offer a container isolation mode that runs a Linux runner in a container
from Apple's Containerization framework.

- **Requirements.** macOS 26 or later on Apple silicon, checked when a runner
  starts. The package itself needs macOS 15, so Mac Runner runs on older
  systems without this mode.
- **Choosing the mode.** A runner uses container isolation when its own
  isolation mode, or the global one, says so. Nothing picks it from labels.
  A container runner's default labels are `linux` and `mac-runner`.
- **No fallback.** On a Mac that can't run containers, or without a kernel,
  starting a container runner fails with an error that says why. Mac Runner
  doesn't switch it to another mode.
- **Framework version.** The package pins `containerization` to an exact
  version, and the guest init image (`vminit`) that Mac Runner requests
  carries the same version. When the pinned version changes, Mac Runner
  rebuilds the cached init file system, under a lock shared by every Mac
  Runner process.
- **Kernel.** The user supplies a Linux kernel as `vmlinux`, in the app's
  `Resources` or in `~/Library/Application Support/MacRunner/`. The Kata
  Containers kernel works. Mac Runner doesn't download or ship one.
- **Image.** GitHub's runner image, `ghcr.io/actions/actions-runner:latest`,
  by default, or any `linux/arm64` image with `bash` chosen per runner. A
  boot script uses the image's Actions runner when it has one and downloads
  it otherwise, installs requested tools with `apt-get` when the image has
  it, and refuses to register a runner whose tools failed to install.
- **Resources.** Each container gets 2 CPUs, 4 GiB of memory, and a sparse
  16 GiB root file system, and uses the `vmnet` shared network.
- **Host directories.** The runner's `_work` and `_diag` directories stay on
  the host, and Mac Runner shares them into the container, so workspaces and logs sit in
  the runner's directory as in the other modes.
- **Lifecycle.** Starting the runner creates its container and registers the
  runner with `--replace`. The container serves jobs until the runner stops,
  in line with [ADR 0003](0003-persistent-registered-runners.md).
- **GUI jobs.** A runner with GUI access gets its own virtual X display,
  registered only once the display accepts connections. Other runners run
  with `CI=true` and `HEADLESS=true`.

The signed app carries the `com.apple.security.virtualization` entitlement,
and the package builds with SwiftPM's sandbox off, because the
Containerization package needs write access during the build.

## Alternatives

- **Docker Desktop or Lima virtual machines.** Mature, but an extra
  dependency to install and run, and not native to macOS.
- **A fresh container per job.** A clean environment for every job, at the
  cost of re-registering after each one.
- **Falling back to the service user** when containers aren't available. A
  Linux job would then run on macOS, where it fails in confusing ways.
- **Downloading or bundling a kernel.** Simpler for users, but Mac Runner
  would have to ship, verify, and update it.

## Consequences

- Linux jobs run on `arm64` Linux. Images and tools must support `arm64`.
- Jobs can't reach the Mac's files outside the shared work and diagnostics
  directories, or its desktop.
- Users must download a kernel before the first container runner starts.
- The first start of a runner pulls its image, and later starts use the cached
  copy.
- Jobs on one container runner share its container until it restarts, so a
  job can affect later jobs on that runner.
- Upgrading the `containerization` package means changing the pinned
  version, and the `vminit` reference with it.
