# Codex Config Switch

Minimal local switcher for Codex official login and third-party API configuration, with cross-provider historical session synchronization.

## Design

Only `config.toml` is managed for configuration.

- Official mode: remove the active third-party `config.toml`; Codex keeps using its own login/auth state.
- API mode: copy the saved API `config.toml` into `$CODEX_HOME/config.toml`.
- Switching providers synchronizes inactive historical sessions to the newly active provider/model by default.
- API keys are never stored in `auth.json` or profile files. Export them in the shell instead.

```bash
export OPENAI_API_KEY='...'
# or the env var referenced by your config.toml, for example:
export DEEPSEEK_API_KEY='...'
```

## Files

```text
/root/.codex/
  config.toml
  profiles/
    api/
      config.toml
    backups/
```

`auth.json` is intentionally not copied, imported, saved, modified, or backed up.

## Commands

```bash
/root/.codex/bin/codex-profile-switch
/root/.codex/bin/codex-profile-switch status
/root/.codex/bin/codex-profile-switch list
/root/.codex/bin/codex-profile-switch save api
/root/.codex/bin/codex-profile-switch import api /path/to/config.toml
/root/.codex/bin/codex-profile-switch use official
/root/.codex/bin/codex-profile-switch use api
/root/.codex/bin/codex-profile-switch use api --no-sync-sessions
/root/.codex/bin/codex-profile-switch sessions
/root/.codex/bin/codex-profile-switch sync-sessions
/root/.codex/bin/codex-profile-switch use api --resume --last
/root/.codex/bin/codex-profile-switch use official --resume <SESSION_ID>
/root/.codex/bin/codex-profile-switch use official --resume-all
```

## Example API config

```toml
model = "deepseek-chat"
model_provider = "deepseek"

[model_providers.deepseek]
base_url = "https://api.deepseek.com"
env_key = "DEEPSEEK_API_KEY"
```

Then:

```bash
export DEEPSEEK_API_KEY='your-key'
/root/.codex/bin/codex-profile-switch import api ~/config.toml
/root/.codex/bin/codex-profile-switch use api
codex
```

`use api` switches the active config and then rebinds inactive historical sessions to the provider/model selected by that config.

Switch back to official login:

```bash
/root/.codex/bin/codex-profile-switch use official
codex
```

The same synchronization runs when returning to the official provider. Use `--no-sync-sessions` to disable synchronization for one switch.

## Historical session synchronization

The sync helper uses Codex app-server APIs instead of directly rewriting Codex's SQLite state or rollout JSONL files.

It:

1. reads the provider/model from the effective current config;
2. lists local sessions across all providers, including archived sessions;
3. resumes sessions with the current provider/model override;
4. leaves session IDs and conversation messages unchanged;
5. skips sessions that already use the current provider;
6. skips sessions currently owned by another active writer.

Run it manually at any time:

```bash
/root/.codex/bin/codex-profile-switch sync-sessions
```

Example output:

```text
session_provider: deepseek
session_model: deepseek-chat
sessions_total: 42
sessions_synced: 36
sessions_already_current: 5
sessions_active_skipped: 1
sessions_failed: 0
```

Automatic synchronization is best-effort. If it encounters a session it cannot update, the provider switch itself remains successful and a warning is shown.

## Backups

When an active `config.toml` exists, switching saves only that file under:

```text
/root/.codex/profiles/backups/<timestamp>/config.toml
```

No credentials are included.

## Cross-provider resume

Historical sessions remain selectable across providers:

```bash
/root/.codex/bin/codex-profile-switch sessions
/root/.codex/bin/codex-profile-switch use official --resume-all
/root/.codex/bin/codex-profile-switch use api --resume-all --last
```

The session selector keeps session IDs intact. Provider synchronization changes only the provider/model context used by future resumes.
