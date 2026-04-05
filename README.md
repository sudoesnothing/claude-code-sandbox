# Claude Code Sandbox

A fully isolated, containerized development environment for [Claude Code](https://claude.ai/code).

All development happens inside a Docker container (Ubuntu 24.04). Your workspace lives in a named Docker volume — not a bind mount — so data persists across container rebuilds and your host filesystem stays untouched.

## What's Inside

- **Ubuntu 24.04** base
- **Node.js 22 LTS** + npm
- **Claude Code CLI** (latest)
- **Python 3** + pip + venv
- **git**, curl, wget, jq, vim, rsync, sox
- **VS Code Dev Containers** compatible

## Quick Start

### Prerequisites

- Docker Desktop with WSL2 backend
- VS Code with the [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension

### 1. Start the sandbox (from WSL)

```bash
bash /d/Development/Infrastructure/claude-code-sandbox/scripts/setup/start-claude-code-sandbox.sh
```

### 2. Open in VS Code

```
F1 → Dev Containers: Attach to Running Container → claude-sandbox
```

Or from this repo folder:
```
F1 → Dev Containers: Reopen in Container
```

### 3. Authenticate Claude Code

Inside the container terminal:
```bash
claude
```

Follow the browser OAuth flow. Credentials are stored in the `claude-sandbox-claude-config` volume and persist across restarts.

## Configuration

Copy `.env.example` to `.env` to customize resource limits:

```bash
cp .env.example .env
```

```bash
# .env
SANDBOX_MEMORY_LIMIT=12g
SANDBOX_CPU_LIMIT=6
```

## Workspace Structure (WAT Framework)

```
/workspace/
├── projects/       # Active projects — each is its own git repo
├── infrastructure/ # IaC configs (n8n, containerlab, claude)
├── web/            # Web projects
├── tools/          # Utility scripts (Python, PowerShell, bash)
├── workflows/      # Markdown SOPs — the WAT "Workflows" layer
├── prompts/        # Claude prompt library
├── .tmp/           # Temp files (gitignored)
├── .env            # API keys (gitignored, never commit)
└── CLAUDE.md       # WAT framework instructions for Claude Code
```

## Volumes

| Volume | Purpose |
|--------|---------|
| `claude-sandbox-workspace` | All workspace data |
| `claude-sandbox-claude-config` | Claude Code credentials and config |

## Using as a Template

1. Fork or clone this repo
2. Copy `.env.example` to `.env`
3. Run `bash scripts/setup/start-claude-code-sandbox.sh`
4. Authenticate Claude Code inside the container
5. Add your own `CLAUDE.md` to `/workspace/`

## Security

- Runs as non-root user `claude` (UID 1001)
- All Linux capabilities dropped
- `no-new-privileges` enforced
- No ports published to host
- Credentials stored in named volume, never in the image or repo
