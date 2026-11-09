# Continuous integration

`.github/workflows/ci.yml` checks every pull request into `main`, and in a
fork also every push to `main`. Merge only when it passes.

## What it runs

One job, **Build & Test**, on GitHub's `macos-latest` runner:

1. Checks out the pull request.
2. Selects the latest stable Xcode.
3. Clears SwiftPM state: `.build`, `Package.resolved`, and SwiftPM's caches,
   so every run resolves packages from scratch.
4. `swift package resolve`.
5. `swift build --disable-sandbox`.
6. `swift test --disable-sandbox`.

Each of the last three steps raises the open file limit to 65536, or to the
hard limit when that is lower, before it runs.

A new push to the same pull request, or to the same branch, cancels the run
in progress.

## In a fork

A fork that develops directly on its own `main` gets the same job on every
push to `main`, so its trunk stays tested. In the upstream repository, push
runs skip the job, because the pull request that produced the push already
ran it. The workflow can also be started by hand from the Actions tab.

## What must pass

The build and the whole test suite. To reproduce a run locally, see
[Build and test](build-and-test.md#run-the-tests).

CI doesn't run `swift-format` or the docs check. Run `npm run check` in
`docs/` yourself when a change touches docs, as
[Documentation workflow](docs-workflow.md) describes.

## The release workflow's runner

CI always uses GitHub's runner. The release workflow is different: it builds
on a self-hosted Mac runner labeled `mac-runner` when one is online and falls
back to `macos-latest` otherwise. See [Releasing](releasing.md#1-select-a-runner).
