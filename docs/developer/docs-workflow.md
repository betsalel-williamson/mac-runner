# Documentation workflow

Mac Runner's docs use Merlon Docs. Shards, small Markdown files under
`docs/`, are the source of truth, and each shard has one job. The compiled
guides in `docs/_build/` come from the shards, so never edit them.

## Where things belong

| Guide             | Holds                                                                            |
| ----------------- | -------------------------------------------------------------------------------- |
| `docs/features/`  | What Mac Runner does, how it works, and the decision records behind it           |
| `docs/client/`    | Installing, configuring, and using Mac Runner                                    |
| `docs/developer/` | Working on this repository: layout, building, testing, CI, commits, and releases |
| `docs/glossary/`  | One term per shard                                                               |

If only contributors need it, it goes in `docs/developer/`. If users of Mac
Runner need it, it goes in `docs/features/` or `docs/client/`.

Shards describe Mac Runner as it works now. When behavior changes, change the
shard in the same pull request and delete the text it replaces. Git keeps
the old wording. Plans, task lists, and backlogs go in the issue tracker, not
in shards.

## Decisions

A decision about how Mac Runner works gets an architecture decision record
under `docs/features/adr/`, named with the next number, and a row in
`docs/features/adr/index.md`. A record has Status, Context, Decision,
Alternatives, and Consequences sections. When a later decision replaces one,
mark the old record as superseded and link the new one rather than deleting it.

## Commands

Install the tools once, then run the scripts, all from `docs/`:

```bash
cd docs
npm install
```

| Command           | Does                                                           |
| ----------------- | -------------------------------------------------------------- |
| `npm run check`   | Validates structure, links, Markdown lint, and Vale prose lint |
| `npm run compile` | Builds the compiled guides into `docs/_build/`                 |
| `npm run fix`     | Formats shards                                                 |
| `npm run review`  | Reports duplication and sprawl across shards                   |
| `npm run lint`    | Markdown lint only                                             |
| `npm run prose`   | Vale prose lint only                                           |

The prose lint needs the `vale` command installed. Run `npm run check` before
you finish a docs change, because CI doesn't run it.

After adding a shard, link it from its guide's `index.md`, which sets the
order of the compiled guide.

## Older documents

Some files in `docs/` and at the repository root predate Merlon Docs. Those
whose content has moved into shards start with a "ready to archive after
review" banner that says where the content now lives. Change the shards, not
those files.

`CONTRIBUTING.md` and `CHANGELOG.md` stay where they are, because GitHub
links contributors to the first and semantic-release writes the second.

Coding agents load the Merlon Docs skill in `.claude/skills/merlon-docs/`
before a docs task, as `AGENTS.md` says.
