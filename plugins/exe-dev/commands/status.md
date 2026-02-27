---
name: status
description: Quick health check of exe.dev VMs
allowed-tools:
  - Bash
---

Show a quick summary of the user's exe.dev VMs.

Run `ssh exe.dev ls --json` and parse with `jq`.

Present a compact summary:

```
## exe.dev Status

2 VMs total: 1 running, 1 stopped

| VM | Status | URL |
|----|--------|-----|
| my-dev | running | https://my-dev.exe.xyz |
| old-test | stopped | https://old-test.exe.xyz |
```

If the SSH command fails, check whether SSH keys are configured:

```bash
grep -c 'exe.dev' ~/.ssh/config 2>/dev/null || echo "0"
```

If no config found, suggest adding:

```
Host exe.dev *.exe.xyz
  IdentitiesOnly yes
  IdentityFile ~/.ssh/id_ed25519
```
