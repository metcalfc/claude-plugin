---
name: exe-ls
description: List exe.dev VMs with status
allowed-tools:
  - Bash
  - Read
---

List the user's exe.dev virtual machines.

Run `ssh exe.dev ls --json` and parse the output with `jq`.

Present results as a table with columns: Name, Status, Image, URL.

The URL for each VM is `https://<vm_name>.exe.xyz` and SSH is `ssh <vm_name>.exe.xyz`.

If the command fails, check whether the user has SSH keys configured for exe.dev and suggest adding an SSH config entry:

```
Host exe.dev *.exe.xyz
  IdentitiesOnly yes
  IdentityFile ~/.ssh/id_ed25519
```
