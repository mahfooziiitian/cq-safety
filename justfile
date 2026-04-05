# justfile — task runner for cq-safety
# Install just: https://just.systems/man/en/chapter_4.html
#
# Usage:
#   just          → list all recipes
#   just scan     → run a development scan
#   just scan-ci  → run a CI/CD scan (requires SAFETY_API_KEY)

set dotenv-load := true   # auto-load .env if present
set shell := ["bash", "-cu"]

policy  := ".safety-policy.yml"
reports := "reports"

# ── Default: list recipes ──────────────────────────────────────────────────────
[private]
default:
    @just --list

# ── Setup ─────────────────────────────────────────────────────────────────────

# Install all dependencies including dev group
install:
    uv sync --group dev

# ── Scanning ──────────────────────────────────────────────────────────────────

# Scan installed packages (full report)
scan:
    uv run safety check --full-report

# Scan requirements.txt for CI/CD using SAFETY_API_KEY (set in .env or environment)
scan-ci:
    #!/usr/bin/env bash
    set -euo pipefail
    : "${SAFETY_API_KEY:?SAFETY_API_KEY must be set for CI scans}"
    mkdir -p {{ reports }}
    uv run safety check -r requirements.txt \
        --key "$SAFETY_API_KEY" \
        --policy-file {{ policy }} \
        --json > {{ reports }}/safety-report.json

# Scan and output JSON to stdout
scan-json:
    uv run safety check --json

# ── Policy ────────────────────────────────────────────────────────────────────

# Generate a fresh Safety v2 policy file
policy-generate:
    uv run safety generate policy_file

# ── Reports ───────────────────────────────────────────────────────────────────

# Generate a full vulnerability report for requirements.txt
report:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p {{ reports }}
    uv run safety check --full-report -r requirements.txt

# ── Docs ──────────────────────────────────────────────────────────────────────

# Build the MkDocs documentation site
docs:
    uv run mkdocs build --strict

# Serve docs locally with live-reload at http://127.0.0.1:8000
docs-serve:
    uv run mkdocs serve --livereload

# Remove the generated docs site directory
docs-clean:
    rm -rf site/

# ── Maintenance ───────────────────────────────────────────────────────────────

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
