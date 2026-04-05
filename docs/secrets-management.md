# Secrets Management

By default, Claude Code credentials are stored in the `claude-sandbox-claude-config` named Docker volume, mounted at `/home/claude/.claude` inside the container. This is the right call for local, single-user use — credentials never touch the image or the repo, and they persist across container restarts without re-authenticating.

This project was built as a personal local dev tool. It's not hardened for production or shared environments, though it's not far off. The main gap is credential handling. If you need runtime injection, the options below are drop-in additions.

---

## Upgrading to Runtime Credential Injection

All three approaches follow the same pattern:

1. Remove the `claude-sandbox-claude-config` volume mount from `docker-compose.yml`
2. Fetch the credential in `scripts/setup/docker-entrypoint.sh` before `exec "$@"`
3. Write it to `/home/claude/.claude/.credentials.json`

The rest of the setup is unchanged.

---

### Option A: Docker Secrets

Native to Docker Compose — no extra tooling required.

**`docker-compose.yml`**
```yaml
services:
  claude-code:
    secrets:
      - claude_credentials
    environment:
      - CLAUDE_CREDENTIALS_FILE=/run/secrets/claude_credentials

secrets:
  claude_credentials:
    file: ./secrets/credentials.json  # gitignored
```

**`scripts/setup/docker-entrypoint.sh`** — add before `exec "$@"`:
```bash
if [ -f "${CLAUDE_CREDENTIALS_FILE:-}" ]; then
    mkdir -p /home/claude/.claude
    cp "$CLAUDE_CREDENTIALS_FILE" /home/claude/.claude/.credentials.json
fi
```

---

### Option B: HashiCorp Vault

Good fit if you're already running Vault locally or in your infrastructure.

**`Dockerfile`** — add `vault` to the image:
```dockerfile
RUN curl -fsSL https://releases.hashicorp.com/vault/1.17.0/vault_1.17.0_linux_amd64.zip \
    -o /tmp/vault.zip && unzip /tmp/vault.zip -d /usr/local/bin && rm /tmp/vault.zip
```

**`.env`** (gitignored):
```bash
VAULT_ADDR=http://your-vault-host:8200
VAULT_TOKEN=your-token
```

**`scripts/setup/docker-entrypoint.sh`** — add before `exec "$@"`:
```bash
if [ -n "${VAULT_ADDR:-}" ] && [ -n "${VAULT_TOKEN:-}" ]; then
    mkdir -p /home/claude/.claude
    vault kv get -field=value secret/claude-credentials \
        > /home/claude/.claude/.credentials.json
fi
```

---

### Option C: Bitwarden Secrets Manager

Good fit if you already use Bitwarden. Uses the `bws` CLI.

**`Dockerfile`** — add `bws` to the image:
```dockerfile
RUN curl -fsSL https://github.com/bitwarden/sdk/releases/latest/download/bws-x86_64-unknown-linux-gnu.zip \
    -o /tmp/bws.zip && unzip /tmp/bws.zip -d /usr/local/bin && rm /tmp/bws.zip
```

**`.env`** (gitignored):
```bash
BWS_ACCESS_TOKEN=your-access-token
CLAUDE_SECRET_ID=your-secret-uuid
```

**`scripts/setup/docker-entrypoint.sh`** — add before `exec "$@"`:
```bash
if [ -n "${BWS_ACCESS_TOKEN:-}" ] && [ -n "${CLAUDE_SECRET_ID:-}" ]; then
    mkdir -p /home/claude/.claude
    bws secret get "$CLAUDE_SECRET_ID" \
        | jq -r '.value' \
        > /home/claude/.claude/.credentials.json
fi
```

---

## What the credential file contains

The `~/.claude/.credentials.json` file is written by Claude Code during OAuth authentication. It contains your session token. Treat it like a password — gitignore it, don't log it, don't bind-mount it from a world-readable location.
