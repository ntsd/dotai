# DotAI Infrastructure Runbook

## Getting Started

```bash
# 3. Generate systemd services from templates
make systemd-generate

# 4. Link and enable systemd services
make systemd-link
make systemd-enable

# 5. Start all services
make systemd-start

# 6. Verify everything is running
make systemd-status
```

## Restarting Services

```bash
# Full restart
make systemd-stop
make systemd-start

# Individual service restart
sudo systemctl restart hermes-gateway
sudo systemctl restart hermes-dashboard
```

## Emergency Procedures

### Full Service Failure

```bash
# 1. Check if systemd is running
systemctl is-active hermes-gateway

# 2. If not, regenerate and restart
make systemd-link
make systemd-start

# 3. Check logs for root cause
sudo journalctl -u hermes-gateway -n 200 --no-pager
```

### Config Corruption Recovery

```bash
# Stop services
make systemd-stop

# Re-link from clean source
make hermes-link
make systemd-link

# Start fresh
make systemd-start
```

### Network Isolation

```bash
# Stop all services
make systemd-stop

# Disable auto-start
make systemd-disable

# Verify
make systemd-status
```

### Hardware Issues
- **Disk full**: `df -h`, clean journal logs, remove old vLLM caches

## Service Ports

| Service | Port | Protocol | Purpose |
|---------|------|----------|---------|
| vLLM models | 8000 | HTTP/OpenAI | LLM inference API |

## Glossary

| Term | Definition |
|------|------------|
| **vLLM** | High-performance LLM inference engine |
