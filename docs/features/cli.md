# Command line

`mac-runner` is the same executable as the app, run with arguments. Each
command loads the shared config, does one job, and exits. Commands and the app
work side by side, as [Architecture](architecture.md) explains. `CLIHandler`
parses commands, with helpers in `CLICommands`.

## Commands

| Command              | Does                                                                                  |
| -------------------- | ------------------------------------------------------------------------------------- |
| `mac-runner`         | Starts the menu bar app                                                               |
| `auth`               | Shows whether someone has signed in to `gh`                                           |
| `list`               | Lists runners with name, target, status, isolation, display access, and labels        |
| `add <target>`       | Adds, registers, and starts a runner                                                  |
| `remove <name>`      | Stops, deregisters, and deletes a runner and its workspace                            |
| `start <name>`       | Starts a runner                                                                       |
| `stop <name>`        | Stops a runner                                                                        |
| `status`             | Counts runners by state, and shows `gh` sign-in, pause settings, and global isolation |
| `status --resources` | Shows CPU, memory, workspace size, and processes per running runner, with a total     |
| `logs <name>`        | Shows the last lines of a runner's log                                                |
| `schedule`           | Shows or sets quiet hours, globally or for one runner                                 |
| `battery`            | Shows or sets pausing on low battery                                                  |
| `apply`              | Changes runners to match a config file                                                |
| `export`             | Writes the current runners as a config file                                           |
| `cleanup`            | Removes idle runner workspaces and CI caches                                          |
| `setup`              | Sets up user isolation, run with `sudo`                                               |
| `uninstall`          | Removes every runner and file Mac Runner created                                      |
| `help`, `version`    | Shows usage or the version                                                            |

## Options

| Command     | Options                                                                                                                       |
| ----------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `add`       | `--org` or `--repo`, `--name`, `--labels a,b`, `--isolation none\|user\|container`, `--enable-gui`, `--image`, `--open-files` |
| `logs`      | `-n` or `--lines N` (50 by default), `-f` or `--follow`, and `--diag` or `--job` for the diagnostics logs                     |
| `schedule`  | `--start HH:mm --end HH:mm`, `--off`, and `--runner <name>` with a window, `--never`, or `--global`                           |
| `battery`   | `on` or `off`, and `--threshold N` from 5 to 95                                                                               |
| `apply`     | `-f` or `--file`, `--dry-run`, `--yes` or `-y`, and `--no-prune`                                                              |
| `export`    | `-o` or `--output <path>`                                                                                                     |
| `cleanup`   | `--dry-run` and `--workspaces-only`                                                                                           |
| `setup`     | `--teardown`                                                                                                                  |
| `uninstall` | `--dry-run`, `--yes` or `-y`, `--include-app`, and `--keep-runners`                                                           |

`add` takes `owner/repo`, or an organization login with `--org`. `--image`
works only with container isolation. Feature shards:
[Runner lifecycle](runner-lifecycle.md), [Automatic pausing](auto-pause.md),
[Declarative config](declarative-config.md), [Disk cleanup](disk-cleanup.md),
and [Uninstall](uninstall.md).

## Logs

`mac-runner logs <name>` prints the last lines of `runner.log`, or of the
newest runner or job diagnostics log. With `--follow` it keeps printing new
lines until Ctrl-C, and moves on to a newer diagnostics file when one appears.

## Container runners in the foreground

`add`, `start`, and `apply` don't exit after starting a container runner. The
runner's virtual machine lives in the command's process, so the command
streams the runner's output and stops the runner on Ctrl-C. It also waits
through crash restarts. To keep container runners in the background, start
them from the menu bar app.

## Limits

- There is no `restart` command. Use `stop` and `start`.
- Commands find runners by name.
- Only `apply` and `export` exit with a nonzero status on failure. Other
  commands print `Error:` and exit with zero.
- Commands don't pause or resume runners. The app applies a schedule or
  battery change within seconds.
