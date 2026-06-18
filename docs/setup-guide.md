# DotAI Infrastructure Setup Guide

## Configure Systemd

Generate systemd services from templates:

```bash
cd systemd
env USER="$USER" HOME="$HOME" envsubst < "$(pwd)/hermes-gateway.service.template" > "$(pwd)/hermes-gateway.service"
env USER="$USER" HOME="$HOME" envsubst < "$(pwd)/hermes-dashboard.service.template" > "$(pwd)/hermes-dashboard.service"
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

## vLLM Inference (Docker Compose)

GPU-based LLM inference runs via Docker Compose. Choose one of the pre-configured setups:

### Option A: Qwen3.6-35B-A3B (NVFP4 + DFlash)

```bash
cd vllm/qwen3.6-35b-a3b
docker compose up -d
```

This uses the AEON-7 NVFP4 quantized model with DFlash speculative decoding on DGX Spark.

### Option B: Qwen3.6-27B v4

```bash
cd vllm/qwen3.6-27b
docker compose up -d
```

This uses the Qwen3.6-27B v4 multimodal model with DFlash on DGX Spark (GB10 architecture).

### Verify Inference

Both setups expose the OpenAI-compatible API at `http://localhost:8000/v1`:

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
- `hermes-gateway` — API server on port 8642
- `hermes-dashboard` — Dashboard on port 9119

## Service Management

```bash
# Full restart
make systemd-stop
make systemd-start

# Individual service
sudo systemctl restart hermes-gateway

# View logs
make systemd-logs
```
