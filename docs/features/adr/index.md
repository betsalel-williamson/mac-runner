# Architecture decision records

Architecture decision records for Mac Runner. Records marked as recorded after
the fact describe decisions already in the code when Mac Runner adopted Merlon
Docs.

| Record                                                          | Title                                                           | Status                            |
| --------------------------------------------------------------- | --------------------------------------------------------------- | --------------------------------- |
| [0001](0001-native-swift-menu-bar-app-and-cli.md)               | One Swift binary for the menu bar app and the command line tool | Accepted, recorded after the fact |
| [0002](0002-gh-cli-for-github-auth.md)                          | Reach GitHub only through the gh command                        | Accepted, recorded after the fact |
| [0003](0003-persistent-registered-runners.md)                   | Runners registered once and kept between jobs                   | Accepted, recorded after the fact |
| [0004](0004-user-isolation-with-service-user.md)                | Isolate macOS jobs with a dedicated service user                | Accepted, recorded after the fact |
| [0005](0005-container-isolation-with-apple-containerization.md) | Linux runners in lightweight virtual machines                   | Accepted, recorded after the fact |
| [0006](0006-declarative-runner-configuration.md)                | Declarative runner configuration in `.mac-runner.yml`           | Accepted, recorded after the fact |
| [0007](0007-semantic-release-and-homebrew-cask.md)              | Automatic releases, shipped as a notarized cask                 | Accepted, recorded after the fact |
| [0008](0008-one-job-runners-option.md)                          | One-job runners as an option beside long-lived runners          | Proposed                          |
