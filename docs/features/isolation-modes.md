# Isolation modes

An isolation mode decides who a runner's jobs run as and what they can reach.
Mac Runner has three modes. A global default applies to every runner that
doesn't pick its own.

## Modes compared

| Mode                                | Jobs run as                           | Jobs run on      | Needs                                            | Workspace                                    |
| ----------------------------------- | ------------------------------------- | ---------------- | ------------------------------------------------ | -------------------------------------------- |
| [None](isolation/none.md)           | The signed-in user                    | macOS            | Nothing extra                                    | `~/.mac-runner/runners/<id>`                 |
| [User](isolation/user.md)           | The hidden service user `_macrunner`  | macOS            | `sudo mac-runner setup`, once                    | `/Users/_macrunner/.mac-runner/runners/<id>` |
| [Container](isolation/container.md) | A user inside a Linux virtual machine | Linux on `arm64` | macOS 26, Apple silicon, and a Linux kernel file | `~/.mac-runner/runners/<id>`, mounted in     |

| Mode      | Keeps jobs from the owner's files                        | Default labels        | Shows as |
| --------- | -------------------------------------------------------- | --------------------- | -------- |
| None      | No                                                       | `macos`, `mac-runner` | 🔓       |
| User      | By file ownership                                        | `macos`, `mac-runner` | 👤       |
| Container | Yes, because the container sees only `_work` and `_diag` | `linux`, `mac-runner` | 📦       |

## Global default and per-runner override

The global default starts as none. These change it:

- `sudo mac-runner setup` sets it to user.
- `sudo mac-runner setup --teardown` sets it back to none.
- `settings: isolation` in a [config file](declarative-config.md) sets it to
  any mode.

A runner can set its own mode instead, with `--isolation` on
`mac-runner add`, the Isolation Mode menu in the Add Runner sheet, or
`isolation:` in a config file. A runner without one follows the global
default, and lists show it as global.

A runner's effective mode decides where Mac Runner looks for its workspace.
Changing the global default changes that place for every runner that follows
it, but `mac-runner setup` moves no files. After setup, remove existing
runners and add them again. `mac-runner apply` registers again every runner
whose effective mode changes.

## Choosing a mode

- **None** for trusted workflows, such as your own repositories.
- **User** for macOS jobs that shouldn't touch the owner's files and desktop.
- **Container** for Linux jobs, and for display tests that need a display of
  their own per runner.

How to pick and switch: [Choose isolation](../client/choose-isolation.md) in
the client guide.
