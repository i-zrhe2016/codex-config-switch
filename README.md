# Codex Config Switch

Minimal local switcher for Codex official login and third-party API configuration.

## Design

Only `config.toml` is managed by this repository.

- Official mode: remove the active third-party `config.toml`; Codex keeps using its own login/auth state.
- API mode: copy the saved API `config.toml` into `$CODEX_HOME/config.toml`.
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
/root/.codex/bin/codex-profile-switch sessions
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

Switch back to official login:

```bash
/root/.codex/bin/codex-profile-switch use official
codex
```

## Backups

When an active `config.toml` exists, switching saves only that file under:

```text
/root/.codex/profiles/backups/<timestamp>/config.toml
```

No credentials are included.

## Cross-provider sessions

Session listing/resume support is unchanged:

```bash
/root/.codex/bin/codex-profile-switch sessions
/root/.codex/bin/codex-profile-switch use official --resume-all
/root/.codex/bin/codex-profile-switch use api --resume-all --last
```

The session helper selects an existing local session and passes its ID to `codex resume`; it does not rewrite or merge session data.
