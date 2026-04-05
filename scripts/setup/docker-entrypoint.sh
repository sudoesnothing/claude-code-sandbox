#!/bin/bash
set -e

WORKSPACE=/workspace
INIT_MARKER="${WORKSPACE}/.initialized"

initialize_workspace() {
    echo "[claude-sandbox] First run detected — initializing workspace..."

    # WAT Framework directories
    mkdir -p \
        "${WORKSPACE}/.tmp" \
        "${WORKSPACE}/tools" \
        "${WORKSPACE}/workflows" \
        "${WORKSPACE}/projects" \
        "${WORKSPACE}/infrastructure" \
        "${WORKSPACE}/web" \
        "${WORKSPACE}/prompts"

    # Create workspace README
    if [ ! -f "${WORKSPACE}/README.md" ]; then
        cat > "${WORKSPACE}/README.md" << 'EOF'
# Workspace

WAT Framework — Workflows, Agents, Tools.

## Structure

| Directory | Purpose |
|-----------|---------|
| `projects/` | Active projects (operauto, etc.) — each is its own git repo |
| `infrastructure/` | IaC configs (n8n, containerlab, claude extensions) |
| `web/` | Web projects (operauto.com) |
| `tools/` | Python, PowerShell, and other utility scripts |
| `workflows/` | Markdown SOPs — how to do things in this environment |
| `prompts/` | Claude prompt library |
| `.tmp/` | Temporary files — regenerated as needed, gitignored |
| `.env` | API keys and secrets — gitignored, never commit |

## WAT Pattern

- **Workflows** (`workflows/`) — Plain-language SOPs defining what to do and how
- **Agents** — Claude Code (you are here)
- **Tools** (`tools/`) — Python scripts for deterministic execution

## Quick Reference

```bash
claude          # Start Claude Code
python3 script  # Run a tool
```
EOF
    fi

    # Create workspace .gitignore
    if [ ! -f "${WORKSPACE}/.gitignore" ]; then
        cat > "${WORKSPACE}/.gitignore" << 'EOF'
# Secrets — never commit
.env
*.credentials.json
.credentials.json
token.json

# Temp files
.tmp/
*.log

# Python
__pycache__/
*.py[cod]
.venv/
venv/

# Node
node_modules/

# OS
.DS_Store
Thumbs.db
EOF
    fi

    # Mark as initialized
    touch "${INIT_MARKER}"
    echo "[claude-sandbox] Workspace initialized at ${WORKSPACE}"
}

# Run initialization only on first start
if [ ! -f "${INIT_MARKER}" ]; then
    initialize_workspace
fi

exec "$@"
