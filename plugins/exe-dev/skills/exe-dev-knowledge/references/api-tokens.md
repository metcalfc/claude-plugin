# HTTPS API & Tokens

exe.dev exposes a programmatic HTTPS API alongside the SSH CLI. This enables automation, CI/CD, and integrations without SSH.

## Endpoint

```
POST https://exe.dev/exec
Authorization: Bearer <token>
Content-Type: application/json

{"args": ["ls", "--json"]}
```

The `args` array mirrors the SSH CLI — anything you can run as `ssh exe.dev <command>` works here.

## Token System (exe0)

Tokens are generated locally using SSH key signing — no web UI needed.

### Token Format

```
exe0.[permissions_base64].[signature_base64]
```

- `exe0` prefix identifies the token type
- Permissions are a JSON object, base64-encoded
- Signature is created with your SSH private key

### Generating a Token

```bash
# Create permissions JSON
PERMS='{"exp":"2026-04-01T00:00:00Z"}'

# Sign with SSH key (produces armored signature)
echo -n "$PERMS" | ssh-keygen -Y sign -f ~/.ssh/id_ed25519 -n exe0@exe.dev

# Assemble: exe0.<base64_perms>.<base64_sig>
```

The signing namespace is `exe0@exe.dev`.

### Permission Fields

| Field | Type | Description |
|-------|------|-------------|
| `exp` | RFC 3339 timestamp | Token expires after this time |
| `nbf` | RFC 3339 timestamp | Token not valid before this time |
| `cmds` | string array | Restrict to specific commands (e.g., `["ls", "new"]`) |
| `ctx` | object | Custom JSON data — passed to VM servers via proxy headers |

### Examples

```json
// Read-only token (ls only, expires in 1 hour)
{"exp":"2026-03-13T19:00:00Z","cmds":["ls"]}

// Full access, valid for 30 days
{"exp":"2026-04-13T00:00:00Z"}

// Create-only with custom context
{"cmds":["new"],"ctx":{"team":"backend","env":"staging"}}
```

## VM-Scoped Tokens

For authenticating against a specific VM's HTTP proxy (not the lobby), use namespace `v0@VMNAME.exe.xyz`:

```bash
echo -n "$PERMS" | ssh-keygen -Y sign -f ~/.ssh/id_ed25519 -n v0@myvm.exe.xyz
```

VM-scoped tokens work with both Bearer and Basic auth — making them git-compatible:

```bash
# Bearer auth
curl -H "Authorization: Bearer exe0...." https://myvm.exe.xyz/api/data

# Basic auth (username ignored, token as password)
git clone https://x:exe0....@myvm.exe.xyz/repo.git
```

## Short Tokens (exe1)

Long exe0 tokens can be converted to opaque server-side handles:

```
exe0-to-exe1 conversion (details TBD — check upstream docs)
```

The exe1 format is shorter and suitable for embedding in URLs or environment variables.

## Usage Notes

- Tokens are self-contained — the server validates the signature against your registered SSH public keys
- Revoke by removing the SSH key from your account (`ssh exe.dev ssh-key`)
- The `ctx` field is forwarded as a proxy header to VMs, enabling custom auth/routing logic
- For CI/CD: generate a scoped token with minimal `cmds` and a short `exp`
