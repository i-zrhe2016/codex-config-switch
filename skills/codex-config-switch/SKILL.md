---
name: codex-config-switch
description: Switch the local Codex CLI between official ChatGPT/Plus authentication and third-party API profiles using the prepared profile switch script. Use when the user asks to switch, inspect, save, or import Codex auth/config profiles.
---

# Codex Config Switch

Use this skill for local Codex profile switching in `$CODEX_HOME` or `/root/.codex`.

## Script

Call the wrapper:

```bash
/root/.codex/skills/codex-config-switch/scripts/switch.sh <command>
```

The wrapper delegates to:

```bash
/root/.codex/bin/codex-profile-switch
```

Supported commands:

- no command: open an interactive action menu.
- `status`: show active profile, auth type, and profile completeness.
- `list`: show whether `official` and `api` profile snapshots exist.
- `save official|api`: save the current auth/config as a profile snapshot. The official snapshot contains only `auth.json`.
- `import official|api`: interactively import profile files.
- `use official|api`: ensure both profile types exist, prompt for missing content, back up current files, then switch.

## Operating Rules

- Before switching, run `list` or `status` so the user can see whether both profile snapshots exist.
- If a required snapshot is missing, use `use official|api` or `import official|api`; the script will prompt for the needed content.
- Official profile input is the user's official `auth.json` content. It has no `config.toml`; switching to it removes the active third-party `config.toml` after creating a backup. Do not generate or infer official Plus credentials.
- API profile input is the user's third-party `config.toml` plus `auth.json` content.
- Never print full API keys, tokens, or third-party API endpoints in the response. The script is designed to avoid exposing them; summarize only auth type and completeness.
- Treat `profiles/backups/<timestamp>/` as rollback material. Do not delete backups unless the user explicitly asks.

## Typical Use

- To switch to official auth:

```bash
/root/.codex/skills/codex-config-switch/scripts/switch.sh status
/root/.codex/skills/codex-config-switch/scripts/switch.sh use official
```

- To switch to the API profile:

```bash
/root/.codex/skills/codex-config-switch/scripts/switch.sh status
/root/.codex/skills/codex-config-switch/scripts/switch.sh use api
```

If the command is interactive, keep the user informed that pasted multi-line input must end with a line containing only `EOF`.
