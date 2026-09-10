---
name: codex-config-switch
description: Switch Codex between its built-in official login and a saved third-party API config.toml. API credentials come from exported environment variables; auth.json is never managed.
---

# Codex Config Switch

Use this skill for local Codex configuration switching in `$CODEX_HOME` or `/root/.codex`.

## Script

```bash
/root/.codex/skills/codex-config-switch/scripts/switch.sh <command>
```

The wrapper delegates to:

```bash
/root/.codex/bin/codex-profile-switch
```

## Managed state

Only `config.toml` is managed.

- Official mode removes the active third-party `config.toml` and leaves Codex authentication untouched.
- API mode copies the saved API `config.toml` into `$CODEX_HOME/config.toml`.
- Never copy, import, save, modify, or back up `auth.json`.
- API secrets must come from exported environment variables, for example `export OPENAI_API_KEY='...'` or the `env_key` used by the selected provider.

## Commands

- `status`: show whether official/API config is active.
- `list`: show whether the API `config.toml` snapshot exists.
- `save api`: save the current `$CODEX_HOME/config.toml` as the API profile.
- `import api CONFIG_FILE`: import one `config.toml` file as the API profile.
- `use official|api`: switch config only.
- `sessions`: list local sessions across model providers.
- `use official|api --resume ...`: switch config and invoke `codex resume`.
- `use official|api --resume-all [--last|SESSION_ID]`: switch config, select from all local providers, and resume.

## Typical use

```bash
export DEEPSEEK_API_KEY='...'
/root/.codex/skills/codex-config-switch/scripts/switch.sh import api ~/config.toml
/root/.codex/skills/codex-config-switch/scripts/switch.sh use api
```

Return to official login:

```bash
/root/.codex/skills/codex-config-switch/scripts/switch.sh use official
```

Before switching, `status` or `list` may be used to inspect the current config state. Do not print secret environment variable values.
