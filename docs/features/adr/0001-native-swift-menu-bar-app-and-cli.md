# One Swift binary for the menu bar app and the command line tool

## Status

Accepted. Recorded after the fact from the code and history at 74c78d7.

## Context

Mac Runner manages self-hosted GitHub Actions runners on one Mac. People use
it two ways: from the menu bar, to watch runners and jobs, and from a
terminal or over SSH, to script runner setup. Both ways need the same
runner model, the same saved configuration, and the same rules for
installing, starting, and isolating runners.

## Decision

Build Mac Runner as one Swift package with one executable target,
`mac-runner`. The binary starts the SwiftUI menu bar app when it gets no
arguments and runs the command line tool when it gets any. The app bundle
holds that one binary, and the Homebrew cask links it onto the `PATH` as
`mac-runner`.

The app runs as a menu bar app with no Dock icon (`LSUIElement`).

## Alternatives

- **Two executables: an app and a separate command line tool.** They would
  share code through a library target but ship and version separately, and
  could drift apart.
- **Only an app.** Nobody could script runner setup or run it over SSH.

## Consequences

- One build, one version, and one release artifact cover both interfaces.
  The command line tool reads its version from the app bundle that encloses
  it.
- The app and command line runs can run at the same time and edit the same
  configuration file, so Mac Runner merges edits made by another process and
  locks shared state, such as the container image store, across processes.
- Every service is reachable from both interfaces, so features land in both
  or explain why not.
- The binary depends on SwiftUI and AppKit even when used only from a
  terminal.
