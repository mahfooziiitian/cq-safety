# justfile — task runner for cq-safety (Safety CLI v3)
set dotenv-load := true
set shell := ["bash", "-cu"]

policy  := ".safety-policy.yml"
reports := "reports"

[private]
default:
    @just --list

# Install all dependencies including dev group
install:
    uv sync --group dev

# Authenticate with Safety Platform (browser)
auth:
    uv run safety auth login

# Authenticate headlessly (for CI with manual token)
auth-headless:
    uv run safety auth login --headless

# Show authentication status
auth-status:
    uv run safety auth status

# Logout from Safety Platform
auth-logout:
    uv run safety auth logout

# Scan installed packages with detailed output
scan:
    uv run safety scan --detailed-output

# Scan a specific directory
scan-target target:
    uv run safety scan --target {{target}} --detailed-output

# CI/CD scan (requires SAFETY_API_KEY)
scan-ci:
    #!/usr/bin/env bash
    set -euo pipefail
    : "${SAFETY_API_KEY:?SAFETY_API_KEY must be set}"
    mkdir -p {{reports}}
    uv run safety --key "$SAFETY_API_KEY" --stage cicd scan \
        --policy-file {{policy}} \
        --save-as json {{reports}}/safety-report.json \
        --save-as html {{reports}}/safety-report.html

# Production scan
scan-prod:
    #!/usr/bin/env bash
    set -euo pipefail
    : "${SAFETY_API_KEY:?SAFETY_API_KEY must be set}"
    uv run safety --key "$SAFETY_API_KEY" --stage production scan \
        --policy-file {{policy}}

# Scan and apply available security fixes
scan-fix:
    uv run safety scan --apply-fixes

# Scan and output JSON to stdout
scan-json:
    uv run safety scan --output json

# Generate a default Safety v3 policy file
policy-generate:
    uv run safety generate policy_file

# Validate the Safety policy file
policy-validate:
    uv run safety validate policy_file

# Generate JSON + HTML reports and display on screen
report:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p {{reports}}
    uv run safety scan \
        --save-as json {{reports}}/safety-report.json \
        --save-as html {{reports}}/safety-report.html \
        --output screen

# Generate SPDX SBOM report
sbom:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p {{reports}}
    uv run safety scan --output spdx \
        --save-as spdx {{reports}}/sbom.spdx

# Build the MkDocs documentation site
docs:
    uv run mkdocs build --strict

# Serve docs locally at http://127.0.0.1:8000
docs-serve:
    uv run mkdocs serve

# Remove the generated docs site directory
docs-clean:
    rm -rf site/

# Update all dependencies
update:
    uv lock --upgrade
    uv sync --group dev

# Check if a newer Safety CLI version is available
check-updates:
    uv run safety check-updates

# Remove all generated files
clean: docs-clean
    rm -rf {{reports}}/
