---
name: exe-share
description: Manage exe.dev VM sharing and public access
argument-hint: "<vmname> [public|private|add <email>|port <port>]"
allowed-tools:
  - Bash
  - Read
---

Manage sharing and access control for an exe.dev VM.

Parse the arguments to determine the action:

- `<vmname> public` → `ssh exe.dev share set-public <vmname>`
- `<vmname> private` → `ssh exe.dev share set-private <vmname>`
- `<vmname> add <email>` → `ssh exe.dev share add <vmname> <email>`
- `<vmname> port <port>` → `ssh exe.dev share port <vmname> <port>`
- `<vmname> link` → `ssh exe.dev share add-link <vmname>`
- `<vmname> remove <email>` → `ssh exe.dev share remove <vmname> <email>`

If only a VM name is provided with no action, show the current sharing state by running `ssh exe.dev ls --json` and filtering for that VM, then ask what the user wants to do.

After any action, confirm what was done and show the VM's public URL: `https://<vmname>.exe.xyz`.
