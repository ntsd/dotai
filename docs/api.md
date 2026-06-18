# DotAI Infrastructure API

## Systemd Services

```bash
# Generate and link services
make systemd-link

# Enable all services
make systemd-enable

# Start all services
make systemd-start
```

### Service Units

| Service | File | Description |
|---------|------|-------------|
| hermes-gateway | `systemd/hermes-gateway.service` | API server (port 8642) |
| hermes-dashboard | `systemd/hermes-dashboard.service` | Web UI (port 9119) |

| Systemd units | `systemd/*.service` |
