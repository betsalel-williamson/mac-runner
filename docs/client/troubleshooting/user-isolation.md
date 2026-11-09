# Fix user isolation problems

Problems with runners whose isolation mode is **User**, which run as the
hidden `_macrunner` user. To set it up, see
[Choose an isolation mode](../choose-isolation.md#set-up-user-isolation).

## The runner doesn't start because the user is missing

**Symptom:** adding or starting a user-isolated runner fails, and
`dscl . -read /Users/_macrunner` says the record isn't found.

**Cause:** Mac Runner doesn't create the `_macrunner` user when you add a
runner. `sudo mac-runner setup` creates it, and it hasn't run on this Mac.

**Fix:**

1. Run setup and answer `y`:

   ```bash
   sudo mac-runner setup
   ```

2. Check the user:

   ```bash
   dscl . -read /Users/_macrunner
   ```

3. Start the runner again.

## Mac Runner asks for a password, or `sudo` fails

**Symptom:** starting or stopping a user-isolated runner fails with a `sudo`
error, or asks for your password.

**Cause:** your account has no entry in `/etc/sudoers.d/mac-runner`, which
lets it run the runner as `_macrunner` without a password. This happens when
another account ran setup, or someone removed the entry.

**Fix:** from your own account, stop every runner, then run setup again:

```bash
sudo mac-runner setup --teardown
sudo mac-runner setup
```

Teardown deletes `/Users/_macrunner`, with the user-isolated runners'
workspaces. Remove those runners and add them again afterward.

## Jobs fail with "Permission denied" in the workspace

**Symptom:** a job, or the runner, can't write to its workspace.

**Cause:** files in the workspace belong to another user. This often happens
after you copy or edit them as yourself.

**Fix:** give the workspaces back to the runner user:

```bash
sudo chown -R _macrunner:staff /Users/_macrunner/.mac-runner
```

## Jobs need `sudo`

**Symptom:** a step that runs `sudo` fails on a user-isolated runner.

**Cause:** the `_macrunner` user has no administrator rights, by design.

**Fix:** keep `sudo` out of jobs on this runner, or run those jobs on a
runner without isolation. Giving `_macrunner` administrator rights gives
every job on it control of your Mac.

Details: [User isolation](../../features/isolation/user.md),
[Isolation modes](../../features/isolation-modes.md).
