---
name: help
description: (exe-dev) Plugin help
allowed-tools: []
---

Display the following help text to the user:

```
exe-dev — exe.dev VM management via SSH CLI and HTTPS API

COMMANDS:
  /exe-ls              List VMs with status
  /exe-new             Create a new VM
  /exe-share           Manage VM sharing and public access
  /exe-status          Quick health check of all VMs
  /exe-dev:add         Request a new feature (files an issue)
  /exe-dev:issue       Report a bug (gathers context, you review before filing)
  /exe-dev:help        This help text

SKILL:
  exe-dev-knowledge    SSH CLI, HTTPS API, HTTP proxy, sharing, templates,
                       LLM gateway, email, Shelley, custom domains, VSCode

USAGE:
  /exe-ls                    List all VMs
  /exe-status                Quick summary of VM health
  /exe-new                   Create a VM (default image)
  /exe-new --image=ubuntu    Create a VM with specific image
  /exe-share my-vm           Manage sharing for a VM
```
