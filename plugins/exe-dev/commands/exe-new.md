---
name: exe-new
description: (exe-dev) Create a new VM
argument-hint: "[--image=<image>]"
allowed-tools:
  - Bash
  - Read
  - Edit
  - AskUserQuestion
---

Create a new exe.dev virtual machine.

If the user provided an `--image` argument, pass it through:
```
ssh exe.dev new --image=<image>
```

Otherwise, create with the default image:
```
ssh exe.dev new
```

After creation, parse the output and present:
- VM name
- HTTPS URL (`https://<vmname>.exe.xyz`)
- SSH command (`ssh <vmname>.exe.xyz`)
- Shelley URL (`https://<vmname>.shelley.exe.xyz/`)

Remind the user the VM is private by default. To make it public: `ssh exe.dev share set-public <vmname>`.

## SSH config alias

After VM creation, offer to add an SSH alias to `~/.ssh/config` via AskUserQuestion:

- **Add SSH alias** — ask for a friendly name (or suggest one based on VM purpose), then add it
- **Skip** — don't touch SSH config

If the user wants an alias:

1. Read `~/.ssh/config`
2. Ensure the exe.dev wildcard block exists (add at the end if missing):
   ```
   Host exe.dev *.exe.xyz
     IdentitiesOnly yes
     IdentityFile ~/.ssh/id_ed25519
   ```
3. Add a Host alias entry after the wildcard block:
   ```
   Host <alias>
     HostName <vmname>.exe.xyz
   ```
4. Use the Edit tool to modify `~/.ssh/config` — NEVER overwrite the entire file
5. Confirm to the user: `ssh <alias>` is now available
