# Fix general problems

Problems with GitHub sign-in, registration, and runners in any isolation
mode.

## Mac Runner can't find `gh`

**Symptom:** adding a runner fails with `gh CLI not found or not
authenticated`, though `gh` works in your terminal.

**Cause:** Mac Runner runs `gh` from `/opt/homebrew/bin/gh` or
`/usr/local/bin/gh` only, not from your `PATH`.

**Fix:**

1. Install `gh` with Homebrew, which puts it in one of those places:

   ```bash
   brew install gh
   ```

2. If you installed `gh` another way, link it into `/usr/local/bin`:

   ```bash
   sudo ln -s "$(which gh)" /usr/local/bin/gh
   ```

## You're not signed in to GitHub

**Symptom:** the menu shows a red line that says
`GitHub authentication expired or is invalid. Run: gh auth login`, or
`mac-runner status` shows `GitHub auth: not authenticated`. You can't browse
repositories or add runners.

**Cause:** `gh` isn't signed in, or its sign-in expired.

**Fix:**

1. Sign in, from the terminal or with **Sign in with GitHub** in the
   **GitHub** tab of **Settings**:

   ```bash
   gh auth login
   ```

2. Check the sign-in and that the API answers:

   ```bash
   gh auth status
   gh api user
   ```

## Adding an organization runner fails with `admin:org`

**Symptom:** adding an organization runner fails, and the error mentions
`admin:org`.

**Cause:** your `gh` sign-in lacks the organization admin scope.

**Fix:** follow [Add an organization runner](../organization-runners.md#give-gh-the-organization-scope).

## Adding a runner fails with "Invalid repository or no access"

**Symptom:** `mac-runner add` or **Add Runner** fails with
`Invalid repository or no access`.

**Cause:** the name is wrong, or your account can't reach the repository or
organization.

**Fix:**

1. Check the name. A repository is `owner/repo`. An organization is its login
   with `--org`.
2. Check that you can see it:

   ```bash
   gh repo view owner/repo
   ```

3. Ask an owner for admin access, which registering a runner needs.

## The runner doesn't show up on GitHub

**Symptom:** Mac Runner shows the runner as running, but the repository's
**Settings > Actions > Runners** page doesn't list it.

**Cause:** registration failed, or the runner can't reach GitHub.

**Fix:**

1. List the runners GitHub knows:

   ```bash
   gh api repos/owner/repo/actions/runners --jq '.runners[].name'
   gh api orgs/my-org/actions/runners --jq '.runners[].name'
   ```

2. Read the runner's diagnostics log for the error:

   ```bash
   mac-runner logs my-runner --diag
   ```

3. Register it again:

   ```bash
   mac-runner remove my-runner
   mac-runner add owner/repo --name my-runner
   ```

## An offline runner stays listed after removal

**Symptom:** the repository's runners page lists a runner that no longer
exists on your Mac, as offline.

**Cause:** something deleted its files without unregistering it, for example by
deleting the app or running `mac-runner uninstall --keep-runners`.

**Fix:** remove it on the repository's **Settings > Actions > Runners** page.
Next time, use `mac-runner remove` or `mac-runner uninstall`, which
unregister runners first.

## The runner seems stuck on a job

**Symptom:** the runner shows **EXECUTING**, but no job runs on GitHub, or it
doesn't pick up new jobs.

**Cause:** the runner process stopped or hung during a job.

**Fix:**

1. Restart the runner:

   ```bash
   mac-runner stop my-runner
   mac-runner start my-runner
   ```

2. If it still seems stuck, look for leftover runner processes:

   ```bash
   ps aux | grep Runner.Listener
   ```

## Runners don't pause on schedule

**Symptom:** runners keep running during quiet hours or on low battery.

**Cause:** the menu bar app does the pausing, and it isn't running.

**Fix:** open Mac Runner, and turn on **Launch at Login** in **Settings**.
Check the schedule with `mac-runner schedule`.

## Your Mac is slow or loud while runners work

**Symptom:** fans run and apps lag while jobs run.

**Cause:** several jobs, or heavy builds, run at once.

**Fix:**

- See which runners use the most with `mac-runner status --resources`.
- Stop runners you don't need, or select **Pause All** in the menu while you
  work.
- Set quiet hours, or pause on low battery. See
  [Pause runners and set schedules](../pause-and-schedules.md).
- Turn on notifications for high resource usage in **Settings** to hear
  when runners pass a limit.

Details: [Runner lifecycle](../../features/runner-lifecycle.md),
[Command line](../../features/cli.md),
[Resource monitoring](../../features/resource-monitoring.md).
