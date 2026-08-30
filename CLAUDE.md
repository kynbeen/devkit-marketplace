# devkit marketplace project rules

This repository distributes the `devkit` plugin to Claude Code and Codex users from one GitHub
marketplace.

## Distribution boundary

- Keep `plugins/devkit/commands/` as the shared workflow source.
- Keep `plugins/devkit/codex-skills/devkit-*/SKILL.md` as thin Codex adapters to those commands.
- Never create `plugins/devkit/skills/`. Both hosts add that directory to component discovery
  automatically and no manifest field can remove it, so adapters placed there ship to Claude Code
  as a duplicate `/devkit:devkit-*` command set. `scripts/validate.ps1` enforces this.
- Do not add unattended development tooling, Telegram integration, or the review workflow.
- Never commit credentials, tokens, user identifiers, or machine-local configuration.
- Keep Claude and Codex plugin versions equal to the Claude marketplace entry version.
- Synchronize from the private full devkit only through `scripts/sync-from-devkit.ps1`; never mirror
  the two repositories bidirectionally.
- Keep installation, first-use, update, and troubleshooting instructions current in
  `docs/GETTING_STARTED.md` whenever commands or host behavior change.
- Do not store maintainer specs or handoffs in this public distribution repository. Record them in
  the private full devkit development repository instead.

## Validation

After changing the plugin, run the repository validator and Claude Code's validator from the
repository root:

```powershell
pwsh -File scripts/validate.ps1
pwsh -File scripts/sync-from-devkit.ps1
claude plugin validate .
```

Also install the repository as a local marketplace in isolated test homes before publishing a new
version. A static manifest check is not a substitute for loading the skills and hooks in each host.
