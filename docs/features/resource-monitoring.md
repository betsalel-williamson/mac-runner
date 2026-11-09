# Resource monitoring

Resource monitoring shows how much of the Mac each running runner uses, so
the owner can tell which runner is heavy and when runners together use too
much. It can also warn when the total crosses a limit.

## Measures

| Measure        | macOS runners                                     | Container runners                          |
| -------------- | ------------------------------------------------- | ------------------------------------------ |
| CPU            | Sum over the runner's process tree, 100% per core | From the virtual machine's CPU time        |
| Memory         | Resident memory of the process tree               | The virtual machine's memory use           |
| Processes      | Processes in the tree                             | Processes in the container                 |
| Workspace size | Size of the runner's workspace on the host        | Size of the runner's workspace on the host |

`ResourceMonitor` reads processes with `ps`, which also sees processes that
the service user owns, and measures workspaces with `du`. When `du` can't
read the whole workspace, its size shows with `≥` as a lower bound.

## How often

The menu bar app reads CPU and memory on each status poll, every 10 seconds.
It does this in the background, so a slow reading never delays the poll. It
measures workspace size every 5 minutes, and gives up on a folder after 2
minutes.

`mac-runner status --resources` reads once, and measures workspace size before
it prints. A container runner that another process hosts shows dashes,
because only that process can read its virtual machine.

## Where it shows

- Under each running runner in the menu bar, with an `All runners` total when
  Mac Runner has figures for more than one runner.
- The dashboard sidebar total and each runner's Activity section.
- `mac-runner status --resources`, as a table of name, CPU, memory, disk, and
  processes, with a total row.

## Warnings

The setting for high resource usage warnings is off by default. When on, the app
compares the total across all runners with two limits:

| Limit        | Default | Range in Settings   |
| ------------ | ------- | ------------------- |
| Total CPU    | 400%    | 50% to 3200%, by 50 |
| Total memory | 16 GB   | 1 to 512 GB         |

The app posts one notification when the total crosses a limit. That limit
warns again only after the total drops back under it. Warnings don't depend
on the Job Notifications setting.

## Related

- [Logs and status](../client/logs-and-status.md) in the client guide
- [Dashboard](dashboard.md)
