---
name: SlowDNS Manager v9 design
description: Key architectural decisions for the BLACK KILLER SSH Tunnel Manager v9.0 script
---

## User DB Format (users.txt)
9 pipe-delimited fields, NO header:
`user|pass|expiry_date|created_date|gb_limit|status|ar_days|ar_trigger|conn_limit`

- Field 6 (status): `active` or `locked`
- Field 7 (ar_days): auto-renew duration in days (0=disabled)
- Field 8 (ar_trigger): days before expiry to trigger auto-renew
- Field 9 (conn_limit): max simultaneous connections (0=unlimited)

**Why:** Extending the original 8-field DB; backward compat: default conn_limit=0 if missing.

## fun_bar() Usage Rule
`fun_bar "static_shell_command" "LABEL"`

**Never interpolate user-controlled or DB-sourced data into the command string.** Use direct bash calls with quoted args for per-user operations (e.g. in expired_users_cleaner).

**Why:** eval/bash-c with user data = root code injection risk.

## GitHub Push
- Remote: `https://github.com/cyberhinju-blip/slowdns-manager`
- Uses `GITHUB_TOKEN` Replit secret; set remote URL with token before push.
- `version.txt` in repo root is read by auto-updater to detect new versions.

## Auto-Updater Integrity Checks
Before replacing script: check shebang, grep "BLACK KILLER", `bash -n` syntax check, file size > 50KB.

## UI Style
- Headers: `\E[44;1;37m  TITLE  \E[0m`
- Separators: `◇────────────────────────────────────────────────────────◇`
- Boxes: `⋘═══════════════...⋙`
- All menu text: CAPITAL LETTERS, English only
