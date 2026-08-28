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
/root/.codex/bin/codex-profile-switch
/root/.codex/bin/codex-profile-switch status
/root/.codex/bin/codex-profile-switch list
/root/.codex/bin/codex-profile-switch save official
/root/.codex/bin/codex-profile-switch save api
/root/.codex/bin/codex-profile-switch import official
/root/.codex/bin/codex-profile-switch import api
/root/.codex/bin/codex-profile-switch use official
/root/.codex/bin/codex-profile-switch use api
/root/.codex/bin/codex-profile-switch sessions
/root/.codex/bin/codex-profile-switch use api --resume --last
/root/.codex/bin/codex-profile-switch use official --resume <SESSION_ID> "继续处理"
/root/.codex/bin/codex-profile-switch use official --resume-all
```

`status`, `list`, and `sessions` are read-only. `save`, `import`, and `use` update local
profile files under `/root/.codex/profiles`.

Running the script without arguments opens an interactive menu for switching,
inspecting, saving, or importing profiles. The explicit subcommands remain
available for scripts and automation.

## Profiles

Profile snapshots live under:

```text
/root/.codex/profiles/
  official/
    auth.json
  api/
    config.toml
    auth.json
  backups/
```

`official` is for official ChatGPT/Plus auth state. Import this by pasting the
official `auth.json` content when prompted. Official login does not use a saved
`config.toml`. When switching to this profile, the current third-party
`config.toml` is backed up and then removed so Codex uses its official defaults.

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
saved from user input or the current auth state.

Every `use official` or `use api` operation backs up the current `config.toml`
and `auth.json` first:

```text
/root/.codex/profiles/backups/<timestamp>/
```

Do not delete backup directories unless rollback material is no longer needed.

### Cross-provider session visibility

`use <profile> --resume ...` combines profile switching with starting
`codex resume`. The profile is applied first; every argument after `--resume`
is passed to `codex resume` unchanged.

```bash
# Switch to the API profile, then resume the most recent session.
/root/.codex/bin/codex-profile-switch use api --resume --last

# Switch to the official profile, then resume a named or UUID session.
/root/.codex/bin/codex-profile-switch use official --resume <SESSION_ID>

# Omit resume arguments to open Codex's normal session picker.
/root/.codex/bin/codex-profile-switch use api --resume
```

The normal Codex picker can hide sessions recorded by another model provider
after a profile switch. Use the all-provider path when the goal is to see or
resume those sessions:

```bash
# List all unarchived local sessions and show their provider.
/root/.codex/bin/codex-profile-switch sessions

# Switch to official auth, then choose from every local provider.
/root/.codex/bin/codex-profile-switch use official --resume-all

# Resume the newest session across every local provider.
/root/.codex/bin/codex-profile-switch use official --resume-all --last

# Resume a known session ID after switching profiles.
/root/.codex/bin/codex-profile-switch use official --resume-all <SESSION_ID>
```

`--resume-all` uses the local app-server session index with an explicit
all-provider filter, then passes the selected ID to `codex resume`. It keeps
the original provider metadata and does not rewrite session JSONL/SQLite data;
it also does not concatenate messages from different sessions. The resumed
session runs with the newly selected profile, so whether it can continue
against that provider is still determined by Codex and the provider.

The data flow and limitations are documented in
[`docs/sessions/cross-provider-visibility.md`](docs/sessions/cross-provider-visibility.md).

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
official profile: missing auth.json
```

To finish official setup, run:

```bash
/root/.codex/bin/codex-profile-switch use official
```

Then paste the official `auth.json` content and finish with `EOF`.
