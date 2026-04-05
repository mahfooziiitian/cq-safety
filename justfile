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

# Authenticate with Safety Platform (browser login, development)
auth:
    uv run safety auth login

# Authenticate without a browser (headless / SSH)
auth-headless:
    uv run safety auth login --headless

# Show current Safety authentication status
auth-status:
    uv run safety auth status

# Log out of the current Safety session
auth-logout:
    uv run safety auth logout

# ── Scanning ──────────────────────────────────────────────────────────────────

# Scan the project directory (development auth, verbose output)
scan:
    uv run safety scan --detailed-output

# Scan a specific target directory
scan-target target:
    uv run safety scan --target {{ target }} --detailed-output

# Scan for CI/CD using SAFETY_API_KEY (set in .env or environment)
scan-ci:
    #!/usr/bin/env bash
    set -euo pipefail
    : "${SAFETY_API_KEY:?SAFETY_API_KEY must be set for CI scans}"
    mkdir -p {{ reports }}
    uv run safety --key "$SAFETY_API_KEY" --stage cicd scan \
        --policy-file {{ policy }} \
        --save-as json {{ reports }}/safety-report.json \
        --save-as html {{ reports }}/safety-report.html

# Scan for production using SAFETY_API_KEY
scan-prod:
    #!/usr/bin/env bash
    set -euo pipefail
    : "${SAFETY_API_KEY:?SAFETY_API_KEY must be set for production scans}"
    mkdir -p {{ reports }}
    uv run safety --key "$SAFETY_API_KEY" --stage production scan \
        --policy-file {{ policy }} \
        --save-as json {{ reports }}/safety-report-prod.json \
        --save-as spdx {{ reports }}/sbom.spdx

# Scan and auto-fix requirements.txt files
scan-fix:
    uv run safety scan --apply-fixes

# Scan and output JSON to stdout
scan-json:
    uv run safety scan --output json

# ── Policy ────────────────────────────────────────────────────────────────────

# Generate a fresh Safety v3 policy file
policy-generate:
    uv run safety generate policy_file

# Validate the Safety policy file
policy-validate:
    uv run safety validate policy_file

# ── Reports ───────────────────────────────────────────────────────────────────

# Generate JSON + HTML vulnerability reports in ./reports/
report:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p {{ reports }}
    uv run safety scan \
        --save-as json {{ reports }}/safety-report.json \
        --save-as html {{ reports }}/safety-report.html \
        --output screen

# Generate an SPDX SBOM (requires SAFETY_API_KEY)
sbom:
    #!/usr/bin/env bash
    set -euo pipefail
    : "${SAFETY_API_KEY:?SAFETY_API_KEY must be set for SBOM generation}"
    mkdir -p {{ reports }}
    uv run safety --key "$SAFETY_API_KEY" --stage production scan \
        --save-as spdx {{ reports }}/sbom.spdx

# ── Docs ──────────────────────────────────────────────────────────────────────

# Build the MkDocs documentation site
docs:
    uv run mkdocs build --strict

# Serve docs locally with live-reload at http://127.0.0.1:8000
docs-serve:
    uv run mkdocs serve

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
