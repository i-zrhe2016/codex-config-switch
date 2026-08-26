# Codex Home Utilities

This Codex home contains a local profile switcher for moving between official
ChatGPT/Plus authentication and a third-party API configuration.

## Config Switcher

Main script:

```bash
/root/.codex/bin/codex-profile-switch
```

Skill wrapper for AI-driven use:

```bash
/root/.codex/skills/codex-config-switch/scripts/switch.sh
```

The skill is available as `$codex-config-switch`. When a user asks Codex to
switch, inspect, save, or import Codex auth/config profiles, the AI should use
the skill wrapper instead of rewriting the switching logic.

## Commands

```bash
/root/.codex/bin/codex-profile-switch status
/root/.codex/bin/codex-profile-switch list
/root/.codex/bin/codex-profile-switch save official
/root/.codex/bin/codex-profile-switch save api
/root/.codex/bin/codex-profile-switch import official
/root/.codex/bin/codex-profile-switch import api
/root/.codex/bin/codex-profile-switch use official
/root/.codex/bin/codex-profile-switch use api
```

`status` and `list` are read-only. `save`, `import`, and `use` update local
profile files under `/root/.codex/profiles`.

## Profiles

Profile snapshots live under:

```text
/root/.codex/profiles/
  official/
    config.toml
    auth.json
  api/
    config.toml
    auth.json
  backups/
```

`official` is for official ChatGPT/Plus auth state. Import this by pasting the
official `auth.json` content when prompted. Its `config.toml` is generated
automatically from local preferences: third-party provider entries and
`base_url` settings are removed, and `model_provider = "openai"` is written.

`api` is for third-party OpenAI-compatible API configuration. Import this by
pasting the third-party `config.toml` and `auth.json` content when prompted.

Multi-line pasted input must end with a line containing only:

```text
EOF
```

## Switching Flow

Before switching, the script checks whether both `official` and `api` profile
snapshots exist. If either profile is incomplete, it prompts for the missing
content before applying the requested profile.

For `save official` and `import official`, only the official `auth.json` is
saved from user input or the current auth state. The official `config.toml` is
auto-filled by the switcher so API endpoints are not copied into the official
profile.

Every `use official` or `use api` operation backs up the current `config.toml`
and `auth.json` first:

```text
/root/.codex/profiles/backups/<timestamp>/
```

Do not delete backup directories unless rollback material is no longer needed.

## Privacy

The switcher is designed not to print full API keys, tokens, or third-party API
endpoints. README examples also avoid documenting any concrete third-party API
address.

Credential files are written with restrictive permissions:

```text
600 config/auth files
700 profile/script directories where applicable
```

## Current Local State

At the time this README was created:

```text
active_profile: api
api profile: complete
official profile: missing config.toml auth.json
```

To finish official setup, run:

```bash
/root/.codex/bin/codex-profile-switch use official
```

Then paste the official `auth.json` content and finish with `EOF`.
