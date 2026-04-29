# Local Git Mirror Server Setup

This Docker-based local server mirrors GitHub and runs on `localhost:45139`, synchronizing with GitHub every 5 minutes.

## Quick Start

### 1. Start the Local Mirror Server

```bash
# Build and start the Docker container
docker-compose up -d

# Check status
docker-compose ps
docker logs pimpl-git-mirror
```

### 2. Verify It's Working

```bash
# Test the server is accessible
curl http://localhost:45139/

# You should see: "Git Mirror Server" info page
```

### 3. Sync Your Local Repository

```bash
# Fetch from both remotes
git fetch origin
git fetch local

# Or use the sync script
./sync-remotes.sh
```

## What's Included

- **Dockerfile** - Python-based git HTTP server with git-http-backend
- **docker-compose.yml** - Container orchestration
- **entrypoint.sh** - Initialization and auto-sync logic

## Server Features

✅ **Auto-sync from GitHub** - Every 5 minutes  
✅ **Git HTTP Protocol Support** - Clone/push over HTTP  
✅ **Persistent Storage** - Docker volume `git_data`  
✅ **Web Interface** - Info page at `http://localhost:45139/`

## Management

### View Logs
```bash
docker logs -f pimpl-git-mirror
```

### Restart Server
```bash
docker-compose restart
```

### Manual Sync (inside container)
```bash
docker exec pimpl-git-mirror git -C /var/git/pimpl.git fetch --all
```

### Stop Server
```bash
docker-compose down
```

### Remove Everything (including data)
```bash
docker-compose down -v
```

## Git Commands with Local Server

### Clone from Local
```bash
git clone http://127.0.0.1:45139/git/pimpl.git
```

### Add as Remote
```bash
# Already configured in this repo as "local"
git fetch local
git push local main
```

### View Mirror Status
```bash
# See all branches in both remotes
git branch -r

# Should show:
# origin/main
# origin/claude/github-local-sync-setup-INEIQ
# local/main
# local/claude/github-local-sync-setup-INEIQ
```

## Troubleshooting

### "Cannot connect to localhost:45139"
1. Check if container is running: `docker ps`
2. Check logs: `docker logs pimpl-git-mirror`
3. Restart: `docker-compose restart`

### "Repository not found"
- Container needs time to initialize on first run (creates mirror from GitHub)
- Wait 30-60 seconds and try again
- Check logs: `docker logs pimpl-git-mirror`

### "Failed to sync from GitHub"
- Check internet connection
- Verify GitHub is accessible: `ping github.com`
- Server will retry automatically every 5 minutes

### Out of sync with GitHub
- Sync happens automatically every 5 minutes
- Force manual sync: `docker exec pimpl-git-mirror git -C /var/git/pimpl.git fetch --all`

## Architecture

```
GitHub (Source of Truth)
    ↓ (mirrors every 5 min)
Docker Container (Local Mirror Server)
    ↓ (git fetch/push)
Your Local Repository
```

## Performance Notes

- **First run**: ~1-2 minutes to clone GitHub repo (depends on size & network)
- **Sync interval**: 5 minutes (configurable in entrypoint.sh)
- **Disk usage**: ~100MB+ (depends on repository size)

## Next Steps

1. Start the server: `docker-compose up -d`
2. Test sync: `./sync-remotes.sh`
3. Work with both remotes using git commands

---

**Setup Date**: 2026-04-29
