# Security and Publishing Notes

## Do not publish

- Passwords.
- Private SSH keys.
- Tailscale auth keys.
- Full disk packs or backups.
- Private home-network details that are not needed for reproduction.
- Generated logs containing private hostnames or addresses.

## Safe to publish

- Host number design: host `41` / octal `051`.
- Sanitized SIMH snippets with placeholder IP addresses.
- Setup procedure and validation commands.
- Scripts that use placeholders and environment variables.

## Recommended placeholders

```text
<PI_TAILSCALE_IP>
<CIVITAE_TAILSCALE_IP>
<ARPANET_REPO_PATH>
<PIDP10_ROOT>
```

## Repository boundary

Keep private deployment details in local notes or `.env` files. Keep this public repository reproducible but not site-secret-bearing.
