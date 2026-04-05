# Variables
UV         := uv
SAFETY     := uv run safety
MKDOCS     := uv run mkdocs
POLICY     := .safety-policy.yml
REPORT_DIR := reports
TARGET     := .

# Default target
.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*##/ {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# Setup
.PHONY: install
install: ## Install all dependencies (including dev)
	$(UV) sync --group dev

# Authentication
.PHONY: auth
auth: ## Authenticate with Safety Platform (browser login)
	$(SAFETY) auth login

.PHONY: auth-status
auth-status: ## Show current authentication status
	$(SAFETY) auth status

# Scanning
.PHONY: scan
scan: ## Scan installed packages with detailed output
	$(SAFETY) scan --detailed-output

.PHONY: scan-ci
scan-ci: ## CI/CD scan — requires SAFETY_API_KEY; saves JSON + HTML reports
	@test -n "$(SAFETY_API_KEY)" || (echo "Error: SAFETY_API_KEY is not set"; exit 1)
	@mkdir -p $(REPORT_DIR)
	$(SAFETY) --key $(SAFETY_API_KEY) --stage cicd scan \
		--policy-file $(POLICY) \
		--save-as json $(REPORT_DIR)/safety-report.json \
		--save-as html $(REPORT_DIR)/safety-report.html

.PHONY: scan-target
scan-target: ## Scan a specific directory: make scan-target TARGET=/path/to/dir
	$(SAFETY) scan --target $(TARGET) --detailed-output

.PHONY: scan-fix
scan-fix: ## Scan and automatically apply available security fixes
	$(SAFETY) scan --apply-fixes

.PHONY: scan-json
scan-json: ## Scan and output JSON to stdout
	$(SAFETY) scan --output json

# Policy
.PHONY: policy-generate
policy-generate: ## Generate a default Safety v3 policy file
	$(SAFETY) generate policy_file

.PHONY: policy-validate
policy-validate: ## Validate the Safety policy file
	$(SAFETY) validate policy_file

# Reports
$(REPORT_DIR):
	@mkdir -p $(REPORT_DIR)

.PHONY: report
report: $(REPORT_DIR) ## Generate JSON + HTML reports and display on screen
	$(SAFETY) scan \
		--save-as json $(REPORT_DIR)/safety-report.json \
		--save-as html $(REPORT_DIR)/safety-report.html \
		--output screen

# Docs
.PHONY: docs
docs: ## Build the MkDocs documentation site
	$(MKDOCS) build --strict

.PHONY: docs-serve
docs-serve: ## Serve docs locally with live-reload (http://127.0.0.1:8000)
	$(MKDOCS) serve

.PHONY: docs-clean
docs-clean: ## Remove the generated docs site directory
	rm -rf site/

# Maintenance
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
