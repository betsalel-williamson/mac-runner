# Uninstall the app and its runners

Remove your runners from GitHub and every file Mac Runner created. Run
`mac-runner uninstall` before you delete the app, so your runners don't stay
listed on GitHub as offline.

## See what uninstall would remove

```bash
mac-runner uninstall --dry-run
```

The dry run lists the runners it would unregister and each folder and file
it would delete, with sizes. Run it even with no runners left: it also finds
workspaces that earlier versions left on disk.

## Uninstall

```bash
mac-runner uninstall
```

Uninstall stops running runners, unregisters them from GitHub, and deletes:

| Location                                                                  | What it holds                                |
| ------------------------------------------------------------------------- | -------------------------------------------- |
| Runner folders in `~/.mac-runner`                                         | Runner workspaces, often more than 1 GB each |
| Runner folders in `/Users/_macrunner/.mac-runner`                         | Workspaces of user-isolated runners          |
| `~/Library/Application Support/MacRunner`                                 | Settings, runner list, and the Linux kernel  |
| `~/Library/Preferences/com.omniaura.mac-runner.plist`, `mac-runner.plist` | App and command-line preferences             |
| `~/Library/Caches`, `~/Library/HTTPStorages` entries                      | Cached update checks                         |
| Crash and diagnostic reports                                              | Mac Runner's crash reports                   |

It leaves files of your own in `~/.mac-runner` and asks before deleting.
Options:

| Option           | What it does                                                     |
| ---------------- | ---------------------------------------------------------------- |
| `--yes`, `-y`    | Doesn't ask first                                                |
| `--include-app`  | Also deletes `MacRunner.app` and the `mac-runner` link           |
| `--keep-runners` | Deletes local files, and leaves the runners registered on GitHub |

When uninstall can't unregister a runner, it names the runner. Remove it from the
repository's **Settings > Actions > Runners** page on GitHub.

## Remove the app

- If you installed with Homebrew, after `mac-runner uninstall`:

  ```bash
  brew uninstall --cask mac-runner
  ```

  `brew uninstall --zap --cask mac-runner` removes the app and its files in
  one step, but it can't unregister runners or reach user-isolated
  workspaces. Run `mac-runner uninstall` first.

- If you installed from a download, run `mac-runner uninstall --include-app`,
  or drag `MacRunner.app` to the Trash.

## Remove the isolation user

`mac-runner uninstall` doesn't delete the `_macrunner` user. To delete it,
run `sudo mac-runner setup --teardown` before you uninstall.

Details: [Uninstall](../features/uninstall.md).
