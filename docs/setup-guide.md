# DotAI Infrastructure Setup Guide

## Configure Systemd

Generate systemd services from templates:

```bash
cd systemd
env USER="$USER" HOME="$HOME" envsubst < "$(pwd)/hermes-dashboard.service.template" > "$(pwd)/hermes-dashboard.service"
env USER="$USER" HOME="$HOME" envsubst < "$(pwd)/agentsview.service.template" > "$(pwd)/agentsview.service"
```

Link and enable:

```bash
make systemd-link
make systemd-enable
```

Or use the Makefile shorthand:

```bash
make systemd-link    # Generate + link services
make systemd-enable  # Enable all services
```

## LLM Inference (sparkrun)

GPU-based LLM inference runs via sparkrun:

### Qwen3.8-27B (sparkrun)

Install `sparkrun` first if not already installed:

```bash
uvx sparkrun setup
```

Run the recipe:

```bash
# Run solo on single DGX Spark node
sparkrun run sparkrun/qwen-3.8-27b-sglang/recipe.yaml --solo

# Auto restart when the OS restarts (or: make sparkrun-run)
sparkrun run sparkrun/qwen-3.8-27b-sglang/recipe.yaml --solo --restart unless-stopped

# Or specify cluster/host
sparkrun run sparkrun/qwen-3.8-27b-sglang/recipe.yaml --hosts <spark-ip>

# View logs
sparkrun logs Qwen3.8-27B-NVFP4
```

This uses the `RadixArk/Qwen3.8-27B-NVFP4` checkpoint with `incoai/Qwen3.8-27B-DFlash2` speculative decoding via SGLang.

### Verify Inference

All setups expose the OpenAI-compatible API at `http://localhost:8000/v1`:

```bash
curl http://localhost:8000/v1/models | jq '.data[0].id'
```

After inference is running, update `~/.hermes/profiles/common/config.yaml` to point to the correct endpoint:

```yaml
custom_providers:
  - name: Spark.ntsd.dev:8000
    base_url: http://spark.ntsd.dev:8000/v1
    model: qwen36-fast
```

See [troubleshooting.md](troubleshooting.md) for GPU and Docker issues.

## Start Services

```bash
# Start all services
make systemd-start

# Check status
make systemd-status
```

Expected output:
- `hermes-dashboard` — Dashboard on port 9119
- `agentsview` — AgentsView AI sessions Web UI on port 8080 (public origin https://pi.ntsd.dev:10002)

## Service Management

```bash
# Full restart
make systemd-stop
make systemd-start

sudo systemctl restart hermes-dashboard

# View logs
make systemd-logs
```
