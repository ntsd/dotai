# DotAI Infrastructure Troubleshooting

## Systemd Services

### Services not starting

```bash
# Check status
sudo systemctl status hermes-gateway
sudo systemctl status hermes-dashboard
sudo systemctl status hermes-workspace

# Check logs
sudo journalctl -u hermes-gateway -f
sudo journalctl -u hermes-workspace -f
```

**Fix:** Ensure the env files exist and have correct paths:
- `~/hermes-gateway.env`
- `~/hermes-workspace.env`

Verify systemd units point to the correct paths:
```bash
cat /etc/systemd/system/hermes-gateway.service | grep ExecStart
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
# In hermes-gateway.env or .bashrc
export PATH="$PATH:/path/to/bin"
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
