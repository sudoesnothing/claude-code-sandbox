# Claude Code Sandbox

A minimal, isolated Docker environment for running [Claude Code](https://claude.ai/code).

Claude Code runs entirely inside a container. Your workspace is stored in a named Docker volume — not a bind mount to your host — so it persists across container rebuilds and your host filesystem stays clean.

## What's Included

- **Ubuntu 24.04**
- **Node.js 22 LTS**
- **Claude Code CLI** (latest)
- **git**, curl, sudo
- **VS Code Dev Containers** support

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (Desktop or Engine)
- [VS Code](https://code.visualstudio.com/) + [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) *(optional)*

## Quick Start

```bash
# Clone the repo
git clone https://github.com/sudoesnothing/claude-code-sandbox.git
cd claude-code-sandbox

# Start the container
bash scripts/setup/start-claude-code-sandbox.sh
```

Then authenticate Claude Code inside the container:

```bash
docker exec -it claude-sandbox claude
```

Follow the browser OAuth flow. Credentials are stored in the `claude-sandbox-claude-config` volume and persist across restarts.

## VS Code

```
F1 -> Dev Containers: Reopen in Container
```

or attach to the running container:

```
F1 -> Dev Containers: Attach to Running Container -> claude-sandbox
```

## Configuration

Copy `.env.example` to `.env` to adjust resource limits:

```bash
cp .env.example .env
```

| Variable | Default | Description |
|----------|---------|-------------|
| `SANDBOX_MEMORY_LIMIT` | `8g` | Container memory — adjust to your machine |
| `SANDBOX_CPU_LIMIT` | `4` | vCPU count — adjust to your machine |

## Workspace

The container starts with a minimal `/workspace/projects/` directory. Organize it however you like.

An optional WAT framework (Workflows / Agents / Tools) layout is documented in [`CLAUDE.md`](CLAUDE.md) and pre-scaffolded in [`scripts/setup/docker-entrypoint.sh`](scripts/setup/docker-entrypoint.sh) if you want a structured starting point.

## Volumes

| Volume | Purpose |
|--------|---------|
| `claude-sandbox-workspace` | Workspace data |
| `claude-sandbox-claude-config` | Claude credentials and config |

## Security

- Non-root user (`claude`, UID 1001) with passwordless sudo
- No ports published to the host
- Credentials stored in a named volume, never in the image

## Credits

The `CLAUDE.md` in this repo is a simplified template based on the **WAT (Workflows / Agents / Tools)** framework. Credit to [Nate Herk](https://www.youtube.com/@nateherk) for the inspiration — his work in agentic AI and automation is worth checking out if you want to go deeper with Claude Code and practical AI workflows.

The full, ready-to-use WAT `CLAUDE.md` file is available in the Classroom of his free community:
[AI Automation Society](https://skool.com/ai-automation-society/about)
