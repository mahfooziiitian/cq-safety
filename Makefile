# ── Variables ─────────────────────────────────────────────────────────────────
PYTHON     := python3
UV         := uv
SAFETY     := uv run safety
MKDOCS     := uv run mkdocs
POLICY     := .safety-policy.yml
REPORT_DIR := reports

# ── Default target ────────────────────────────────────────────────────────────
.DEFAULT_GOAL := help

.PHONY: help
help:                ## Show this help message
@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} \
     /^[a-zA-Z_-]+:.*##/ {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# ── Setup ─────────────────────────────────────────────────────────────────────
.PHONY: install
install:             ## Install all dependencies (including dev)
$(UV) sync --group dev

# ── Scanning ──────────────────────────────────────────────────────────────────
.PHONY: scan
scan:                ## Scan installed packages (full report)
$(SAFETY) check --full-report

.PHONY: scan-ci
scan-ci:             ## Scan requirements.txt for CI/CD (requires SAFETY_API_KEY env var)
@test -n "$(SAFETY_API_KEY)" || (echo "Error: SAFETY_API_KEY is not set"; exit 1)
mkdir -p $(REPORT_DIR)
$(SAFETY) check -r requirements.txt \
--key $(SAFETY_API_KEY) \
--policy-file $(POLICY) \
--json > $(REPORT_DIR)/safety-report.json

.PHONY: scan-json
scan-json:           ## Scan and output JSON to stdout
$(SAFETY) check --json

# ── Policy ────────────────────────────────────────────────────────────────────
.PHONY: policy-generate
policy-generate:     ## Generate a default Safety v2 policy file
$(SAFETY) generate policy_file

# ── Reports ───────────────────────────────────────────────────────────────────
$(REPORT_DIR):
mkdir -p $(REPORT_DIR)

.PHONY: report
report: $(REPORT_DIR) ## Generate a full vulnerability report for requirements.txt
$(SAFETY) check --full-report -r requirements.txt

# ── Docs ──────────────────────────────────────────────────────────────────────
.PHONY: docs
docs:                ## Build the MkDocs documentation site
$(MKDOCS) build --strict

.PHONY: docs-serve
docs-serve:          ## Serve docs locally with live-reload (http://127.0.0.1:8000)
$(MKDOCS) serve

.PHONY: docs-clean
docs-clean:          ## Remove the generated docs site directory
rm -rf site/

# ── Maintenance ───────────────────────────────────────────────────────────────
.PHONY: update
update:              ## Update all dependencies to latest compatible versions
$(UV) lock --upgrade
$(UV) sync --group dev

.PHONY: clean
clean: docs-clean    ## Remove generated files (reports, docs site)
rm -rf $(REPORT_DIR)/

.PHONY: check-updates
check-updates:       ## Check if a newer version of Safety CLI is available
$(SAFETY) check-updates
