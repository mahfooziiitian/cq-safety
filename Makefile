# ── Variables ──────────────────────────────────────────────────────────────────
UV         := uv
SAFETY     := uv run safety
MKDOCS     := uv run mkdocs
POLICY     := .safety-policy.yml
REPORT_DIR := reports

# ── Default target ─────────────────────────────────────────────────────────────
.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} 	     /^[a-zA-Z_-]+:.*##/ {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# ── Setup ──────────────────────────────────────────────────────────────────────
.PHONY: install
install: ## Install all dependencies (including dev)
	$(UV) sync --group dev

# ── Scanning ───────────────────────────────────────────────────────────────────
.PHONY: scan
scan: ## Scan installed packages (full report, uses SAFETY_API_KEY if set)
	$(SAFETY) check --full-report --policy-file $(POLICY)

.PHONY: scan-ci
scan-ci: ## Scan for CI/CD — saves JSON report (requires SAFETY_API_KEY)
	@test -n "$(SAFETY_API_KEY)" || (echo "Error: SAFETY_API_KEY is not set"; exit 1)
	@mkdir -p $(REPORT_DIR)
	$(SAFETY) check \
		--key $(SAFETY_API_KEY) \
		--policy-file $(POLICY) \
		--full-report \
		--json > $(REPORT_DIR)/safety-report.json

.PHONY: scan-file
scan-file: ## Scan a requirements file: make scan-file FILE=requirements.txt
	$(SAFETY) check -r $(FILE) --full-report --policy-file $(POLICY)

.PHONY: scan-json
scan-json: ## Scan and output JSON to stdout
	$(SAFETY) check --json --policy-file $(POLICY)

# ── Policy ─────────────────────────────────────────────────────────────────────
.PHONY: policy-generate
policy-generate: ## Generate a default Safety v2 policy file
	$(SAFETY) generate policy_file

# ── Reports ────────────────────────────────────────────────────────────────────
$(REPORT_DIR):
	@mkdir -p $(REPORT_DIR)

.PHONY: report
report: $(REPORT_DIR) ## Generate a full-text report in reports/
	$(SAFETY) check --full-report --policy-file $(POLICY) > $(REPORT_DIR)/safety-report.txt

# ── Docs ───────────────────────────────────────────────────────────────────────
.PHONY: docs
docs: ## Build the MkDocs documentation site
	$(MKDOCS) build --strict

.PHONY: docs-serve
docs-serve: ## Serve docs locally with live-reload (http://127.0.0.1:8000)
	$(MKDOCS) serve

.PHONY: docs-clean
docs-clean: ## Remove the generated docs site directory
	rm -rf site/

# ── Maintenance ────────────────────────────────────────────────────────────────
.PHONY: update
update: ## Update all dependencies to latest compatible versions
	$(UV) lock --upgrade
	$(UV) sync --group dev

.PHONY: clean
clean: docs-clean ## Remove all generated files (reports and docs site)
	rm -rf $(REPORT_DIR)/

.PHONY: check-updates
check-updates: ## Check if a newer version of Safety CLI is available
	$(SAFETY) check-updates
