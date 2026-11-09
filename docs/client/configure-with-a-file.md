# Configure runners with a file

Describe your runners in `.mac-runner.yml`, and `mac-runner apply` creates,
updates, and removes runners to match. Keep the file in version control, or
use it to set up the same runners on another Mac.

## Export what you have

```bash
mac-runner export -o .mac-runner.yml
```

Without `-o`, `export` prints the file to the terminal.

## Edit the file

```yaml
version: 1

settings:
  isolation: user # none | user | container
  quiet-hours: { start: "22:00", end: "06:00" } # or: never
  pause-on-battery: true
  battery-threshold: 20 # percent, 5 to 95

runners:
  - name: mac-runner-ci # letters, digits, . _ -
    repo: omniaura/mac-runner # or org: omniaura for an organization runner
    labels: [macos, swift] # default: [macos, mac-runner]
    count: 2 # creates mac-runner-ci-1 and mac-runner-ci-2

  - name: linux-builder
    org: omniaura
    isolation: container # none | user | container | global (default: global)
    image: ghcr.io/myorg/ci-image:latest # container runners only
    enable-gui: false # default: false (headless)
    open-files: 65536 # default: the limit from Settings
    quiet-hours: never # never | { start, end } (default: global schedule)
```

Every key is optional except `name` and one of `repo` or `org`. `apply`
rejects keys it doesn't know, so a typo stops it before it changes anything.

## Preview the changes

```bash
mac-runner apply --dry-run
```

`apply` prints its plan and, with `--dry-run`, stops there. When the runners
already match the file, it says so and changes nothing.

## Apply the file

```bash
mac-runner apply
```

`apply` asks before it removes or registers a runner again. Answer `y` to go
on.

| Option              | What it does                             |
| ------------------- | ---------------------------------------- |
| `-f, --file <path>` | Reads that file                          |
| `--dry-run`         | Shows the plan without changing anything |
| `--yes`, `-y`       | Doesn't ask first                        |
| `--no-prune`        | Keeps runners that aren't in the file    |

Without `-f`, `apply` reads `./.mac-runner.yml`, then
`~/.mac-runner/config.yml`.

## What a change does

`apply` matches runners by name.

| Change in the file                        | What `apply` does                           |
| ----------------------------------------- | ------------------------------------------- |
| A new name                                | Registers and starts the runner             |
| `repo` or `org`, `labels`, or `isolation` | Unregisters it and registers it again       |
| `enable-gui`, `open-files`, or `image`    | Updates it, and restarts it if it's running |
| `quiet-hours`                             | Updates it in place                         |
| A name no longer in the file              | Unregisters it and deletes its workspace    |

Changing `isolation` under `settings` also registers again every runner that
follows the global mode. `count` takes 1 to 50.

A container runner that `apply` starts stays in the foreground of the
terminal. See
[Run and stop runners](run-and-stop-runners.md#container-runners-from-the-command-line).

Details: [Declarative configuration](../features/declarative-config.md).
