---
name: codex-config-switch
description: Import, activate, inspect, and switch Codex config.toml profiles between the built-in official login and a saved third-party API configuration, while synchronizing historical local sessions to the newly active provider. Use when the user asks an AI to import a Codex config, switch providers, activate API mode, return to official Codex login, check the active profile, sync historical conversations, or save the current API config. Manage only config.toml; never manage auth.json, and keep API keys in exported environment variables.
---

# Codex Config Switch

Use the existing switcher instead of editing `$CODEX_HOME/config.toml` or Codex session storage by hand.

## Command

Run the bundled wrapper:

```bash
/root/.codex/skills/codex-config-switch/scripts/switch.sh <command>
```

It delegates to `/root/.codex/bin/codex-profile-switch` unless `CODEX_CONFIG_SWITCH_SCRIPT` overrides that path.

## Map user intent to actions

| User intent | Action |
| --- | --- |
| Import a `config.toml` | `import api CONFIG_FILE` |
| Import and immediately use it | `import api CONFIG_FILE`, then `use api` |
| Switch to a third-party/API provider | `use api` |
| Switch back to official Codex login | `use official` |
| Sync all historical sessions to the active provider | `sync-sessions` |
| Switch without syncing sessions | `use official\|api --no-sync-sessions` |
| Check the current mode | `status` |
| Check whether an API config is saved | `list` |
| Save the current config as the API profile | `save api` |

Treat provider names such as DeepSeek, OpenRouter, or another third-party endpoint as API mode unless the user explicitly asks for official Codex login.

## AI workflow

1. Infer the requested operation from the user's wording. Do not ask for confirmation when the requested import or switch is already clear.
2. Use only `config.toml` for configuration. Never read, import, copy, modify, back up, or request `auth.json`.
3. If the user provides a file path, import that file directly.
4. If the user pastes a complete TOML configuration, write it to a permission-restricted temporary file, import it, then delete the temporary file.
5. If the user requests both import and activation, perform both operations in that order.
6. Let `use official` and `use api` synchronize historical sessions automatically after switching. Do not add `--no-sync-sessions` unless the user explicitly wants to keep historical sessions bound to their previous providers.
7. After a mutating operation, run `status` and report the resulting `active_profile`.
8. If `use api` fails because no API profile exists, ask for a `config.toml` path or complete TOML content instead of inventing one.

## Historical session synchronization

Provider switching automatically invokes the session synchronizer after the new config becomes active.

The synchronizer:

- reads the effective provider and model from Codex app-server;
- enumerates active and archived local sessions across all providers;
- uses Codex `thread/resume` with provider/model overrides instead of editing SQLite or rollout JSONL files directly;
- skips sessions already bound to the active provider;
- skips sessions held by another active writer and reports the count;
- keeps the config switch successful even if session synchronization is only partially successful.

Manual synchronization:

```bash
/root/.codex/skills/codex-config-switch/scripts/switch.sh sync-sessions
```

Disable automatic synchronization for one switch:

```bash
/root/.codex/skills/codex-config-switch/scripts/switch.sh use api --no-sync-sessions
```

This changes the provider/model used when historical sessions are resumed. It does not rewrite conversation messages or merge different session IDs.

## Pasted config example

```bash
tmp="$(mktemp)"
chmod 600 "$tmp"
cat >"$tmp" <<'EOF'
# user-provided config.toml content
EOF
/root/.codex/skills/codex-config-switch/scripts/switch.sh import api "$tmp"
rm -f "$tmp"
/root/.codex/skills/codex-config-switch/scripts/switch.sh use api
/root/.codex/skills/codex-config-switch/scripts/switch.sh status
```

## Credentials

Keep credentials outside `config.toml`.

A provider config should reference an environment variable, for example:

```toml
model = "deepseek-chat"
model_provider = "deepseek"

[model_providers.deepseek]
base_url = "https://api.deepseek.com"
env_key = "DEEPSEEK_API_KEY"
```

The user supplies the secret in the shell:

```bash
export DEEPSEEK_API_KEY='...'
```

Never print an environment variable's value. If a required variable is missing, identify only its variable name and tell the user to export it. If a pasted configuration contains a literal API key, do not echo the key back; recommend replacing it with `env_key` before importing.

## Common operations

Import a file and activate API mode with automatic history sync:

```bash
/root/.codex/skills/codex-config-switch/scripts/switch.sh import api ~/config.toml
/root/.codex/skills/codex-config-switch/scripts/switch.sh use api
/root/.codex/skills/codex-config-switch/scripts/switch.sh status
```

Return to official login and rebind history to the official provider:

```bash
/root/.codex/skills/codex-config-switch/scripts/switch.sh use official
/root/.codex/skills/codex-config-switch/scripts/switch.sh status
```

## Report results

Keep the response short. Report:

- whether the config was imported;
- which profile is active: `official`, `api`, or `custom`;
- the session synchronization counts;
- the backup path if the switcher created one;
- any missing environment variable name.

Do not include secret values or the contents of `auth.json`.
