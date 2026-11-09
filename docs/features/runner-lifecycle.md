# Runner lifecycle

A runner in Mac Runner moves through add, start, stop, and remove.
`RunnerManager` drives each step, whether it begins in the menu bar, the
dashboard, the command line, or a config file.

## States

| State   | Meaning                                                                        |
| ------- | ------------------------------------------------------------------------------ |
| Running | The runner process or virtual machine is up, and idle or executing a job       |
| Stopped | Not running                                                                    |
| Paused  | Stopped by Pause All or by [automatic pausing](auto-pause.md), to resume later |
| Error   | A start, restart, or resume failed, and the last event says why                |

Whether a running runner is executing a job comes from its log or from
GitHub's runner list. See [Job notifications](job-notifications.md).

## Add

Adding a runner registers it with GitHub and starts it:

1. Mac Runner checks that someone has signed in to `gh`, and that the account
   can see the repository or organization.
2. For a macOS runner it makes sure `gh` exists on the Mac. For a repository
   target it also installs the toolchains that the repository's top-level
   files point to (Node, Python, Go, Ruby, and Rust) plus the Extra CI Tools
   from Settings. Homebrew installs them.
3. For a macOS runner it gets a registration token with `gh`, downloads the
   latest GitHub Actions runner for macOS into a new workspace, and runs the
   runner's `config.sh` with the target, token, name, and labels. If it can't
   find or download the latest release, it uses a pinned version.
4. It looks up the ID that GitHub gave the runner, to remove it later.
5. It saves the runner to `config.json` and starts it.

A container runner skips steps 2 and 3. It picks its tools when added, and
registers from inside its virtual machine each time it starts. See
[Container isolation](isolation/container.md).

## Names and labels

| Source            | Default name                                                                |
| ----------------- | --------------------------------------------------------------------------- |
| `mac-runner add`  | `mac-runner-`, the first 8 characters of the host name, and 4 random digits |
| Add Runner sheet  | `mac-runner-` and 4 random digits                                           |
| Several instances | The base name with `-1`, `-2`, and further numbers                          |
| Duplicate         | The base name without any trailing `-N`, plus the next free `-N` from 2     |

The Add Runner sheet creates up to 20 instances at once, and a config file
creates up to 50 with `count`. A duplicate keeps the original's target,
labels, isolation, display access, open files limit, and image.

Default labels are `macos` and `mac-runner`, or `linux` and `mac-runner` for a
container runner. The Add Runner sheet registers `macos` alone when its labels
field is empty.

## Start

Starting a runner:

- Installs and registers again a macOS runner whose workspace has no runner
  in it.
- Rotates `runner.log` when it has grown too big, and prunes old diagnostics.
- Launches the runner with the open files limit, the Homebrew folders first on
  `PATH`, and the environment that [display access](gui-access.md) calls for.
- Appends the runner's output to `runner.log` and writes a process ID file.

A macOS runner is a separate process. It keeps running after the command that
started it exits and after the app quits.

## Stop and restart

Stopping a macOS runner sends `SIGTERM` to its whole process tree, deepest
process first. Stopping a container runner stops and deletes its container.
A job in progress ends with the runner.

There is no restart command, so stop and then start. Mac Runner restarts a
runner on its own in three cases:

- **After a crash:** when a runner exits with an error, or a signal kills it,
  and nobody stopped it, Mac Runner restarts it after 5 seconds, then 10, 20,
  and up to 60. After the retry limit within 10 minutes, 5 by default, the
  runner goes to the error state. Settings can change the limit or turn crash
  restarts off.
- **For a stale `PATH`:** an idle macOS runner whose saved `PATH` lacks the
  Homebrew folders restarts to pick them up.
- **For a config change:** `mac-runner apply` restarts a runner whose display
  access, image, or open files limit changed.

## Across app launches

`config.json` records which runners were running. When the app starts, it
starts again every runner that was running and whose process has gone. The app
tracks a runner whose process is still alive, such as one started from the
command line, through its process ID file. Launch at Login makes the app
start at login and bring its runners back.

## Remove

Removing a runner:

1. Stops it if it's running.
2. Deletes its GitHub registration. For a runner without a recorded GitHub
   ID, such as a container runner that never came online, Mac Runner deletes
   only an offline registration with its name. It never touches a live runner
   that it can't tie to this one.
3. Deletes its workspace, which holds the runner release and the `_work`
   checkout.
4. Deletes it from `config.json`.

Remove in the menu bar acts at once. The dashboard asks first.

## Related

- [Add a runner](../client/add-a-runner.md) in the client guide
- [Command line](cli.md)
- [Declarative config](declarative-config.md)
