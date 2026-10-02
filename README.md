# DotAI Infrastructure

## Project Structure

```text
├── nginx/                # Nginx reverse proxy configurations
│   ├── hermes-dashboard.pi.ntsd.dev # Hermes dashboard reverse proxy
│   ├── agentsview.pi.ntsd.dev       # AgentsView sessions Web UI reverse proxy
│   └── vllm.spark.ntsd.dev          # vLLM API reverse proxy
├── systemd/              # Systemd service files for 24/7 operation
│   ├── README.md         # Systemd setup guide
│   ├── *.service.template # Service unit templates
│   └── *.service          # Generated service units
├── sparkrun/             # LLM inference configs (sparkrun recipes)
│   ├── qwen-3.8-27b-sglang/ # Qwen3.8-27B NVFP4 with SGLang + DFlash2
│   └── qwen-3.8-27b-vllm/   # Qwen3.8-27B NVFP4 with vLLM + DFlash2
```

## Documentation

| Document | Description |
|----------|-------------|
| [systemd/README.md](systemd/README.md) | Systemd service configuration |
| [docs/setup-guide.md](docs/setup-guide.md) | DotAI infrastructure setup guide |
| [docs/api.md](docs/api.md) | Infrastructure API reference |
| [docs/runbook.md](docs/runbook.md) | Operations runbook (restarting, emergency procedures) |
| [docs/troubleshooting.md](docs/troubleshooting.md) | Troubleshooting guides (systemd, vLLM/GPU) |

## Sparkrun Inference (Optional)

GPU-based LLM inference runs via `sparkrun` in `sparkrun/`:

| Setup | Model | GPU | Details | Source / Recipe |
|-------|-------|-----|---------|-----------------|
| `sparkrun/qwen-3.8-27b-sglang/` | Qwen3.8-27B | DGX Spark (NVFP4 + DFlash2) | `RadixArk/Qwen3.8-27B-NVFP4` with `incoai/Qwen3.8-27B-DFlash2` (sglang) | [recipe.yaml](sparkrun/qwen-3.8-27b-sglang/recipe.yaml) |
| `sparkrun/qwen-3.8-27b-vllm/` | Qwen3.8-27B | DGX Spark (NVFP4 + DFlash2) | `unsloth/Qwen3.8-27B-NVFP4` with `z-lab/Qwen3.8-27B-DFlash2` (vLLM) | [recipe.yaml](sparkrun/qwen-3.8-27b-vllm/recipe.yaml) |

All setups expose an OpenAI-compatible API at `http://localhost:8000/v1`.

### Running Qwen3.8 with sparkrun

Install `sparkrun` first if not already installed:

```bash
uvx sparkrun setup
```

Deploy the recipe using `sparkrun` on DGX Spark:

```bash
# Run in solo mode (single-node DGX Spark)
sparkrun run sparkrun/qwen-3.8-27b-sglang/recipe.yaml --solo

# Auto restart when the OS restarts (or via make: make sparkrun-run)
sparkrun run sparkrun/qwen-3.8-27b-sglang/recipe.yaml --solo --restart unless-stopped

# Or target a specific cluster/host
sparkrun run sparkrun/qwen-3.8-27b-sglang/recipe.yaml --hosts <spark-ip>

# View running logs (or: make sparkrun-logs)
sparkrun logs Qwen3.8-27B-NVFP4

# Check status (or: make sparkrun-status)
sparkrun status

# Stop the workload (or: make sparkrun-stop)
sparkrun stop Qwen3.8-27B-NVFP4
```

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make sparkrun-run` | Run Qwen3.8-27B recipe with sparkrun (`--solo`, `--restart unless-stopped`) |
| `make sparkrun-stop` | Stop Qwen3.8-27B sparkrun workload |
| `make sparkrun-status` | Show sparkrun workload status |
| `make sparkrun-logs` | View Qwen3.8-27B sparkrun logs |
| `make nginx-link` | Link all nginx configs to `/etc/nginx/sites-enabled/`, test and reload nginx |
| `make nginx-link-hermes` | Link Hermes dashboard nginx config, test and reload |
| `make nginx-link-agentsview` | Link AgentsView nginx config, test and reload |
| `make nginx-link-vllm` | Link vLLM nginx config, test and reload |
| `make nginx-test` | Test nginx configuration (`nginx -t`) |
| `make nginx-reload` | Test and reload nginx service |
| `make systemd-link` | Link systemd services to `/etc/systemd/system/` |
| `make systemd-enable` | Enable all services on boot |
| `make systemd-start` | Start all services |
| `make systemd-stop` | Stop all services |
| `make systemd-status` | Show service status |
| `make systemd-logs` | Show service logs |
| `make systemd-refresh` | Full refresh (generate → link → enable → start) |
