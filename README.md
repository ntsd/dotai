# DotAI Infrastructure

## Project Structure

```text
├── systemd/              # Systemd service files for 24/7 operation
│   ├── README.md         # Systemd setup guide
│   ├── *.service.template # Service unit templates
│   └── *.service          # Generated service units
└── vllm/                 # Docker Compose LLM inference configs
    ├── qwen3.6-35b-a3b/  # NVFP4 35B with DFlash on DGX Spark
    └── qwen3.6-27b/      # Qwen3.6-27B v4 on DGX Spark
```

## Documentation

| Document | Description |
|----------|-------------|
| [systemd/README.md](systemd/README.md) | Systemd service configuration |

## vLLM Inference (Optional)

GPU-based LLM inference runs via Docker Compose in `vllm/`:

| Setup | Model | GPU | Details |
|-------|-------|-----|---------|
| `vllm/qwen3.6-35b-a3b/` | Qwen3.6-35B-A3B | DGX Spark (NVFP4 + DFlash) | Speculative decoding with AEON-7 |
| `vllm/qwen3.6-27b/` | Qwen3.6-27B v4 | DGX Spark (GB10) | Multimodal with DFlash |

Both expose the OpenAI-compatible API at `http://localhost:8000/v1`.

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
