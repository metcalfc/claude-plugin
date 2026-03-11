---
name: exe-ls
description: (exe-dev) List VMs with status
allowed-tools:
  - Bash
  - Read
---

List the user's exe.dev virtual machines.

Run `ssh exe.dev ls --json` and parse the output with `jq`.

Present results as a table with columns: Name, Alias, Status, Image, URL.

The URL for each VM is `https://<vm_name>.exe.xyz` and SSH is `ssh <vm_name>.exe.xyz`.

To populate the Alias column, read `~/.ssh/config` and look for `Host <alias>` entries whose `HostName` matches `<vm_name>.exe.xyz`. Show the alias if found, or `-` if no alias exists.

If the command fails, check whether the user has SSH keys configured for exe.dev and suggest adding an SSH config entry:

```
Host exe.dev *.exe.xyz
  IdentitiesOnly yes
  IdentityFile ~/.ssh/id_ed25519
```
