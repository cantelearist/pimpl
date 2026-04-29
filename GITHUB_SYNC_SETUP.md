# GitHub & Local Server Mirror Setup

## Overview
- **Primary Source**: GitHub (`origin`) - `https://github.com/cantelearist/pimpl.git`
- **Mirror/Dev**: Local Server (`local`) - `http://local_proxy@127.0.0.1:45139/git/cantelearist/pimpl`

GitHub is the source of truth. Changes should flow from GitHub → Local Server.

## Remotes Configuration

```bash
$ git remote -v
local   http://local_proxy@127.0.0.1:45139/git/cantelearist/pimpl (fetch)
local   http://local_proxy@127.0.0.1:45139/git/cantelearist/pimpl (push)
origin  https://github.com/cantelearist/pimpl.git (fetch)
origin  https://github.com/cantelearist/pimpl.git (push)
```

## Common Workflows

### 1. Sync Latest from GitHub to Local
```bash
# Fetch latest from GitHub
git fetch origin

# Merge or rebase if needed
git pull origin main

# Push to local server to keep in sync
git push local
```

### 2. Push Changes to GitHub (Primary)
```bash
# Make your changes locally
git commit -m "Your changes"

# Push to GitHub (primary)
git push origin main

# Sync local server
git push local main
```

### 3. Automatic Mirror Sync (All Branches)
```bash
# Run the sync script
./sync-remotes.sh

# Or manually fetch from both
git fetch origin
git fetch local
```

### 4. View All Remote Branches
```bash
# GitHub branches
git branch -r | grep origin/

# Local server branches
git branch -r | grep local/
```

## Setup Checklist

- [x] GitHub configured as `origin` (primary)
- [x] Local server configured as `local` (mirror)
- [x] Both remotes have fetch & push URLs set
- [ ] GitHub authentication (SSH key or personal token)
- [ ] Local server credentials verified
- [ ] First sync test completed

## Authentication

### GitHub HTTPS (Recommended for Mirrors)
If using HTTPS, you may need to:
1. Generate a Personal Access Token (PAT) on GitHub
2. Use: `git config credential.helper store`
3. Or update remote with: `git remote set-url origin https://USERNAME:TOKEN@github.com/cantelearist/pimpl.git`

### GitHub SSH
If using SSH:
1. Ensure SSH keys are in `~/.ssh/`
2. Test: `ssh -T git@github.com`
3. Update remote: `git remote set-url origin git@github.com:cantelearist/pimpl.git`

## Next Steps

1. **Test GitHub Connection**:
   ```bash
   git fetch origin
   ```

2. **Test Local Server Connection**:
   ```bash
   git fetch local
   ```

3. **Perform Initial Sync**:
   ```bash
   ./sync-remotes.sh
   ```

4. **Configure Default Branch** (if needed):
   ```bash
   git branch -u origin/main main  # Track GitHub main
   ```

## Troubleshooting

**Connection Error to GitHub**:
- Check internet connection
- Verify GitHub is accessible: `ping github.com`
- Check authentication (SSH keys or PAT)

**Connection Error to Local Server**:
- Verify local server is running
- Check network: `curl http://local_proxy@127.0.0.1:45139/`
- Verify credentials if authentication required

**Diverged Histories**:
```bash
# If branches diverged, rebase on GitHub version
git fetch origin
git rebase origin/main
```

---

**Setup Date**: 2026-04-29  
**Repository**: `cantelearist/pimpl`
