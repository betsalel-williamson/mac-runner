# Commit conventions

Commits on `main` follow [Conventional Commits](https://www.conventionalcommits.org/),
because semantic-release reads them to decide whether to release and which
version to cut. Why: [ADR 0007](../features/adr/0007-semantic-release-and-homebrew-cask.md).

## Format

```text
<type>[optional scope][!]: <description>

[optional body]

[optional footer]
```

A scope is optional, such as `fix(ci): …`. Mark a breaking change with `!`
after the type or scope, or with a `BREAKING CHANGE:` footer.

## Types and releases

`.releaserc.json` sets these rules:

| Commit                                                      | Release |
| ----------------------------------------------------------- | ------- |
| Breaking change, any type                                   | Major   |
| `feat`                                                      | Minor   |
| `fix`                                                       | Patch   |
| `perf`                                                      | Patch   |
| `docs`, `style`, `refactor`, `test`, `chore`, `build`, `ci` | None    |

A commit that the rules don't match falls through to semantic-release's
default rules, which also release a patch for a revert written in the form
`git revert` produces.

A release ships everything merged since the last one, so a `docs` or
`refactor` commit reaches users with the next `feat` or `fix`.

## Pull requests

Most changes reach `main` as a squash merge, so the pull request's title
becomes the commit that semantic-release reads. Give the title the type the
change deserves: `feat` for something users can now do, `fix` for something
that now works.

## Release hygiene

A merged change that users should get, but that reached `main` with no `feat`
or `fix` commit, doesn't release. Open a follow-up pull request with an empty
conventional commit so the pipeline publishes it:

```bash
git commit --allow-empty -m "fix: trigger semantic release"
```

`AGENTS.md` states this rule for coding agents too.

semantic-release's own commits, `chore(release): <version> [skip ci]`, update
`CHANGELOG.md` and the cask. Don't write commits in that form by hand.
