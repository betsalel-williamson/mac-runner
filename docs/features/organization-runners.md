# Organization runners

A runner registers with either one repository or a whole organization. An
organization runner can take jobs from any repository that the
organization's runner group gives access to, so one Mac can serve many
repositories without a runner for each.

## Targets compared

|                     | Repository runner                  | Organization runner                                             |
| ------------------- | ---------------------------------- | --------------------------------------------------------------- |
| Identifier          | `owner/repo`                       | The organization login, with no slash                           |
| Add from the CLI    | `mac-runner add owner/repo`        | `mac-runner add org --org`                                      |
| Config file key     | `repo:`                            | `org:`                                                          |
| GitHub API path     | `repos/owner/repo/actions/runners` | `orgs/org/actions/runners`                                      |
| Registration target | `https://github.com/owner/repo`    | `https://github.com/org`                                        |
| Permission needed   | Admin access to the repository     | Organization admin, and the `admin:org` scope on the `gh` token |
| Runner group        | None                               | The organization's default runner group                         |

## What changes for an organization runner

- **Permission:** a registration token needs the `admin:org` scope. When `gh`
  lacks it, the error names the fix,
  `gh auth refresh -h github.com -s admin:org`. The Add Runner sheet offers to
  copy that command or to open the page that grants the scope.
- **Tools:** Mac Runner skips toolchain detection, because there is no single
  repository to inspect. It still installs `gh` and the Extra CI Tools.
- **Job details:** GitHub lists workflow runs per repository, so Mac Runner
  doesn't look up an organization runner's job on GitHub. Its jobs still come
  from the runner's log, and notifications and Recent Jobs show the job name.
  Their links open the organization's runner settings page instead of the
  run.
- **Display:** the menu bar and dashboard group organization runners under the
  organization's name with a building icon, and lists show `(org)` after it.

A repository runner and an organization runner with similar identifiers stay
in separate groups, because Mac Runner groups runners by scope and identifier
together.

## Related

- [Runner lifecycle](runner-lifecycle.md)
- [Organization runners](../client/organization-runners.md) in the client guide
