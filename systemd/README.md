# Systemd

To make all the agent service always run 24/7 on a Linux machine and automated start we need systemd setup.

Available services:
- `hermes-dashboard` (Hermes Agent Dashboard)
- `agentsview` (AgentsView AI Sessions Web UI)

## Installation using Makefile (Recommended)

From the repository root:

```sh
# Generate service files and link them to /etc/systemd/system
make systemd-link

# Enable and start services
make systemd-start

# Check status of all services
make systemd-status

# View recent service logs
make systemd-logs
```

## Manual Installation

1. Generate local `.service` files from template

```sh
env USER="$USER" HOME="$HOME" envsubst < "$(pwd)/agentsview.service.template" > "$(pwd)/agentsview.service"
env USER="$USER" HOME="$HOME" envsubst < "$(pwd)/hermes-dashboard.service.template" > "$(pwd)/hermes-dashboard.service"
```

The templates use `${USER}` for `User` and `Group`, and `${HOME}` for paths.

2. Link systemd file to /etc/systemd/system

```sh
sudo ln -sf "$(pwd)/agentsview.service" /etc/systemd/system/agentsview.service
sudo ln -sf "$(pwd)/hermes-dashboard.service" /etc/systemd/system/hermes-dashboard.service
```

3. Create env file for additional environments (optional)

```sh
touch ~/agentsview.env
touch ~/hermes.env
```

then put the required env there for each service.

Tip: you can also set `PATH` inside the env to allow access to binary files or CLI tools.

All services now load `~/.bashrc` in `ExecStart` before running their command.

4. Start systemd by systemctl

```sh
sudo systemctl daemon-reload

sudo systemctl enable --now agentsview
sudo systemctl enable --now hermes-dashboard
```

5. Check status and the journalctl log

```sh
sudo systemctl status agentsview
sudo journalctl -u agentsview -f
```

6. To disable systemd service

By disabling systemd the service will not automatically start anymore:

```sh
sudo systemctl stop agentsview
sudo systemctl disable agentsview
```

