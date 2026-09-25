SHELL := /bin/bash

SYSTEMD_SERVICES := hermes-dashboard agentsview
SYSTEMD_DIR := $(CURDIR)/systemd
NGINX_DIR := $(CURDIR)/nginx
NGINX_SITES_ENABLED := /etc/nginx/sites-enabled
SPARKRUN_RECIPE := vllm/qwen3.8-27b/recipe.yaml
SPARKRUN_WORKLOAD := Qwen3.8-27B-NVFP4-DFlash2-unsloth-NVIDIA-DGX-Spark-prod-v4

SVC ?=
SERVICE ?= $(SVC)
SERVICES ?= $(if $(SERVICE),$(SERVICE),$(SYSTEMD_SERVICES))

.PHONY: systemd-generate systemd-link systemd-enable systemd-disable systemd-start systemd-stop systemd-restart systemd-status systemd-logs systemd-refresh nginx-link nginx-link-hermes nginx-link-agentsview nginx-link-vllm nginx-test nginx-reload sparkrun-run sparkrun-start sparkrun-stop sparkrun-status sparkrun-logs

systemd-generate:
	@command -v envsubst >/dev/null 2>&1 || (echo "Error: envsubst not found. Install gettext package." && exit 1)
	@for svc in $(SERVICES); do \
		if [ -f "$(SYSTEMD_DIR)/$$svc.service.template" ]; then \
			echo "Generating $$svc.service"; \
			env USER="$(USER)" HOME="$(HOME)" envsubst < "$(SYSTEMD_DIR)/$$svc.service.template" > "$(SYSTEMD_DIR)/$$svc.service"; \
		elif [ ! -f "$(SYSTEMD_DIR)/$$svc.service" ]; then \
			echo "WARN: neither $(SYSTEMD_DIR)/$$svc.service.template nor $(SYSTEMD_DIR)/$$svc.service found"; \
		fi; \
	done
	@echo "Generated systemd service files from templates"

systemd-link: systemd-generate
	@for svc in $(SERVICES); do \
		if [ -f "$(SYSTEMD_DIR)/$$svc.service" ]; then \
			echo "Linking $$svc.service"; \
			sudo ln -sf "$(SYSTEMD_DIR)/$$svc.service" /etc/systemd/system/$$svc.service; \
		else \
			echo "WARN: $(SYSTEMD_DIR)/$$svc.service not found"; \
		fi; \
	done
	@sudo systemctl daemon-reload
	@echo "Linked systemd unit files from $(SYSTEMD_DIR)"

systemd-enable: systemd-link
	@sudo systemctl daemon-reload
	@for svc in $(SERVICES); do \
		echo "Enabling $$svc"; \
		sudo systemctl enable "$$svc" || echo "WARN: failed to enable $$svc"; \
	done
	@echo "Enabled: $(SERVICES)"

systemd-disable:
	@for svc in $(SERVICES); do \
		echo "Disabling $$svc"; \
		sudo systemctl disable "$$svc" || echo "WARN: failed to disable $$svc"; \
	done
	@echo "Disabled: $(SERVICES)"

systemd-start: systemd-enable
	@sudo systemctl daemon-reload
	@for svc in $(SERVICES); do \
		echo "Starting $$svc"; \
		sudo systemctl start "$$svc" || echo "WARN: failed to start $$svc"; \
	done
	@echo "Started: $(SERVICES)"

systemd-stop:
	@for svc in $(SERVICES); do \
		echo "Stopping $$svc"; \
		sudo systemctl stop "$$svc" || echo "WARN: failed to stop $$svc"; \
	done
	@$(MAKE) systemd-disable SVC=$(if $(SVC),$(SVC),$(SERVICE))
	@echo "Stopped and disabled: $(SERVICES)"

systemd-restart:
	@sudo systemctl daemon-reload
	@for svc in $(SERVICES); do \
		echo "Restarting $$svc"; \
		sudo systemctl restart "$$svc" || echo "WARN: failed to restart $$svc"; \
	done
	@echo "Restarted: $(SERVICES)"

systemd-status:
	@for svc in $(SERVICES); do \
		echo "==== $$svc ===="; \
		sudo systemctl status "$$svc" --no-pager -l || true; \
		state="$$(sudo systemctl is-active "$$svc" 2>/dev/null || true)"; \
		if [[ -z "$$state" ]]; then state="unknown"; fi; \
		echo "State: $$state"; \
		echo; \
	done

systemd-logs:
	@for svc in $(SERVICES); do \
		echo "==== $$svc logs ===="; \
		sudo journalctl -u "$$svc" -n 120 --no-pager -l || true; \
		echo; \
	done

systemd-refresh:
	@sudo systemctl daemon-reload
	@sudo systemctl reset-failed $(SERVICES) || true
	@$(MAKE) systemd-link SVC=$(if $(SVC),$(SVC),$(SERVICE))
	@$(MAKE) systemd-enable SVC=$(if $(SVC),$(SVC),$(SERVICE))
	@$(MAKE) systemd-start SVC=$(if $(SVC),$(SVC),$(SERVICE))
	@echo "Refreshed and restarted: $(SERVICES)"

