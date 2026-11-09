# Cloud fallback

Cloud fallback is a workflow pattern, not a part of the app. A job runs on a
Mac Runner runner when one is online and on a GitHub-hosted runner when not.
Pushes keep building whether the Mac is on or off. Mac Runner's own release
workflow uses it.

## How it works

A workflow has two jobs:

1. A small preflight job, on a GitHub-hosted runner, runs
   [`mikehardy/runner-fallback-action`](https://github.com/mikehardy/runner-fallback-action).
   It asks the GitHub API whether a self-hosted runner with the primary label
   is online, and outputs either that label or the fallback label.
2. The real job needs the preflight job and takes its `runs-on` from that
   output.

The action's inputs:

| Input               | Example             | Meaning                                      |
| ------------------- | ------------------- | -------------------------------------------- |
| `primary-runner`    | `mac-runner`        | A label the Mac Runner runner registers with |
| `fallback-runner`   | `macos-latest`      | The GitHub-hosted runner to use otherwise    |
| `fallback-on-error` | `true`              | Fall back when the check itself fails        |
| `github-token`      | A repository secret | A token that can read self-hosted runners    |

| Mac Runner runner with the label | Job runs on                  | Cost                     |
| -------------------------------- | ---------------------------- | ------------------------ |
| Online                           | The self-hosted runner       | No GitHub-hosted minutes |
| Offline                          | The fallback, `macos-latest` | GitHub-hosted minutes    |

## What it needs

- A token that can read the repository's self-hosted runners. The default
  `GITHUB_TOKEN` can't. A fine-grained personal access token with read-only
  Administration permission on the repository works.
- That token in a repository secret, such as `RUNNER_TOKEN`.
- `fallback-on-error: true`, so a missing or broken token falls back to the
  GitHub-hosted runner instead of failing the workflow.

## Limits

- The preflight job itself runs on a GitHub-hosted runner.
- The check happens once, before the job starts. A runner that goes offline
  after the check doesn't send the job back to GitHub-hosted runners. The job
  waits for a runner with the label.
- GitHub sees a paused Mac Runner runner as offline, so jobs fall back while
  it stays paused.
- The fallback runner must suit the job too, for example macOS for a macOS
  build.

How to set it up: [Cloud fallback](../client/cloud-fallback.md) in the client
guide.
