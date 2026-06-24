# Systemd

To make all the agent service always run 24/7 on a Linux machine and automated start we need systemd setup.

## Installation

1. Generate local `.service` files from template

```sh
env USER="$USER" HOME="$HOME" envsubst < "$(pwd)/hermes-gateway.service.template" > "$(pwd)/hermes-gateway.service"
env USER="$USER" HOME="$HOME" envsubst < "$(pwd)/hermes-dashboard.service.template" > "$(pwd)/hermes-dashboard.service"
```

The templates use `${USER}` for `User` and `Group`, and `${HOME}` for paths.

2. Link systemd file to /etc/systemd/system

```sh
sudo ln -sf "$(pwd)/hermes-gateway.service" /etc/systemd/system/hermes-gateway.service
sudo ln -sf "$(pwd)/hermes-dashboard.service" /etc/systemd/system/hermes-dashboard.service
```

3. Create env file for additional environments

```sh
touch ~/hermes.env
```

then put the requires env there for each service.

Tip: you can also set `PATH` inside the env to allow access the binary files or cli tools.

All services now load `~/.bashrc` in `ExecStart` before running their command.

Example hermes.env

```sh
API_SERVER_ENABLED=true
API_SERVER_HOST=0.0.0.0
API_SERVER_KEY=dummypassword

GATEWAY_ALLOW_ALL_USERS=true
```

4. Start systemd by systemctl

```sh
sudo systemctl daemon-reload

sudo systemctl enable --now hermes-gateway
sudo systemctl enable --now hermes-dashboard
```

5. Check status and the journalctl log

```sh
sudo systemctl status hermes-gateway
sudo systemctl status hermes-dashboard

sudo journalctl -u hermes-gateway -f
sudo journalctl -u hermes-dashboard -f
```

6. To disable systemd service

by disable systemd the service will not automatic start anymore

```sh
sudo systemctl stop hermes-gateway
sudo systemctl stop hermes-dashboard

sudo systemctl disable hermes-gateway
sudo systemctl disable hermes-dashboard
```