# Macro for individual service targets
define SERVICE_TARGETS
.PHONY: systemd-generate-$(1) systemd-link-$(1) systemd-enable-$(1) systemd-disable-$(1) \
        systemd-start-$(1) systemd-stop-$(1) systemd-restart-$(1) systemd-status-$(1) \
        systemd-logs-$(1) systemd-refresh-$(1)

systemd-generate-$(1):
	@$$(MAKE) systemd-generate SVC=$(2)

systemd-link-$(1):
	@$$(MAKE) systemd-link SVC=$(2)

systemd-enable-$(1):
	@$$(MAKE) systemd-enable SVC=$(2)

systemd-disable-$(1):
	@$$(MAKE) systemd-disable SVC=$(2)

systemd-start-$(1):
	@$$(MAKE) systemd-start SVC=$(2)

systemd-stop-$(1):
	@$$(MAKE) systemd-stop SVC=$(2)

systemd-restart-$(1):
	@$$(MAKE) systemd-restart SVC=$(2)

systemd-status-$(1):
	@$$(MAKE) systemd-status SVC=$(2)

systemd-logs-$(1):
	@$$(MAKE) systemd-logs SVC=$(2)

systemd-refresh-$(1):
	@$$(MAKE) systemd-refresh SVC=$(2)
endef

$(eval $(call SERVICE_TARGETS,agentsview,agentsview))
$(eval $(call SERVICE_TARGETS,hermes-dashboard,hermes-dashboard))
$(eval $(call SERVICE_TARGETS,hermes,hermes-dashboard))

# Pattern rules for any other custom service name
systemd-generate-%:
	@$(MAKE) systemd-generate SVC=$*

systemd-link-%:
	@$(MAKE) systemd-link SVC=$*

systemd-enable-%:
	@$(MAKE) systemd-enable SVC=$*

systemd-disable-%:
	@$(MAKE) systemd-disable SVC=$*

systemd-start-%:
	@$(MAKE) systemd-start SVC=$*

systemd-stop-%:
	@$(MAKE) systemd-stop SVC=$*

systemd-restart-%:
	@$(MAKE) systemd-restart SVC=$*

systemd-status-%:
	@$(MAKE) systemd-status SVC=$*

systemd-logs-%:
	@$(MAKE) systemd-logs SVC=$*

systemd-refresh-%:
	@$(MAKE) systemd-refresh SVC=$*

nginx-link:
	@sudo mkdir -p $(NGINX_SITES_ENABLED)
	@for conf in $(NGINX_DIR)/*; do \
		[ -f "$$conf" ] || continue; \
		echo "Linking $$(basename "$$conf") to $(NGINX_SITES_ENABLED)/"; \
		sudo ln -sf "$$conf" $(NGINX_SITES_ENABLED)/; \
	done
	@echo "Linked nginx config files from $(NGINX_DIR)"
	@sudo nginx -t
	@sudo systemctl reload nginx
	@echo "Nginx reloaded successfully"

nginx-link-hermes:
	@sudo mkdir -p $(NGINX_SITES_ENABLED)
	@echo "Linking hermes-dashboard.pi.ntsd.dev to $(NGINX_SITES_ENABLED)/"
	@sudo ln -sf "$(NGINX_DIR)/hermes-dashboard.pi.ntsd.dev" $(NGINX_SITES_ENABLED)/
	@sudo nginx -t
	@sudo systemctl reload nginx
	@echo "Hermes dashboard nginx reloaded successfully"

nginx-link-agentsview:
	@sudo mkdir -p $(NGINX_SITES_ENABLED)
	@echo "Linking agentsview.pi.ntsd.dev to $(NGINX_SITES_ENABLED)/"
	@sudo ln -sf "$(NGINX_DIR)/agentsview.pi.ntsd.dev" $(NGINX_SITES_ENABLED)/
	@sudo nginx -t
	@sudo systemctl reload nginx
	@echo "AgentsView nginx reloaded successfully"


nginx-link-vllm:
	@sudo mkdir -p $(NGINX_SITES_ENABLED)
	@echo "Linking vllm.spark.ntsd.dev to $(NGINX_SITES_ENABLED)/"
	@sudo ln -sf "$(NGINX_DIR)/vllm.spark.ntsd.dev" $(NGINX_SITES_ENABLED)/
	@sudo nginx -t
	@sudo systemctl reload nginx
	@echo "vLLM nginx reloaded successfully"

nginx-test:
	@sudo nginx -t

nginx-reload:
	@sudo nginx -t
	@sudo systemctl reload nginx
	@echo "Nginx reloaded successfully"

sparkrun-run:
	sparkrun run $(SPARKRUN_RECIPE) --solo --restart unless-stopped

sparkrun-start: sparkrun-run

sparkrun-stop:
	sparkrun stop $(SPARKRUN_WORKLOAD)

sparkrun-status:
	sparkrun status

sparkrun-logs:
	sparkrun logs $(SPARKRUN_WORKLOAD)

