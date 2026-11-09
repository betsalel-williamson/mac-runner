# Add an organization runner

An organization runner takes jobs from any repository in the organization
that targets its labels. Use one when several repositories share your Mac.

## Give `gh` the organization scope

Registering an organization runner needs organization admin permission and
the `admin:org` scope on your `gh` sign-in. Add the scope once:

```bash
gh auth refresh -h github.com -s admin:org
```

When the scope is missing, adding the runner fails and the **Add Runner**
window shows the command with two buttons:

- **Copy Command** copies it, to run in a terminal.
- **Open Reauth** opens the GitHub sign-in page in your browser and puts the
  device code on your clipboard.

After you approve, select **Add Runner** again.

## Add the runner from the menu bar

1. Select the Mac Runner icon, then **Add Runner**.
2. Set **Target Type** to **Organization**.
3. Type the organization login under **Organization**, or select **Browse**
   to pick one.
4. Fill in the name, labels, and other options as for a
   [repository runner](add-a-runner.md), then select **Add Runner**.

The menu groups organization runners under the organization name with a
building icon.

## Add the runner from the command line

Pass the organization login, without a slash, and `--org`:

```bash
mac-runner add my-org --org --labels macos,mac-runner
```

`mac-runner list` shows the target as `my-org (org)`.

## Target it from a workflow

Any repository in the organization reaches the runner through its labels:

```yaml
jobs:
  build:
    runs-on: [self-hosted, macos, mac-runner]
```

GitHub's runner groups decide which repositories may use organization
runners. Mac Runner registers new runners in the organization's default
runner group.

Details: [Organization runners](../features/organization-runners.md).
