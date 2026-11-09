# Job notifications

Mac Runner tells the owner when a runner starts a job and when the job ends,
with native macOS notifications. It learns about jobs from each runner's own
log, so even jobs that last a few seconds show up.

## Where jobs come from

The GitHub Actions runner writes a line to its output when it starts a job
and when the job ends, and Mac Runner saves that output in `runner.log`.
`JobLogTracker` follows each running runner's log, and the menu bar app reads
new lines every 2 seconds:

| Log line                                     | Means                                                   |
| -------------------------------------------- | ------------------------------------------------------- |
| `Running job: <name>`                        | A job started                                           |
| `Job <name> completed with result: <result>` | The job ended with that result                          |
| `Listening for Jobs`                         | The runner restarted, which cancels any job in progress |

When it starts following a log, the tracker reads its recent lines to find a
job already in progress. When a runner has no log to follow, Mac Runner falls
back to GitHub's busy flag from the 10-second status poll.

## Links to the run

For a repository runner, Mac Runner looks the job up on GitHub to get its
workflow name and a link to its run, waiting up to 8 seconds. When GitHub has
no record yet, or the runner belongs to an organization, Mac Runner knows the
job by name only. Its link then opens the repository's Actions page or the
organization's runner settings. Mac Runner tries again later to swap in
GitHub's record and the job's final result.

## Notifications

| Event            | Title                       | Body                               |
| ---------------- | --------------------------- | ---------------------------------- |
| Job started      | Job started on `<runner>`   | `<target> - <workflow>`            |
| Job succeeded    | Job completed on `<runner>` | `<target> - <workflow> (success)`  |
| Any other result | Job failed on `<runner>`    | `<target> - <workflow> (<result>)` |

Selecting a notification opens its link. A job that starts and ends between
two reads of the log gets one notification, for its end. Job Notifications is
on by default, and Settings can turn it off. The app asks for permission to
notify at launch. The command line never posts notifications.

## Recent jobs and the busy icon

Each job also goes into the runner's Recent Jobs in the
[dashboard](dashboard.md), up to 20 per runner, kept for as long as the app
runs. While any runner is executing a job, the menu bar icon moves. See
[Menu bar](menu-bar.md#status-item).

## Related

- [Automatic pausing](auto-pause.md) and
  [Resource monitoring](resource-monitoring.md) also post notifications.
- [Logs and status](../client/logs-and-status.md) in the client guide
