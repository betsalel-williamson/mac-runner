# Disk cleanup

CI jobs leave large checkouts and dependency caches behind. Disk cleanup
reclaims that space without touching anything a running job could be using.
It runs on demand with `mac-runner cleanup`, or on its own when free space
runs low. `DiskCleanupService` does the work.

## What cleanup deletes

Cleanup deletes the contents of these folders, not the folders themselves:

| Folder                                       | When                              |
| -------------------------------------------- | --------------------------------- |
| Each runner's `_work` folder                 | That runner isn't running or busy |
| `~/.cache`                                   | No runner is running or busy      |
| `~/.npm/_cacache` and `~/.npm/_npx`          | No runner is running or busy      |
| `~/.cargo/registry/cache` and `~/.cargo/git` | No runner is running or busy      |
| `~/.gradle/caches`                           | No runner is running or busy      |
| `~/Library/Caches/Homebrew`                  | No runner is running or busy      |
| `~/Library/Caches/go-build`                  | No runner is running or busy      |
| `~/Library/Caches/org.swift.swiftpm`         | No runner is running or busy      |
| `~/Library/Developer/Xcode/DerivedData`      | No runner is running or busy      |

The shared caches belong to the user who runs cleanup, and any job could be
using them. Cleanup therefore leaves them all alone while any runner is
running. Stopped and paused runners count as not running.

## Always skipped

- The workspace of a runner that's running or busy.
- Every shared cache while any runner is running.
- Container runners' workspaces.
- Everything in a workspace outside `_work`, such as the runner release and
  its registration.
- The service user's own caches under `/Users/_macrunner`.

## On demand

`mac-runner cleanup` reports the space it reclaimed and the active runners it
skipped. `--dry-run` reports without deleting. `--workspaces-only` keeps every
shared cache.

## Automatic cleanup

Clean CI Data When Disk Space Is Low is off by default. When on, the menu bar
app checks free space at most once an hour. When the free space on the home
volume drops below the target, it runs a full cleanup, shared caches
included. The target is 100 GB by default, and Settings can change it to any
value from 10 to 500 GB.

## Related

- [Disk cleanup](../client/disk-cleanup.md) in the client guide
- [Uninstall](uninstall.md), which removes everything instead
