# User isolation

User isolation runs a runner's jobs as `_macrunner`, a hidden macOS user that
Mac Runner creates. Jobs work in that user's home folder instead of the
owner's, so they can't change the owner's files or fill the owner's desktop
with windows.

## Setup

`sudo mac-runner setup` prepares the Mac once, after asking for confirmation:

1. It creates the hidden user `_macrunner` with a user ID from 400 to 499, the
   `staff` group, and no password, so nobody can log in as it.
2. It creates `/Users/_macrunner` with `.mac-runner/runners` for workspaces,
   a private `.tmp` folder, and a `.zprofile`. The profile puts Homebrew on
   `PATH`, points `TMPDIR` at `.tmp`, and raises the open files limit.
3. It installs `/etc/sudoers.d/mac-runner`, after `visudo` checks it. With
   this entry the invoking user can run login shells as `_macrunner`, run
   `kill`, and create folders under `/Users/_macrunner` and change their
   owner, all without a password.
4. It sets the global isolation default to user.

Runners added after setup that follow the global default use user isolation.
Existing runners don't move, so remove them and add them again.

## How it runs

- The workspace is `/Users/_macrunner/.mac-runner/runners/<id>`, owned by
  `_macrunner`. Mac Runner creates, installs, and deletes it through the
  sudoers entry.
- The runner starts with `sudo -n -H -u _macrunner` in a `zsh` login shell, so
  `HOME` is the service user's home and its profile applies.
- `_macrunner` creates `runner.log` and gives write access to the owner's
  account alone, so the app can append the runner's output and its own events.
- Stopping signals the process tree as `_macrunner`.

## Teardown

`sudo mac-runner setup --teardown` reverses setup. It refuses while any
runner is running. It removes the sudoers entry, deletes `_macrunner` and its
home folder with every workspace in it, and sets the global default back to
none.

## Limits

- It separates files by owner and isn't a sandbox. `_macrunner` belongs to the
  `staff` group and can read whatever file permissions on the Mac let it.
- Tools that Mac Runner installs come from the owner's Homebrew, which
  `_macrunner` shares through `PATH`.
- `_macrunner` has no login session, so a runner with display access shares
  the owner's desktop. See [Display access](../gui-access.md).
- Setup always uses the name `_macrunner`.
- [Uninstall](../uninstall.md) deletes service user workspaces but leaves the
  user and the sudoers entry. Teardown removes them.

## Related

- [Isolation modes](../isolation-modes.md)
- [Choose isolation](../../client/choose-isolation.md) in the client guide
