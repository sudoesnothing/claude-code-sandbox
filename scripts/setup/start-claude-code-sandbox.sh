#!/usr/bin/env bash
# start-claude-code-sandbox.sh
# Starts the Claude Code sandbox container, building it first if needed.
#
# Usage (from the repo root):
#   bash scripts/setup/start-claude-code-sandbox.sh
#
# Works on Linux, macOS, and Windows (Git Bash / WSL).

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CONTAINER_NAME="claude-sandbox"
PROJECT_NAME="claude-sandbox"

check_docker() {
    if ! docker info &>/dev/null; then
        echo "ERROR: Docker is not running. Please start Docker and try again."
        exit 1
    fi
}

print_status() {
    local status
    status=$(docker inspect --format='{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || echo "missing")
    echo ""
    echo "=============================================="
    echo "  Claude Code Sandbox"
    echo "=============================================="
    echo "  Container : ${CONTAINER_NAME}  [${status}]"
    echo ""
    echo "  Attach in VS Code:"
    echo "    F1 -> Dev Containers: Attach to Running Container"
    echo ""
    echo "  Open a shell:"
    echo "    docker exec -it ${CONTAINER_NAME} bash"
    echo ""
    echo "  Run Claude Code:"
    echo "    docker exec -it ${CONTAINER_NAME} claude"
    echo "=============================================="
}

check_docker

CONTAINER_STATUS=$(docker inspect --format='{{.State.Status}}' "${CONTAINER_NAME}" 2>/dev/null || echo "missing")

case "${CONTAINER_STATUS}" in
    "running")
        echo "[claude-sandbox] Already running."
        ;;
    "exited" | "created" | "paused")
        echo "[claude-sandbox] Starting stopped container..."
        docker start "${CONTAINER_NAME}"
        ;;
    "missing")
        echo "[claude-sandbox] Building and starting..."
        docker compose -f "${REPO_ROOT}/docker-compose.yml" -p "${PROJECT_NAME}" up -d --build
        ;;
    *)
        docker compose -f "${REPO_ROOT}/docker-compose.yml" -p "${PROJECT_NAME}" up -d
        ;;
esac

print_status
