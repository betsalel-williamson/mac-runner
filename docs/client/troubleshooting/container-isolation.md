# Fix container isolation problems

Problems with runners whose isolation mode is **Container**. To set one up,
see [Choose an isolation mode](../choose-isolation.md#set-up-container-isolation).

## Container isolation isn't available

**Symptom:** starting a container runner fails with
`Container isolation requires macOS 26.0+ and is not available on this system`.

**Cause:** container isolation needs macOS 26 or later on Apple Silicon.

**Fix:**

1. Check that the macOS version is 26.0 or later:

   ```bash
   sw_vers -productVersion
   ```

2. Check that the chip is Apple Silicon. This prints `arm64`:

   ```bash
   uname -m
   ```

3. On an older or Intel Mac, use user isolation for macOS jobs instead.

## The Linux kernel isn't found

**Symptom:** starting a container runner fails with
`Container isolation needs a Linux kernel at …/vmlinux`.

**Cause:** Mac Runner doesn't find a kernel inside the app or at
`~/Library/Application Support/MacRunner/vmlinux`.

**Fix:**

1. Install the Kata Containers kernel as in
   [Set up container isolation](../choose-isolation.md#set-up-container-isolation).
2. Check that the file is there and that you can read it:

   ```bash
   ls -la ~/Library/Application\ Support/MacRunner/vmlinux
   ```

3. Quit and open Mac Runner again, so it finds the kernel.

## The container doesn't start

**Symptom:** the runner shows an error, and its output or the start command
shows `Failed to create container` or `Failed to start container`.

**Cause:** Mac Runner can't pull the image, the image doesn't meet the
requirements, or the Mac lacks room for the VM. Each container runner's VM uses 2 CPU cores,
4 GiB of memory, and up to 16 GiB of disk.

**Fix:**

1. Read the runner's output:

   ```bash
   mac-runner logs my-runner
   ```

2. Check that your Mac reaches the registry, such as `ghcr.io` or Docker Hub.
   Mac Runner pulls an image the first time a runner uses it, then reuses the
   local copy.
3. Check a custom image: linux/arm64, with `bash`, and either the GitHub
   Actions runner at `/home/runner`, `/actions-runner`, or `/runner`, or
   `curl` and `tar`. To try GitHub's image instead, add the runner without
   `--image`.
4. Close memory-hungry apps, or stop other container runners.

## A container runner with a display doesn't start

**Symptom:** a container runner with GUI access stops at start, and its
output says `GUI access needs Xvfb, and this image has neither Xvfb nor
apt-get`.

**Cause:** the image can't give the runner a virtual display.

**Fix:** use an image with `Xvfb` installed, or with `apt-get` and a root or
passwordless-`sudo` default user. Or turn off GUI access for the runner.

## The runner stops when you close the terminal

**Symptom:** a container runner you started with `mac-runner add`, `start`,
or `apply` goes offline when the command ends.

**Cause:** a container runner's VM lives inside the process that started it.

**Fix:** start container runners from the menu bar app, which keeps them
running in the background. From the command line, leave the terminal open.

## Stop or remove fails with "runs inside another Mac Runner process"

**Symptom:** stopping or removing a container runner fails with
`This container runner's VM runs inside another Mac Runner process`.

**Cause:** another Mac Runner process, such as a terminal running
`mac-runner start`, or the menu bar app, hosts that runner's VM.

**Fix:** stop it where it runs: press Ctrl-C in that terminal, or stop it in
the menu bar app. Then try again.

## Jobs wait a long time for a new container runner

**Symptom:** the first start of a container runner takes minutes.

**Cause:** Mac Runner pulls the image on first use, and installs the
runner's tools with `apt-get` each time its container starts.

**Fix:** use an image with the GitHub Actions runner and your tools already
installed. Later starts reuse the pulled image.

Details: [Container isolation](../../features/isolation/container.md),
[Isolation modes](../../features/isolation-modes.md).
