#!/usr/bin/env bash
# start-claude-code-sandbox.sh
# Starts or attaches to the Claude Code sandbox container.
# Run from WSL: bash /d/Development/Infrastructure/claude-code-sandbox/scripts/setup/start-claude-code-sandbox.sh

set -e

COMPOSE_FILE="/d/Development/Infrastructure/claude-code-sandbox/docker-compose.yml"
CONTAINER_NAME="claude-sandbox"
PROJECT_NAME="claude-sandbox"

check_docker() {
    if ! docker info &>/dev/null; then
        echo "ERROR: Docker is not running. Start Docker Desktop and try again."
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
    echo "  Container : ${CONTAINER_NAME}"
    echo "  Status    : ${status}"
    echo ""
    echo "  Open in VS Code:"
    echo "    F1 → Dev Containers: Attach to Running Container"
    echo "    Select: ${CONTAINER_NAME}"
    echo ""
    echo "  Open a shell:"
    echo "    docker exec -it ${CONTAINER_NAME} bash"
    echo ""
    echo "  Run Claude Code directly:"
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
        echo "[claude-sandbox] Container stopped — starting..."
        docker start "${CONTAINER_NAME}"
        echo "[claude-sandbox] Started."
        ;;
    "missing")
        echo "[claude-sandbox] Container not found — building and starting..."
        docker compose -f "${COMPOSE_FILE}" -p "${PROJECT_NAME}" up -d --build
        echo "[claude-sandbox] Started."
        ;;
    *)
        echo "[claude-sandbox] Container state: ${CONTAINER_STATUS} — attempting start..."
        docker compose -f "${COMPOSE_FILE}" -p "${PROJECT_NAME}" up -d
        ;;
esac

print_status
