# Watch and control a runner fleet

The menu shows a **Fleet** section when the Mac also runs the runner fleet
supervisor, `mbp-supervisor`, from a github-runners clone. The supervisor
takes jobs through GitHub scale sets and starts one container per job. The
app only shows its state and starts or stops it.

The app looks for the clone at `~/Repos/github-runners`, and needs its
built supervisor at `bin/mbp-supervisor`. To use another clone, set its path:

```sh
defaults write com.omniaura.mac-runner fleetSupervisorRepoPath /path/to/github-runners
```

## What the section shows

- Whether the supervisor is running under its launch agent.
- The vCPUs and memory the runner containers use, the memory left for new
  ones, the load average, and macOS memory pressure.
- For each runner size, the jobs running and how many more fit now. Hover a
  size to see what limits it.
- Each running job's container.

The section refreshes every 15 seconds.

## Start, stop, and logs

The **…** menu in the section:

- **Start Supervisor** installs the launch agent if needed and starts it.
  The supervisor then starts again at each login.
- **Restart Supervisor** picks up a rebuilt supervisor or a changed config.
- **Stop Supervisor** stops it and removes the launch agent. A job still
  running fails.
- **Open Supervisor Log** and **Open Job Logs Folder** open
  `~/Library/Logs/mbp-supervisor`.
