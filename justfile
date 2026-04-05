# justfile — task runner for cq-safety
# Install just: https://just.systems
# Usage: just [recipe]

set dotenv-load := true
set shell := ["bash", "-cu"]

policy  := ".safety-policy.yml"
reports := "reports"

# List all available recipes
[private]
default:
    @just --list

# ── Setup ──────────────────────────────────────────────────────────────────────

# Install all dependencies including dev group
install:
    uv sync --group dev

# ── Scanning ───────────────────────────────────────────────────────────────────

# Scan installed packages (full report)
scan:
    uv run safety check --full-report --policy-file {{ policy }}

# Scan a specific requirements file
scan-file file:
    uv run safety check -r {{ file }} --full-report --policy-file {{ policy }}

# Scan for CI/CD, save JSON report (requires SAFETY_API_KEY in env or .env)
scan-ci:
    #!/usr/bin/env bash
    set -euo pipefail
    : "${SAFETY_API_KEY:?SAFETY_API_KEY must be set}"
    mkdir -p {{ reports }}
    uv run safety check \
        --key "$SAFETY_API_KEY" \
        --policy-file {{ policy }} \
        --full-report \
        --json > {{ reports }}/safety-report.json

# Scan and output JSON to stdout
scan-json:
    uv run safety check --json --policy-file {{ policy }}

# ── Policy ─────────────────────────────────────────────────────────────────────

# Generate a default Safety v2 policy file
policy-generate:
    uv run safety generate policy_file

# ── Reports ────────────────────────────────────────────────────────────────────

# Generate a full-text report saved to reports/safety-report.txt
report:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p {{ reports }}
    uv run safety check --full-report --policy-file {{ policy }} \
        > {{ reports }}/safety-report.txt

# ── Docs ───────────────────────────────────────────────────────────────────────

# Build the MkDocs documentation site (strict mode)
docs:
    uv run mkdocs build --strict

# Serve docs locally with live-reload at http://127.0.0.1:8000
docs-serve:
    uv run mkdocs serve

# Remove the generated docs site directory
docs-clean:
    rm -rf site/

# ── Maintenance ────────────────────────────────────────────────────────────────

# Update all dependencies to latest compatible versions
update:
    uv lock --upgrade
    uv sync --group dev

# Check if a newer version of Safety CLI is available
check-updates:
    uv run safety check-updates

# Remove all generated files (reports and docs site)
clean: docs-clean
    rm -rf {{ reports }}/
