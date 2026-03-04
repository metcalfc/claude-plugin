---
name: exe-new
description: >-
  Create a new exe.dev VM. Use when the user says "create a VM", "make a VM",
  "spin up a VM", "new VM", "launch a VM", "start a new VM on exe", "make VMs
  on exe", "set up an exe.dev machine", or any request to create, provision, or
  launch exe.dev virtual machines.
argument-hint: "[--image=<image>]"
allowed-tools:
  - Bash
  - Read
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
