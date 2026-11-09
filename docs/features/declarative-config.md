# Declarative config

A config file, `.mac-runner.yml`, describes the runners a Mac should have and
a few global settings. `mac-runner apply` creates, updates, and removes
runners until they match it, so a setup can live in version control and move
to another Mac. `DeclarativeConfig` reads the file and `ConfigPlanner` works
out the changes.

## Finding the file

`apply` reads the first of:

1. The path that `-f` or `--file` names.
2. `.mac-runner.yml` in the current folder.
3. `~/.mac-runner/config.yml`.

## Schema

Top level:

| Key        | Value                               |
| ---------- | ----------------------------------- |
| `version`  | Optional, and `1` when present      |
| `settings` | Optional global settings, see below |
| `runners`  | The list of runners                 |

Settings, each optional. A setting the file leaves out keeps its current
value.

| Key                 | Value                                                                  |
| ------------------- | ---------------------------------------------------------------------- |
| `isolation`         | `none`, `user`, or `container`, the global default                     |
| `quiet-hours`       | `{ start: "HH:mm", end: "HH:mm" }`, or `never` to turn quiet hours off |
| `pause-on-battery`  | `true` or `false`                                                      |
| `battery-threshold` | A percentage from 5 to 95                                              |

Runner keys:

| Key           | Value                                              | Without it                     |
| ------------- | -------------------------------------------------- | ------------------------------ |
| `name`        | Letters, digits, `.`, `_`, and `-`, required       |                                |
| `repo`, `org` | Exactly one, `owner/name` or an organization login |                                |
| `labels`      | A list of labels                                   | The defaults for its isolation |
| `isolation`   | `none`, `user`, `container`, or `global`           | Follows the global default     |
| `enable-gui`  | `true` or `false`                                  | `false`                        |
| `open-files`  | A positive number                                  | The global open files limit    |
| `quiet-hours` | `{ start, end }`, or `never`, `off`, or `none`     | Follows the global schedule    |
| `image`       | An image reference, for container isolation only   | The default runner image       |
| `count`       | 1 to 50, creating `name-1` to `name-N`             | 1, with the name as written    |

## Validation

`apply` stops before changing anything when the file has a problem:

- An unknown key, at any level. A typo can't read as an empty runner list and
  remove everything.
- A version other than 1.
- A bad name, target, count, time, threshold, or `open-files` value.
- `image` on a runner that isn't a container runner.
- Two runners with the same name, after `count` expands.

## Applying

`apply` matches runners by name, prints its plan, and then acts:

| Change                                                                               | What `apply` does                                                 |
| ------------------------------------------------------------------------------------ | ----------------------------------------------------------------- |
| A new name                                                                           | Adds, registers, and starts the runner                            |
| Target, labels, or effective isolation                                               | Removes the runner and registers it again                         |
| `enable-gui`, `image`, or `open-files`                                               | Updates it, and restarts it if it's running                       |
| `quiet-hours`, or isolation moving between pinned and inherited with the same effect | Updates it in place                                               |
| A runner missing from the file                                                       | Removes it and deletes its workspace, unless `--no-prune` applies |

Changing the global `isolation` registers again every runner that follows it.

- `--dry-run` prints the plan and stops.
- `apply` asks before it removes a runner or registers one again. `--yes`
  skips the question.
- `apply` doesn't restart a runner that's executing a job. The change takes
  effect the next time the runner starts, and the output says so.
- Running `apply` again with no changes does nothing.

### Order of work

1. It checks that it can register every runner to add or register again:
   someone has signed in to `gh` and the target is reachable. A runner that
   fails this check stays as it is.
2. It removes runners, using the settings they started with.
3. It saves the new settings.
4. It adds, registers again, and updates runners under the new settings.

If registering a runner again fails after its removal, the error says so, and
running `apply` again retries it. `apply` exits with a nonzero status when any
change fails.

## Exporting

`mac-runner export` writes the current setup as a version 1 file, to standard
output or to the path that `-o` names. It writes all four settings and every
runner, sorted by name. Each runner lists its name, target, and labels, plus
only the keys it sets for itself: `isolation` when pinned, `enable-gui` when
on, and `open-files`, `quiet-hours`, and `image` when present. It never writes
`count`.

## Related

- [Configure with a file](../client/configure-with-a-file.md) in the client
  guide
- [Runner lifecycle](runner-lifecycle.md)
