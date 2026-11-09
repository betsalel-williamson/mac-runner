# Releasing

Releases are automatic. Every push to `main` runs
`.github/workflows/release.yml`, and when the commits since the last release
call for one, the workflow builds, signs, notarizes, and publishes it, then
updates the Homebrew cask. Nobody tags a release or uploads files by hand.
Why: [ADR 0007](../features/adr/0007-semantic-release-and-homebrew-cask.md).

## What starts a release

Releases happen only in `omniaura/mac-runner`.

- A push to `main`, which is what merging a pull request does.
- A manual run of the Release workflow from the repository's Actions tab
  (`workflow_dispatch`). It releases only if the commits call for one.

Which commits call for a release, and which version they produce:
[Commit conventions](commit-conventions.md). Release runs don't overlap: a
second push waits for the running one.

## In a fork

Every job in the release workflow checks that it runs in
`omniaura/mac-runner`. In a fork, a push to `main` runs only the
**Release skipped in fork** job, which records a notice in the run's summary,
so a fork never tags a version, publishes a release, or touches the Homebrew
tap.

## The pipeline

The workflow has four jobs.

### 1. Select a runner

On `ubuntu-latest`, `mikehardy/runner-fallback-action` checks whether a
self-hosted runner with the `mac-runner` label is online. If one is, the next
two jobs run there. If not, or if the check fails, they run on GitHub's
`macos-latest`. The check needs the `RUNNER_TOKEN` secret, a fine-grained
token with read access to the repository's administration settings.

### 2. Check for a release

semantic-release runs as a dry run over the full history. It reports whether
a release is due and its version. The rest of the workflow uses that version.

### 3. Build and release

This job runs only when a release is due. It:

1. Selects the latest stable Xcode and resolves packages.
2. Builds release binaries for `arm64` and `x86_64` with `--disable-sandbox`,
   and joins them into one universal binary with `lipo`.
3. Builds `build/MacRunner.app`, with an `Info.plist` from
   `scripts/generate-info-plist.sh` that carries the release version.
4. Imports the Developer ID Application certificate into a temporary
   keychain and finds the signing identity in it.
5. Signs nested code, then the executable, then the app, with the hardened
   runtime, a secure timestamp, and `scripts/MacRunner.entitlements`, and
   verifies the signature. The entitlements grant virtualization, which
   container isolation needs.
6. Zips the app with `ditto --keepParent` as `MacRunner-<version>.zip`.
7. Notarizes the zip with `scripts/notarize.sh`, staples the ticket to the
   app, and zips the stapled app again. The cask uses this zip's checksum.
8. Builds `MacRunner-<version>.dmg` with `create-dmg`, or `hdiutil` if
   `create-dmg` fails, then signs, notarizes, and staples it.
9. Deletes the temporary keychain and API key, even when an earlier step
   failed.
10. Writes the version and checksum into `Casks/mac-runner.rb`.
11. Runs semantic-release for real. It tags `v<version>`, creates the GitHub
    release with notes and the zip and disk image, updates `CHANGELOG.md`,
    and commits the changelog and cask to `main` as
    `chore(release): <version> [skip ci]`.
12. Uploads the zip and disk image to the release again with `--clobber`.

### 4. Update the Homebrew tap

On `ubuntu-latest`, after a release, the job copies `Casks/mac-runner.rb`
from `main` into the `omniaura/homebrew-tap` repository and pushes it, using
the `HOMEBREW_TAP_GITHUB_TOKEN` secret. Users install with
`brew install --cask omniaura/tap/mac-runner`.

## Signing and notarization

`scripts/notarize.sh <artifact>` submits a zip or disk image to Apple's
notary service and waits. It uses an App Store Connect API key when
`NOTARY_API_KEY_PATH`, `APPLE_API_KEY_ID`, and `APPLE_API_ISSUER_ID` are all
set, and an Apple ID otherwise. When Apple doesn't accept the submission, it
prints Apple's log for it and fails.

| Secret                       | Used for                                                          |
| ---------------------------- | ----------------------------------------------------------------- |
| `APPLE_CERTIFICATE_BASE64`   | The Developer ID Application certificate, a base64-encoded `.p12` |
| `APPLE_CERTIFICATE_PASSWORD` | The `.p12` password                                               |
| `APPLE_API_KEY_BASE64`       | App Store Connect API key (`.p8`), base64-encoded, preferred      |
| `APPLE_API_KEY_ID`           | That key's ID                                                     |
| `APPLE_API_ISSUER_ID`        | That key's issuer ID                                              |
| `APPLE_ID`                   | Apple ID for notarization, when there is no API key               |
| `APPLE_ID_PASSWORD`          | That Apple ID's app-specific password                             |
| `APPLE_TEAM_ID`              | The Apple Developer team, for Apple ID notarization               |
| `RUNNER_TOKEN`               | The runner check in job 1                                         |
| `HOMEBREW_TAP_GITHUB_TOKEN`  | Pushing to `omniaura/homebrew-tap`                                |

## Cask updates

`Casks/mac-runner.rb` in this repository is the cask's source. The tap's copy
is overwritten on every release, so change the cask here. A cask change
reaches users only with the next release, so commit it as a `fix` when users
need it.

The workflow changes only the `version` and `sha256` lines. The download link
follows the release asset name, `MacRunner-<version>.zip`, so keep the
workflow's asset names and the cask's link in step.

## When a release doesn't appear

- **No release ran.** The merged commits had no `feat`, `fix`, `perf`, or
  breaking change. Follow [Release hygiene](commit-conventions.md#release-hygiene).
- **Signing failed with no identity found.** The certificate secret doesn't
  hold a Developer ID Application identity, or its password is wrong.
- **Notarization failed.** Read Apple's log, which the workflow prints, fix
  the cause, and run the workflow again from the Actions tab.
- **The release exists but the tap didn't change.** Rerun the failed
  "Update Homebrew tap" job.

## Local builds

The Makefile's `app` and `dmg` targets build a bundle with an ad hoc signature
and not notarized, for local testing. They aren't a way to publish a
release, and their file names differ from the release assets. To repeat a
release, run the workflow again.
