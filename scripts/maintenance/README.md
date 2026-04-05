# Maintenance Scripts

Scripts for ongoing maintenance of the Claude Code sandbox.

## Planned

| Script | Purpose |
|--------|---------|
| `backup-workspace.sh` | Tar the `claude-sandbox-workspace` volume to a local archive |
| `update-claude.sh` | Rebuild the image to pick up a newer `@anthropic-ai/claude-code` version |
| `reset-workspace.sh` | **Destructive** — destroy and reinitialize the workspace volume |

## Volume Management

```bash
# List sandbox volumes
docker volume ls | grep claude-sandbox

# Inspect workspace volume
docker volume inspect claude-sandbox-workspace

# Manual backup
docker run --rm \
  -v claude-sandbox-workspace:/workspace:ro \
  -v $(pwd):/backup \
  ubuntu:24.04 \
  tar czf /backup/workspace-backup-$(date +%Y%m%d).tar.gz -C / workspace
```
