# devkit marketplace project rules

This repository distributes the `devkit` plugin to Claude Code and Codex users from one GitHub
marketplace.

## Distribution boundary

- Keep `plugins/devkit/commands/` as the shared workflow source.
- Keep `plugins/devkit/skills/devkit-*/SKILL.md` as thin Codex adapters to those commands.
- Do not add unattended development tooling, Telegram integration, or the review workflow.
- Never commit credentials, tokens, user identifiers, or machine-local configuration.
- Keep Claude and Codex plugin versions equal to the Claude marketplace entry version.

## Validation

After changing the plugin, run the repository validator and Claude Code's validator from the
repository root:

```powershell
pwsh -File scripts/validate.ps1
claude plugin validate .
```

Also install the repository as a local marketplace in isolated test homes before publishing a new
version. A static manifest check is not a substitute for loading the skills and hooks in each host.
