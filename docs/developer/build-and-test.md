# Build and test

## Prerequisites

- A Mac with macOS 15 or later, the minimum in `Package.swift`.
- Xcode. CI uses the latest stable release.
- The GitHub CLI (`gh`), signed in, to use runners from a local build.
- For container isolation: macOS 26 or later on Apple silicon, and a Linux
  kernel at `~/Library/Application Support/MacRunner/vmlinux`.

## Choose the toolchain

Build and test with Xcode's toolchain, as CI does. With only the Command Line
Tools selected, the build fails at the SwiftUI `#Preview` in
`MenuBarView.swift`, because the preview macro's plugin ships only with Xcode.

Either select Xcode for every command:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

or select it for one command by prefixing it with
`DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer`. The commands below
assume you selected Xcode.

## Build and run

| Command                         | Does                                                             |
| ------------------------------- | ---------------------------------------------------------------- |
| `swift build --disable-sandbox` | Builds the debug binary at `.build/debug/mac-runner`, as CI does |
| `make build`                    | Runs `swift build`                                               |
| `make run` or `just dev`        | Builds, then starts the menu bar app from the debug binary       |
| `.build/debug/mac-runner help`  | Runs the command line tool, which any argument selects           |

The binary starts the menu bar app when it gets no arguments, and the command
line tool when it gets any.

The release workflow passes `--disable-sandbox` because Apple's
Containerization package needs write access during the build, which the
default SwiftPM sandbox blocks. Pass it locally too when the build reports a
sandbox error.

## Run the tests

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --disable-sandbox
```

This matches CI. Read the result from the `Executed … tests, with … failures`
line of the `All tests` suite. The tests are XCTest. The last line reports a test run with 0 tests. It comes from Swift Testing,
which finds no tests, and doesn't count the XCTest suite. Lines that start with `objc[` and name
duplicate `UniversalHID` classes are a harmless warning from Xcode's
frameworks.

Every change must leave the suite with no failures. To run one test class,
add `--filter`, such as `--filter DeclarativeConfigTests`.

`make test` runs plain `swift test`, so it uses whichever toolchain you
selected and leaves the sandbox on.

What the suite covers, and what needs a manual check: [Testing](testing.md).

## Make targets

| Target           | Does                                                                                                      |
| ---------------- | --------------------------------------------------------------------------------------------------------- |
| `make build`     | `swift build`                                                                                             |
| `make run`       | Builds, then runs `.build/debug/mac-runner`                                                               |
| `make test`      | `swift test`                                                                                              |
| `make lint`      | `swift-format lint -r Sources Tests`                                                                      |
| `make format`    | `swift-format format -i -r Sources Tests`, which rewrites files in place                                  |
| `make release`   | A universal (`arm64` and `x86_64`) release build                                                          |
| `make app`       | Builds `build/MacRunner.app` from the release build, signed ad hoc with the entitlements in `scripts/`    |
| `make dmg`       | Packs the app into `build/MacRunner.dmg`                                                                  |
| `make install`   | Replaces `/Applications/MacRunner.app` with the local build                                               |
| `make uninstall` | Deletes the app and the invoking user's Mac Runner files, but not runners on GitHub or service user files |
| `make clean`     | Deletes `.build` and `build`                                                                              |
| `make update`    | `swift package update`                                                                                    |
| `make info`      | `swift package describe`                                                                                  |

`make lint` and `make format` call a `swift-format` command on the `PATH`.
Xcode ships one that isn't on the `PATH`, so run it as
`xcrun swift-format lint -r Sources Tests`, or install `swift-format` with
Homebrew. The code doesn't follow swift-format's default style and CI doesn't
run either target, so `make format` rewrites most files. Keep it out of a
feature change.

`make xcode` calls `swift package generate-xcodeproj`, which current SwiftPM
no longer has. Open `Package.swift` in Xcode instead.

`make app` builds a bundle for local testing only. Its `Info.plist` carries
version `0.1.0` unless you set `VERSION`, and it has no Developer ID
signature or notarization. Releases come from the release workflow, described
in [Releasing](releasing.md).
