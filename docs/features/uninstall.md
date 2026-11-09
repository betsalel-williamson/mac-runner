# Uninstall

`mac-runner uninstall` takes a Mac Runner installation apart. It stops
runners, deregisters them from GitHub, and deletes the files Mac Runner
wrote. Deregistering comes first because GitHub keeps listing a runner as
offline in the repository's settings when its files go without notice.
`UninstallService` plans and deletes.

## Steps

1. It lists what it will do: runners to stop, runners to deregister, and every
   path to delete with its size.
2. It asks for confirmation, unless `--yes` skips the question. `--dry-run`
   stops after the list.
3. It stops running runners, so no workspace goes away in the middle of a
   job.
4. It deregisters each runner that has a recorded GitHub ID, unless
   `--keep-runners` keeps the registrations.
5. It deletes each path. For workspaces under `/Users/_macrunner` it uses the
   service user's access, without a password.
6. It removes `~/.mac-runner/runners` and `~/.mac-runner` when nothing else is
   in them.
7. It reports what it freed, what it couldn't remove, and runners it couldn't
   deregister. Those stay listed on GitHub until someone removes them there.

## What uninstall removes

| Location                                                                                             | Holds                                       |
| ---------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| `~/.mac-runner/runners/<id>` and `/Users/_macrunner/.mac-runner/runners/<id>`                        | Runner workspaces                           |
| Workspaces with no runner in the config                                                              | Orphaned workspaces from earlier versions   |
| `~/Library/Application Support/MacRunner`                                                            | `config.json`, process ID files, the kernel |
| `~/Library/Preferences/com.omniaura.mac-runner.plist` and `mac-runner.plist`                         | Preferences and update check state          |
| Mac Runner's folders in `~/Library/Caches`, `~/Library/HTTPStorages`, and saved app state            | Caches                                      |
| Mac Runner's crash and diagnostic reports                                                            | Reports                                     |
| `/Applications/MacRunner.app` and the `mac-runner` links in `/opt/homebrew/bin` and `/usr/local/bin` | Only with `--include-app`                   |

Orphaned workspaces are folders named like a runner ID with no runner in
`config.json`. Uninstall looks for them under the user's home and under the
service user's home when that exists, even when `config.json` is empty.

## Always kept

- Anything else in `~/.mac-runner`, such as `config.yml`. Uninstall deletes
  only runner ID folders there.
- The `_macrunner` user, its home folder, and `/etc/sudoers.d/mac-runner`.
  `sudo mac-runner setup --teardown` removes them, as
  [User isolation](isolation/user.md#teardown) describes.
- The Containerization store with its cached images, in
  `~/Library/Application Support/com.apple.containerization`.
- Tools that Homebrew installed.
- Registrations of runners without a recorded GitHub ID.

## Homebrew

When Homebrew installed the app and `--include-app` is absent, uninstall ends
by suggesting `brew uninstall --cask mac-runner`. Homebrew alone can't
deregister runners or reach the service user's workspaces, so uninstall runs
first.

## Related

- [Uninstall](../client/uninstall.md) in the client guide
- [Disk cleanup](disk-cleanup.md)
