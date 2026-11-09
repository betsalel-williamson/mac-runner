# Repository Instructions

## Release Hygiene

- Semantic-release only cuts releases from conventional commits. For any merged user-facing fix that did not include a `fix:` or `feat:` commit on the PR branch, open a follow-up PR with an empty conventional commit, for example `fix: trigger semantic release`, so the release pipeline publishes the change.

## Documentation

- Docs use Merlon Docs. Load the `merlon-docs` skill in `.claude/skills/`
  before a docs task, and follow the workflow it picks.
- Shards under `docs/features`, `docs/client`, `docs/developer`, and
  `docs/glossary` are the source of truth. Never edit `docs/_build/`.
- Run `npm run check` in `docs/` (after `npm install` there) before finishing
  a docs change.
- Older files in `docs/` and at the repository root that carry a "ready to
  archive after review" banner have moved into shards; change the shards, not
  them.
