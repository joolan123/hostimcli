#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-8080}"

if [[ -z "${PASSWORD:-}" ]]; then
  echo "ERROR: PASSWORD environment variable is required." >&2
  echo "Set a strong PASSWORD in Hostim before starting this app." >&2
  exit 1
fi

mkdir -p \
  /workspace/projects \
  /workspace/downloads \
  /workspace/venvs \
  /workspace/.go/bin \
  /workspace/.npm-global/bin \
  /workspace/.code-server/user-data \
  /workspace/.code-server/extensions \
  /workspace/.config \
  /workspace/.local/share \
  /workspace/.cache

# Hostim volumes can be created with root ownership. Give the normal IDE user access.
chown -R coder:coder /workspace

cat >/workspace/README-FIRST.txt <<'TXT'
Welcome to your Hostim Linux workspace.

Useful checks:
  go version
  python3 --version
  node --version
  npm --version
  git --version
  curl https://api.ipify.org

Persistent locations:
  /workspace/projects
  /workspace/downloads
  /workspace/.go/bin          (binaries installed with `go install`)
  /workspace/.npm-global/bin  (global npm binaries)
  /workspace/.code-server     (VS Code settings/extensions)

System packages installed with `sudo apt install ...` are NOT persistent across a
rebuild/redeploy. Add important packages to Dockerfile so they become permanent.
Files under /workspace are persistent when a Hostim volume is mounted there.
TXT
chown coder:coder /workspace/README-FIRST.txt

exec sudo -u coder -H env \
  PASSWORD="$PASSWORD" \
  HOME=/home/coder \
  XDG_CONFIG_HOME=/workspace/.config \
  XDG_DATA_HOME=/workspace/.local/share \
  XDG_CACHE_HOME=/workspace/.cache \
  GOPATH=/workspace/.go \
  GOBIN=/workspace/.go/bin \
  NPM_CONFIG_PREFIX=/workspace/.npm-global \
  PATH="/usr/local/go/bin:/workspace/.go/bin:/workspace/.npm-global/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
  code-server \
    --bind-addr "0.0.0.0:${PORT}" \
    --auth password \
    --disable-telemetry \
    --user-data-dir /workspace/.code-server/user-data \
    --extensions-dir /workspace/.code-server/extensions \
    /workspace
