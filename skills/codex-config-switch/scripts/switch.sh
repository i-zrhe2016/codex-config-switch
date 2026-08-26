#!/usr/bin/env bash
set -euo pipefail

SCRIPT="${CODEX_CONFIG_SWITCH_SCRIPT:-/root/.codex/bin/codex-profile-switch}"

if [[ ! -x "$SCRIPT" ]]; then
  printf 'Error: Codex profile switch script is not executable: %s\n' "$SCRIPT" >&2
  exit 127
fi

exec "$SCRIPT" "$@"
