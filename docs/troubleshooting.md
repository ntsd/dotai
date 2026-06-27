# DotAI Infrastructure Troubleshooting

## Systemd Services

### Services not starting

```bash
# Check status
sudo systemctl status hermes-dashboard

# Check logs
sudo journalctl -u hermes-dashboard -f
```

**Fix:** Ensure the env files exist and have correct paths:
- `~/hermes.env`

Verify systemd units point to the correct paths:
```bash
cat /etc/systemd/system/hermes-dashboard.service | grep ExecStart
```

### Service won't start after reboot

```bash
sudo systemctl daemon-reload
make systemd-link
make systemd-enable
```

### PATH not set in systemd

Services source `.bashrc`. If custom binaries are needed:

```bash
# In hermes.env or .bashrc
export PATH="$PATH:/path/to/bin"
```

### Hermes Dashboard refuses to bind to 0.0.0.0

If you see this error in the dashboard logs:
```
Refusing to bind dashboard to 0.0.0.0 — the auth gate engages on non-loopback binds, but no auth providers are registered.
```

**Fix:** When exposing the dashboard on a public interface (`0.0.0.0`), it requires an authentication provider to be configured. You can set up basic auth in `~/hermes.env`:

1. Generate a password hash for your chosen password:
```bash
/home/ntsd/.hermes/hermes-agent/venv/bin/python3 -c "from plugins.dashboard_auth.basic import hash_password; print(hash_password('your-password'))"
```

2. Add the username and generated password hash to `~/hermes.env`:
```bash
HERMES_DASHBOARD_BASIC_AUTH_USERNAME=admin
HERMES_DASHBOARD_BASIC_AUTH_PASSWORD_HASH="your-generated-hash"
```

3. Restart the dashboard service:
```bash
sudo systemctl restart hermes-dashboard
```



## GPU Issues (vLLM)

### vLLM not finding GPU

```bash
nvidia-smi
docker ps | grep vllm
```

### OOM errors

Reduce context window or batch size in `vllm/*/docker-compose.yml`.

### Docker port conflicts

```bash
# Check if port 8000 is in use
ss -tlnp | grep 8000

# Modify docker-compose.yml to use a different port
# Then update config.yaml base_url
```
