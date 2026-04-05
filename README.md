# Safety CLI 3 — Python Dependency Security Scanner

[Safety CLI 3](https://safetycli.com) scans your Python dependencies for known security vulnerabilities, licence issues, and supply-chain risks. It integrates with the [Safety Platform](https://platform.safetycli.com) for team dashboards, policy management, and audit logs.

- **Docs:** https://docs.safetycli.com  
- **Platform:** https://platform.safetycli.com  
- **PyPI:** https://pypi.org/project/safety/

---

## Table of Contents

1. [What is Safety](#what-is-safety)
2. [Installation](#installation)
3. [Authentication](#authentication)
4. [Quick Start](#quick-start)
5. [How it Works](#how-it-works)
6. [Scanning Options](#scanning-options)
7. [Output Formats](#output-formats)
8. [Auto-Fix](#auto-fix)
9. [Ignoring Vulnerabilities](#ignoring-vulnerabilities)
10. [CI/CD Integration](#cicd-integration)
11. [Policy Files v3](#policy-files-v3)
12. [API Key & Safety Platform](#api-key--safety-platform)
13. [Common Workflows](#common-workflows)
14. [Exit Codes](#exit-codes)
15. [Deprecated Commands](#deprecated-commands)
16. [Troubleshooting](#troubleshooting)

---

## What is Safety

Safety CLI 3 is an open-source security tool by [safetycli.com](https://safetycli.com) that checks Python packages against the Safety Vulnerability Database — one of the largest curated databases of Python security advisories.

**Key capabilities:**

| Feature | Description |
|---------|-------------|
| Vulnerability scanning | Detect CVEs and advisories in installed packages |
| Policy enforcement | Define acceptable risk thresholds per project |
| Auto-fix | Automatically apply safe version upgrades |
| SBOM generation | Export SPDX software bill of materials |
| Platform integration | Team dashboards, audit logs, CI/CD gating |
| Multi-format output | screen, JSON, HTML, text, SPDX |

---

## Installation

```bash
# pip
pip install safety

# uv (recommended)
uv add --dev safety

# pipx (isolated)
pipx install safety

# Verify
safety --version
```

---

## Authentication

Safety CLI 3 requires authentication to access the vulnerability database.

### Development (interactive)

```bash
safety auth login
```

This opens a browser tab to [platform.safetycli.com](https://platform.safetycli.com). Sign in with your account. The CLI stores a token locally.

```bash
# Headless (SSH / no browser)
safety auth login --headless

# Check status
safety auth status

# Logout
safety auth logout
```

### CI/CD (API key)

Create an API key at [platform.safetycli.com](https://platform.safetycli.com) and add it as a repository secret named `SAFETY_API_KEY`.

```bash
# CI/CD scan using API key
safety --key $SAFETY_API_KEY --stage cicd scan
```

---

## Quick Start

```bash
# 1. Authenticate
safety auth login

# 2. Scan your environment
safety scan

# 3. Detailed output
safety scan --detailed-output

# 4. Scan a specific directory
safety scan --target /path/to/project

# 5. Auto-fix vulnerabilities
safety scan --apply-fixes
```

---

## How it Works

1. Safety inventories packages installed in the active Python environment (or a specified path).
2. Each package version is checked against the Safety Vulnerability Database.
3. Results are evaluated against your policy file thresholds.
4. The scan exits with a code indicating pass/fail status (see [Exit Codes](#exit-codes)).
5. If `--apply-fixes` is used, Safety updates `pyproject.toml` / `requirements.txt` to safe versions.

---

## Scanning Options

```bash
safety scan [OPTIONS]
```

| Option | Description |
|--------|-------------|
| `--target PATH` | Directory to scan (default: current environment) |
| `--output FORMAT` | Output format: `screen`, `json`, `html`, `text`, `spdx` |
| `--detailed-output` | Show full vulnerability details |
| `--save-as FORMAT FILE` | Save report to file (can repeat for multiple formats) |
| `--policy-file PATH` | Path to policy file (default: `.safety-policy.yml`) |
| `--apply-fixes` | Automatically apply safe version upgrades |
| `--filter` | Filter results by severity or status |

### Examples

```bash
# Basic scan
safety scan

# Save JSON and HTML reports
safety scan --save-as json reports/safety.json --save-as html reports/safety.html

# Use custom policy
safety scan --policy-file policies/strict.yml

# Scan a directory
safety scan --target ./src
```

---

## Output Formats

| Format | Command | Use Case |
|--------|---------|----------|
| `screen` | `safety scan --output screen` | Human-readable terminal output |
| `json` | `safety scan --output json` | Machine-readable, CI pipelines |
| `html` | `safety scan --output html` | Reports for stakeholders |
| `text` | `safety scan --output text` | Plain text logs |
| `spdx` | `safety scan --output spdx` | Software bill of materials (SBOM) |

```bash
# Save multiple formats simultaneously
safety scan \
  --save-as json reports/safety.json \
  --save-as html reports/safety.html \
  --output screen
```

---

## Auto-Fix

Safety can automatically upgrade vulnerable packages to the minimum safe version:

```bash
safety scan --apply-fixes
```

**Behaviour:**

- Only applies patch-level upgrades by default (configurable via `security-updates.auto-security-updates-limit` in policy).
- Updates `pyproject.toml` or `requirements.txt` in place.
- Re-run your lock tool (`uv lock`, `pip-compile`) after fixes are applied.
- Review changes in version control before committing.

---

## Ignoring Vulnerabilities

Safety CLI 3 does **not** have a `--ignore` CLI flag. All exceptions are managed through the policy file.

```yaml
# .safety-policy.yml
installation:
  allow:
    vulnerabilities:
      CVE-2024-12345:
        reason: "False positive — only affects Windows builds"
        expires: "2025-06-01"
```

This approach ensures exceptions are:
- Documented with a reason
- Version-controlled
- Auditable on the Safety Platform

---

## CI/CD Integration

### GitHub Actions

```yaml
- name: Run Safety scan
  run: |
    uv run safety --key "$SAFETY_API_KEY" --stage cicd scan \
      --policy-file .safety-policy.yml \
      --save-as json reports/safety-report.json
  env:
    SAFETY_API_KEY: ${{ secrets.SAFETY_API_KEY }}
```

### GitLab CI

```yaml
safety-scan:
  stage: security
  script:
    - pip install uv
    - uv sync --group dev
    - uv run safety --key "$SAFETY_API_KEY" --stage cicd scan
      --policy-file .safety-policy.yml
      --save-as json reports/safety-report.json
  artifacts:
    paths:
      - reports/
```

---

## Policy Files v3

Generate a default policy file:

```bash
safety generate policy_file
# Creates .safety-policy.yml

safety validate policy_file
# Validates the policy file
```

**v3 schema:**

```yaml
version: '3.0'

scanning-settings:
  max-depth: 6
  exclude: []
  include-files: []
  system:
    targets: []

report:
  dependency-vulnerabilities:
    enabled: true
    auto-ignore-in-report:
      python:
        environment-results: true
        unpinned-requirements: true
      cvss-severity: []

fail-scan-with-exit-code:
  dependency-vulnerabilities:
    enabled: true
    fail-on-any-of:
      cvss-severity:
        - critical
        - high
        - medium
      exploitability:
        - critical
        - high
        - medium

security-updates:
  dependency-vulnerabilities:
    auto-security-updates-limit:
      - patch

installation:
  default-action: allow
  audit-logging:
    enabled: true
  allow:
    packages: []
    vulnerabilities: {}
  deny:
    packages: {}
    vulnerabilities:
      warning-on-any-of:
        cvss-severity: []
      block-on-any-of:
        cvss-severity: []
```

---

## API Key & Safety Platform

1. Sign up at [platform.safetycli.com](https://platform.safetycli.com)
2. Go to **Settings → API Keys**
3. Create a key scoped to your project
4. Add as `SAFETY_API_KEY` in your CI/CD secret store

The platform provides:
- Team vulnerability dashboards
- Historical scan results
- Policy management
- Audit logs for compliance

---

## Common Workflows

### 1. Daily developer scan

```bash
safety scan --detailed-output
```

### 2. Generate reports for a stakeholder

```bash
safety scan \
  --save-as json reports/safety.json \
  --save-as html reports/safety.html \
  --output screen
```

### 3. CI gate — fail on critical/high

Configure your policy:
```yaml
fail-scan-with-exit-code:
  dependency-vulnerabilities:
    enabled: true
    fail-on-any-of:
      cvss-severity:
        - critical
        - high
```

Then in CI:
```bash
safety --key $SAFETY_API_KEY --stage cicd scan --policy-file .safety-policy.yml
```

### 4. Apply fixes and review

```bash
safety scan --apply-fixes
git diff
uv lock
```

### 5. Generate SBOM

```bash
safety scan --output spdx --save-as spdx reports/sbom.spdx
```

---

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Scan passed — no actionable vulnerabilities |
| `1` | Unexpected error |
| `64` | Vulnerabilities found that exceed policy thresholds |
| `65` | Scan configuration or policy error |
| `66` | Unable to fetch vulnerability database |

Use in shell scripts:

```bash
safety scan
case $? in
  0) echo "Clean!" ;;
  64) echo "Vulnerabilities found — review required" ;;
  65) echo "Policy error — check .safety-policy.yml" ;;
  66) echo "Database unreachable — check connectivity" ;;
  *) echo "Unexpected error" ;;
esac
```

---

## Deprecated Commands

| Deprecated | Replacement |
|-----------|-------------|
| `safety check` | `safety scan` |
| `safety check -r requirements.txt` | `safety scan --target .` |
| `safety check --ignore CVE-xxx` | Policy file `installation.allow.vulnerabilities` |
| `safety license` | `safety scan --output spdx` |
| `safety alert` | Platform alerts at platform.safetycli.com |

---

## Troubleshooting

**`safety: command not found`**  
Install with `pip install safety` or use `uv run safety`.

**Authentication errors in dev**  
Run `safety auth login` and complete browser login.

**Authentication errors in CI**  
Verify `SAFETY_API_KEY` is set: `echo $SAFETY_API_KEY`.

**"No packages found"**  
Use `--target` to point to your project: `safety scan --target .`

**Database unreachable**  
Configure proxy: `safety configure --proxy-host proxy.example.com --proxy-port 8080`

**Policy validation error**  
Run `safety validate policy_file` for detailed error messages. Ensure `version: '3.0'` is present.

**Slow CI scans**  
Cache `uv`'s cache directory between CI runs. See GitHub Actions workflow for example.
