# Fall back to GitHub-hosted runners

Run jobs on your Mac when it's online, and on GitHub-hosted runners when it
isn't, so a push always builds. A first job asks GitHub which runners are
online and picks the runner for the next job.

| Your Mac's runner | The job runs on                | Cost                   |
| ----------------- | ------------------------------ | ---------------------- |
| Online            | Your Mac (`mac-runner`)        | Free                   |
| Offline           | GitHub-hosted (`macos-latest`) | GitHub Actions minutes |

## Create a token

The check reads the repository's runners, which needs a token with admin
read access. The default `GITHUB_TOKEN` can't read them.

1. Create a
   [fine-grained personal access token](https://github.com/settings/personal-access-tokens/new).
2. Under **Repository access**, choose **Only select repositories** and pick
   your repository.
3. Under **Permissions**, set **Repository** > **Administration** to
   **Read-only**.
4. Save it as a repository secret named `RUNNER_TOKEN`:

   ```bash
   gh secret set RUNNER_TOKEN
   ```

## Add the fallback to a workflow

Add a `preflight` job that uses
[`mikehardy/runner-fallback-action`](https://github.com/mikehardy/runner-fallback-action),
and run the real job on its output:

```yaml
jobs:
  preflight:
    runs-on: ubuntu-latest
    outputs:
      runner: ${{ steps.runner.outputs.use-runner }}
    steps:
      - name: Select runner
        id: runner
        uses: mikehardy/runner-fallback-action@v1
        with:
          primary-runner: mac-runner
          fallback-runner: macos-latest
          fallback-on-error: true
          github-token: ${{ secrets.RUNNER_TOKEN }}

  build:
    needs: preflight
    runs-on: ${{ fromJson(needs.preflight.outputs.runner) }}
    steps:
      - run: echo "Running on the best available runner"
```

- `primary-runner` is a label your Mac's runner has. `mac-runner` is one of
  the default labels.
- `fallback-runner` is the GitHub-hosted label to use instead.
- `fallback-on-error: true` keeps the workflow running on the fallback when
  the token is missing or wrong.

The build job must work on both runners.

Details: [Cloud fallback](../features/cloud-fallback.md).
