# DotAI Infrastructure

## Project Structure

```text
├── nginx/                # Nginx reverse proxy configurations
├── systemd/              # Systemd service files for 24/7 operation
│   ├── README.md         # Systemd setup guide
│   ├── *.service.template # Service unit templates
│   └── *.service          # Generated service units
├── vllm/                 # LLM inference configs (Docker Compose / sparkrun)
│   ├── qwen3.6-35b-a3b/  # NVFP4 35B with DFlash on DGX Spark
│   └── qwen3.8-27b/      # Qwen3.8-27B NVFP4 with DFlash2 (sparkrun recipe)
```

## Documentation

| Document | Description |
|----------|-------------|
| [systemd/README.md](systemd/README.md) | Systemd service configuration |
| [docs/setup-guide.md](docs/setup-guide.md) | DotAI infrastructure setup guide |

## vLLM Inference (Optional)

GPU-based LLM inference runs via Docker Compose or `sparkrun` in `vllm/`:

| Setup | Model | GPU | Details | Source / Recipe |
|-------|-------|-----|---------|-----------------|
| `vllm/qwen3.6-35b-a3b/` | Qwen3.6-35B-A3B | DGX Spark (NVFP4 + DFlash) | Speculative decoding with AEON-7 | https://github.com/AEON-7/Qwen3.6-35B-A3B-heretic-NVFP4-DFlash |
| `vllm/qwen3.8-27b/` | Qwen3.8-27B | DGX Spark (NVFP4 + DFlash2) | `unsloth/Qwen3.8-27B-NVFP4` with `z-lab/Qwen3.8-27B-DFlash2` (k=8) | [recipe.yaml](vllm/qwen3.8-27b/recipe.yaml) |

All setups expose an OpenAI-compatible API at `http://localhost:8000/v1`.

### Running Qwen3.8 with sparkrun

Install `sparkrun` first if not already installed:

```bash
uvx sparkrun setup
```

Deploy the recipe using `sparkrun` on DGX Spark:

```bash
# Run in solo mode (single-node DGX Spark)
sparkrun run vllm/qwen3.8-27b/recipe.yaml --solo

# Or target a specific cluster/host
sparkrun run vllm/qwen3.8-27b/recipe.yaml --hosts <spark-ip>

# View running logs
sparkrun logs Qwen3.8-27B-NVFP4-DFlash2-unsloth-NVIDIA-DGX-Spark-prod-v4

# Check status
sparkrun status

# Stop the workload
sparkrun stop Qwen3.8-27B-NVFP4-DFlash2-unsloth-NVIDIA-DGX-Spark-prod-v4
```

### Running Qwen3.6 with Docker Compose

```bash
cd vllm/qwen3.6-35b-a3b
docker compose up -d
```

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make nginx-link` | Link nginx configs to `/etc/nginx/sites-enabled/`, test and reload nginx |
| `make nginx-test` | Test nginx configuration (`nginx -t`) |
| `make nginx-reload` | Test and reload nginx service |
| `make systemd-link` | Link systemd services to `/etc/systemd/system/` |
| `make systemd-enable` | Enable all services on boot |
| `make systemd-start` | Start all services |
| `make systemd-stop` | Stop all services |
| `make systemd-status` | Show service status |
| `make systemd-logs` | Show service logs |
| `make systemd-refresh` | Full refresh (generate → link → enable → start) |
