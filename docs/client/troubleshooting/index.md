# Troubleshooting

Find your symptom, then follow the fix. Each entry gives the symptom, the
cause, and the fix.

- [General problems](general.md): GitHub sign-in, `gh`, runners missing on
  GitHub, stuck runners, a busy Mac.
- [Container isolation](container-isolation.md): container runners that
  don't start or stop when you don't expect it.
- [User isolation](user-isolation.md): runners that run as the `_macrunner`
  user.

## Start with these checks

```bash
mac-runner status                 # runners, GitHub sign-in, and settings
mac-runner list                   # each runner's status and isolation
mac-runner logs my-runner         # the runner's output
mac-runner logs my-runner --diag  # the runner's diagnostics log
```

## Ask for help

Search the [issues](https://github.com/omniaura/mac-runner/issues) first. If
yours is new, open an issue with:

- Your macOS version, from `sw_vers`.
- Your Mac Runner version, from `mac-runner version`.
- The runner's isolation mode.
- The full error message, and the steps that lead to it.

Details: [Mac Runner overview](../../features/overview.md).
