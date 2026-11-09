# Free disk space

Jobs leave checkouts, build output, and dependency caches behind. Clean them
up by hand, or let Mac Runner clean when free space runs low.

## See what a cleanup would remove

```bash
mac-runner cleanup --dry-run
```

The dry run prints how much space a cleanup would free, and from how many
items, without deleting anything.

## Run a cleanup

```bash
mac-runner cleanup
```

Cleanup empties the `_work` folder of each stopped macOS runner, and the
shared CI caches in your home folder: npm, SwiftPM, Homebrew, Go, Cargo,
Gradle, Xcode `DerivedData`, and `~/.cache`.

- It skips any runner that's running, and lists it as skipped.
- While any runner is running, it keeps the shared caches, since a job may
  be using them.
- It doesn't touch container runners.

To keep the shared caches and clean only workspaces:

```bash
mac-runner cleanup --workspaces-only
```

## Clean up when disk space runs low

1. Open **Settings**.
2. Turn on **Clean CI Data When Disk Space Is Low**.
3. Set **Minimum free disk space**, from 10 GB to 500 GB.

Mac Runner checks at most once an hour and cleans only when free space is
below that amount. Active runners' data stays. This is off by default.

Details: [Disk cleanup](../features/disk-cleanup.md).
