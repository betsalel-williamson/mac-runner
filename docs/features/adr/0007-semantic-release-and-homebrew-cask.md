# Automatic releases, shipped as a notarized cask

## Status

Accepted. Recorded after the fact from the code and history at 74c78d7.

## Context

Mac Runner is a macOS app that users install and update often, mostly
through Homebrew. Gatekeeper warns about or blocks apps that aren't signed
with a Developer ID and notarized. Releasing by hand meant building, signing,
uploading, and editing the Homebrew file for every change, and the steps
drifted from what was actually shipped.

## Decision

- Commits on `main` follow Conventional Commits, and semantic-release, run
  by `.github/workflows/release.yml` on every push to `main`, decides whether
  to release and which version to cut.
- The workflow builds a universal binary, signs the app with a Developer ID
  and the hardened runtime, notarizes and staples the app and the disk image,
  and publishes both with the zip on the GitHub release.
- Homebrew installs Mac Runner as a cask, `Casks/mac-runner.rb`, whose
  version and checksum the workflow updates. semantic-release commits the
  cask with the changelog, and the workflow copies it to the
  `omniaura/homebrew-tap` repository.
- The release jobs run on a self-hosted Mac runner labeled `mac-runner` when
  one is online, and on GitHub's `macos-latest` otherwise.

## Alternatives

- **Tagging releases by hand** and running the build from the tag. Every
  release would need a person to choose the version and push the tag.
- **A Homebrew formula that builds from source.** Users would need Xcode, and
  the result would carry no signature.
- **Unsigned builds.** Users would have to override Gatekeeper.

## Consequences

- Every merged `feat` or `fix` ships at once. There are no release branches
  or release candidates.
- A user-facing change merged without a `feat` or `fix` commit doesn't
  release until a later commit triggers one, which is why the release
  hygiene rule exists.
- Releases depend on Apple signing and notarization secrets in the
  repository, and on a token that can push to the tap.
- The cask exists in two places. The one in this repository is the source, and
  the tap's copy is overwritten on each release.
- Release commits carry `[skip ci]`, so they don't start another release.
