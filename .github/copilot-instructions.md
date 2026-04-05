# GitHub Copilot Instructions — cq-safety

## Project Overview

**cq-safety** is a tutorial and reference project for **Safety CLI 3** (`safety` v3), a Python dependency vulnerability scanner by [safetycli.com](https://safetycli.com). The project documents Safe CLI 3 workflows, policy management, CI/CD integration, and output formats. Documentation is built with MkDocs Material.

## Tech Stack

| Tool | Version | Purpose |
|------|---------|---------|
| Python | 3.11+ | Runtime |
| Safety CLI | 3.x | Vulnerability scanning |
| uv | latest | Package/project management |
| MkDocs Material | latest | Documentation site |
| just | latest | Task runner |
| make | system | Alternative task runner |

## Running Safety

```bash
# Authenticate (development)
uv run safety auth login

# Check auth status
uv run safety auth status

# Basic scan
uv run safety scan

# Detailed scan
uv run safety scan --detailed-output

# CI/CD scan
uv run safety --key "$SAFETY_API_KEY" --stage cicd scan \
  --policy-file .safety-policy.yml
```

## Common Tasks

```bash
# Install dependencies
uv sync --group dev

# Run safety scan
uv run safety scan --detailed-output

# Run CI scan (requires SAFETY_API_KEY)
make scan-ci

# Generate policy file
uv run safety generate policy_file

# Validate policy file
uv run safety validate policy_file

# Build docs
uv run mkdocs build --strict

# Serve docs locally
uv run mkdocs serve

# Run all tasks
just --list
make help
```

## What to Avoid

- **Never use `safety check`** — it is deprecated in Safety CLI 3. Always use `safety scan`.
- **Never use `--ignore CVE-xxx`** — the `--ignore` CLI flag does not exist in v3. Use the policy file `installation.allow.vulnerabilities` section instead.
- **Never use v2 policy schema keys** — `ignore-cvss-severity-below`, `continue-on-vulnerability-error` are v2 keys. Use the v3 schema with `version: '3.0'`.
- **Never use `-r requirements.txt`** — this project uses `pyproject.toml` and `uv.lock`. Use `safety scan` or `safety scan --target .`.
- **Never hardcode API keys** — always use `$SAFETY_API_KEY` environment variable.

## Policy File

The policy file is `.safety-policy.yml`. It uses Safety CLI 3 schema (`version: '3.0'`).

- Generate: `uv run safety generate policy_file`
- Validate: `uv run safety validate policy_file`
- All vulnerability exceptions go in `installation.allow.vulnerabilities` with a `reason`.

## CI/CD

GitHub Actions workflows are in `.github/workflows/`. They use:
- `astral-sh/setup-uv@v4` for uv installation
- `SAFETY_API_KEY` secret from repository settings
- `--stage cicd` flag for CI context
- `--save-as` for artifact generation
