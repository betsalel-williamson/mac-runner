# Reach GitHub only through the gh command

## Status

Accepted. Recorded after the fact from the code and history at 74c78d7.

## Context

Mac Runner calls GitHub's API to list repositories and organizations,
get runner registration tokens, list and delete runners, and look up jobs
and workflow runs. Each call needs a credential with enough access to manage
self-hosted runners.

## Decision

Make every GitHub call through the GitHub CLI, running `gh api` and
`gh auth status`, and rely on the user's existing `gh` sign-in. Mac Runner
stores no GitHub token of its own. It looks for `gh` in the Homebrew
locations, `/opt/homebrew/bin/gh` and `/usr/local/bin/gh`.

## Alternatives

- **Mac Runner's own personal access token.** Mac Runner would ask for a
  token, store it in the Keychain, and handle expiry and scopes itself.
- **A GitHub App or OAuth app.** Mac Runner would need a registered app and a
  sign-in flow.

## Consequences

- Mac Runner holds no long-lived GitHub secret. It passes only short-lived
  registration tokens to the runner's `config.sh`, and inside containers it
  unsets the token once registration finishes.
- Users must install `gh` and run `gh auth login` first. The cask's caveats
  say so.
- Mac Runner acts with all the access of the user's `gh` sign-in, not a
  narrower credential.
- Organization runners need the `admin:org` scope. When a registration token
  request fails for lack of it, Mac Runner suggests
  `gh auth refresh -h github.com -s admin:org`.
- An expired sign-in shows up when a runner starts, with `gh auth login` as
  the fix.
