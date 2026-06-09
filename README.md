# DotAI Systemd

## Project Structure

```text
├── systemd/              # Systemd service files for 24/7 operation
│   ├── README.md         # Systemd setup guide
│   ├── *.service.template # Service unit templates
│   └── *.service          # Generated service units
```

## Documentation

| Document | Description |
|----------|-------------|
| [systemd/README.md](systemd/README.md) | Systemd service configuration |

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make systemd-link` | Link systemd services to `/etc/systemd/system/` |
| `make systemd-enable` | Enable all services on boot |
| `make systemd-start` | Start all services |
| `make systemd-stop` | Stop all services |
| `make systemd-status` | Show service status |
| `make systemd-logs` | Show service logs |
| `make systemd-refresh` | Full refresh (generate → link → enable → start) |
