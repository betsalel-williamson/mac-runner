# No isolation

With no isolation, a runner runs as the user who started it, directly on
macOS. It's the default mode and needs nothing beyond Mac Runner itself.

## How it runs

- The workspace is `~/.mac-runner/runners/<id>`, owned by that user.
- `ProcessManager` starts the runner's `run.sh` through `bash`, after setting
  the open files limit with `ulimit -n`.
- The runner gets the user's environment, with the Homebrew folders
  (`/opt/homebrew/bin`, `/usr/local/bin`, and their `sbin` folders) first on
  `PATH`. Mac Runner saves this `PATH` in the workspace's `.path` file.
- The [display access](../gui-access.md) setting decides whether display
  variables stay in the environment.

## Limits

- Jobs can read and change everything the user can, such as files, keys in
  the home folder, and other apps' data. Use this mode only for trusted
  workflows.
- Jobs share the user's Homebrew, caches, and tools with everything else on
  the Mac.

## Related

- [Isolation modes](../isolation-modes.md)
- [User isolation](user.md)
