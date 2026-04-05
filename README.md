# Safety CLI 3 — Python Dependency Vulnerability Scanner

A tutorial and reference guide for using [Safety CLI 3](https://docs.safetycli.com) to detect known security vulnerabilities in Python dependencies.

> **Safety v3** replaces `safety check` with `safety scan` and introduces browser-based authentication, a new policy schema (v3.0), auto-fix support, and multi-format output.

---

## Table of Contents

1. [What is Safety?](#what-is-safety)
2. [Installation](#installation)
3. [Authentication](#authentication)
4. [Quick Start](#quick-start)
5. [How Safety Works](#how-safety-works)
6. [Scanning Options](#scanning-options)
7. [Understanding the Output](#understanding-the-output)
8. [Output Formats](#output-formats)
9. [Auto-Fix Vulnerabilities](#auto-fix-vulnerabilities)
10. [Ignoring Vulnerabilities](#ignoring-vulnerabilities)
11. [CI/CD Integration](#cicd-integration)
12. [Safety Policy Files v3](#safety-policy-files-v3)
13. [API Key & Safety Platform](#api-key--safety-platform)
14. [Common Workflows](#common-workflows)
15. [Exit Codes](#exit-codes)
16. [Deprecated Commands](#deprecated-commands)
17. [Troubleshooting](#troubleshooting)

---

## What is Safety?

Safety CLI 3 is an open-source command-line tool and Python library that checks your project's dependencies against a curated database of known security vulnerabilities (CVEs). It integrates with `pip`, `requirements.txt`, `Pipfile`, and `pyproject.toml` workflows.

**Key features in v3:**
- `safety scan` — project-directory-based scanning (replaces `safety check`)
- Browser-based OAuth login (`safety auth login`) for development
- API key support for CI/CD and production stages (`--stage cicd`)
- New policy schema v3.0 with fail thresholds, firewall rules, and auto-ignore
- Auto-fix support (`--apply-fixes`) for requirements.txt files
- Multiple output formats: JSON, HTML, SPDX, text, screen

---

## Installation

```bash
# Recommended: install in your project's virtual environment
pip install "safety>=3.0"

# With uv (recommended for projects)
uv add --dev "safety>=3.0"

# Verify installation
safety --version
# safety, version 3.7.x
```

> **Python support:** Safety v3 requires Python 3.7+.

---

## Authentication

Safety v3 introduces two authentication modes depending on your context.

### Development (browser-based OAuth)

```bash
# Authenticate once — opens platform.safetycli.com in your browser
safety auth login

# For headless/SSH environments
safety auth login --headless

# Check auth status
safety auth status

# Log out
safety auth logout
```

Register for a free account at [platform.safetycli.com](https://platform.safetycli.com).

### CI/CD & Production (API key)

```bash
# Set via environment variable (recommended)
export SAFETY_API_KEY=your-key-here

# Or pass directly as a global flag
safety --key $SAFETY_API_KEY --stage cicd scan
```

### Lifecycle Stages

| Stage | Auth Method | Use Case |
|-------|------------|----------|
| `development` | `safety auth login` | Local development (default) |
| `cicd` | `--key` / `SAFETY_API_KEY` | CI/CD pipelines |
| `production` | `--key` / `SAFETY_API_KEY` | Production systems |

---

## Quick Start

```bash
# 1. Authenticate (first time)
safety auth login

# 2. Scan the current project directory
safety scan

# 3. Verbose output
safety scan --detailed-output

# 4. CI/CD scan with API key
safety --key $SAFETY_API_KEY --stage cicd scan
```

---

## How Safety Works

1. Safety scans your project directory tree (auto-discovers dependency files)
2. It queries the Safety vulnerability database (via Safety Platform)
3. Each package version is checked against known CVE entries
4. Results are reported with severity scores, CVE IDs, affected ranges, and fix versions

```
Project directory  →  Auto-discover deps  →  Safety DB lookup  →  Vulnerability report
```

---

## Scanning Options

### Global Flags (before the subcommand)

| Flag | Description |
|------|-------------|
| `--stage <stage>` | `development` (default), `cicd`, `production` |
| `--key <api-key>` | API key for cicd/production scans |
| `--proxy-host` / `--proxy-port` / `--proxy-protocol` | HTTP proxy settings |

### `safety scan` Flags

| Flag | Default | Description |
|------|---------|-------------|
| `--target <path>` | `.` | Project directory to scan |
| `--output <format>` | `screen` | `screen`, `json`, `html`, `text`, `spdx` |
| `--detailed-output` | off | Verbose report (screen only) |
| `--save-as <format> <file>` | — | Save results to a file (repeatable) |
| `--policy-file <path>` | — | Apply a local v3 policy file |
| `--apply-fixes` | off | Auto-patch requirements.txt files |
| `--filter <key>` | — | Filter JSON output by key |

### Examples

```bash
# Scan current directory
safety scan

# Scan a specific directory
safety scan --target /path/to/project

# CI/CD scan, save JSON report
safety --key $SAFETY_API_KEY --stage cicd scan --save-as json report.json

# Scan with policy file
safety scan --policy-file .safety-policy.yml

# Auto-fix requirements.txt
safety scan --apply-fixes
```

---

## Understanding the Output

**No vulnerabilities found:**

```
  Safety Report
  ─────────────
  Scanned 0 vulnerabilities in 42 packages.
  No known security vulnerabilities found.
```

**Vulnerability detected (screen output):**

```
  Safety Report
  ─────────────
  → requests 2.19.1
    CVE-2018-18074 (CVSS 9.8 Critical)
    Affected: <2.20.0
    Fix: Upgrade to requests>=2.20.0
```

**Fields explained:**
- **package + version** — the vulnerable package and installed version
- **CVE ID** — standard vulnerability identifier
- **CVSS score + severity** — Common Vulnerability Scoring System rating
- **Affected** — version range that is vulnerable
- **Fix** — minimum safe version to upgrade to

---

## Output Formats

### Default (screen)

```bash
safety scan
safety scan --detailed-output    # full advisory text
```

### JSON

```bash
safety scan --output json
safety scan --save-as json safety-report.json
```

### HTML

```bash
safety scan --save-as html safety-report.html
```

### SPDX (SBOM)

```bash
safety scan --save-as spdx safety-report.spdx
```

### Save multiple formats simultaneously

```bash
safety scan \
  --save-as json safety-report.json \
  --save-as html safety-report.html \
  --output screen
```

### Parsing JSON in Python

```python
import json, subprocess

result = subprocess.run(
    ["safety", "scan", "--output", "json"],
    capture_output=True, text=True, check=False,
)
report = json.loads(result.stdout)
for vuln in report.get("vulnerabilities", []):
    print(
        f"{vuln['package_name']} {vuln['installed_version']} "
        f"— {vuln['vulnerability_id']} "
        f"({vuln['severity']['cvss_v3']['base_severity']})"
    )
```

---

## Auto-Fix Vulnerabilities

Safety v3 can automatically update vulnerable packages in `requirements.txt` files:

```bash
safety scan --apply-fixes
```

> **Note:** `--apply-fixes` currently supports `requirements.txt` files only. `pyproject.toml`, `Pipfile`, and `setup.cfg` require manual updates.

---

## Ignoring Vulnerabilities

In Safety v3, ignores are configured in the **policy file** (v3 schema). The old `--ignore` CLI flag is not available in `safety scan`.

```yaml
# .safety-policy.yml
installation:
  allow:
    vulnerabilities:
      CVE-2018-18074:
        reason: "Not exploitable — no HTTP redirects in our deployment"
```

Apply the policy:

```bash
safety scan --policy-file .safety-policy.yml
```

> ⚠️ Always document *why* a CVE is being allowed and review it after each dependency upgrade.

---

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/security.yml
name: Security Scan

on: [push, pull_request]

jobs:
  safety:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"
      - run: pip install "safety>=3.0"
      - name: Run Safety scan
        run: safety --key $SAFETY_API_KEY --stage cicd scan
        env:
          SAFETY_API_KEY: ${{ secrets.SAFETY_API_KEY }}
```

### GitLab CI

```yaml
safety-scan:
  stage: test
  image: python:3.11-slim
  script:
    - pip install "safety>=3.0"
    - safety --key $SAFETY_API_KEY --stage cicd scan --save-as json safety-report.json
  artifacts:
    paths: [safety-report.json]
    when: always
```

### Pre-commit Hook

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: safety-scan
        name: Safety vulnerability scan
        language: system
        entry: safety
        args: ["scan", "--detailed-output"]
        pass_filenames: false
        always_run: true
```

---

## Safety Policy Files v3

Generate a default v3 policy file:

```bash
safety generate policy_file
# Creates .safety-policy.yml
```

Validate a policy file:

```bash
safety validate policy_file
```

### Full Policy Example

```yaml
version: '3.0'

scanning-settings:
  max-depth: 6
  exclude:
    - tests/
    - docs/
  include-files:
    - requirements-prod.txt

report:
  dependency-vulnerabilities:
    enabled: true
    auto-ignore-in-report:
      python:
        environment-results: true
        unpinned-requirements: true
      cvss-severity:
        - low

fail-scan-with-exit-code:
  dependency-vulnerabilities:
    enabled: true
    fail-on-any-of:
      cvss-severity:
        - high
        - critical
        - medium
      exploitability:
        - high
        - critical
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
    vulnerabilities:
      CVE-2018-18074:
        reason: "Not exploitable — no HTTP-to-HTTPS redirects in our stack"
  deny:
    packages: {}
    vulnerabilities:
      warning-on-any-of:
        cvss-severity: [low, medium]
      block-on-any-of:
        cvss-severity: [high, critical]
```

---

## API Key & Safety Platform

| Auth Method | Use Case |
|------------|----------|
| `safety auth login` | Development — browser OAuth, free |
| `SAFETY_API_KEY` env var | CI/CD and production — API key |

Get an API key at [platform.safetycli.com](https://platform.safetycli.com).

---

## Common Workflows

### Workflow 1: Developer daily scan

```bash
safety auth login          # once
safety scan --detailed-output
```

### Workflow 2: CI/CD pipeline scan with JSON artifact

```bash
safety --key $SAFETY_API_KEY --stage cicd scan \
  --policy-file .safety-policy.yml \
  --save-as json safety-report.json
```

### Workflow 3: Auto-fix before committing

```bash
safety scan --apply-fixes
git diff requirements.txt    # review changes
git add requirements.txt && git commit -m "chore: upgrade vulnerable packages"
```

### Workflow 4: SBOM generation

```bash
safety --key $SAFETY_API_KEY --stage production scan \
  --save-as spdx sbom.spdx
```

### Workflow 5: Fail build on High/Critical only

```yaml
# .safety-policy.yml
fail-scan-with-exit-code:
  dependency-vulnerabilities:
    enabled: true
    fail-on-any-of:
      cvss-severity: [high, critical]
```

```bash
safety --key $SAFETY_API_KEY --stage cicd scan --policy-file .safety-policy.yml
```

---

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | ✅ No vulnerabilities found (or none above policy threshold) |
| `1` | ❌ Vulnerabilities found above policy threshold |
| `64` | ⚠️ Command-line usage error |
| `65` | ⚠️ No packages found to scan |
| `66` | ⚠️ Database fetch error |

---

## Deprecated Commands

| Command | Status | Use Instead |
|---------|--------|-------------|
| `safety check` | ❌ Deprecated (unsupported after 1 May 2024) | `safety scan` |
| `safety license` | ❌ Deprecated | `safety scan` |
| `safety alert` | ❌ Deprecated | Safety Platform integrations |

---

## Troubleshooting

### Not authenticated
```bash
safety auth login           # development
# or
export SAFETY_API_KEY=...   # CI/CD
```

### No packages found
```bash
safety scan --target /path/to/your/project
```

### Policy file errors
```bash
safety validate policy_file   # check syntax
safety generate policy_file   # regenerate fresh v3 template
```

### Auto-fix didn't update everything
`--apply-fixes` only patches `requirements.txt`. Update `pyproject.toml` / `Pipfile` manually.

---

## Additional Resources

- [Safety CLI 3 documentation](https://docs.safetycli.com)
- [Safety Platform](https://platform.safetycli.com)
- [Safety GitHub](https://github.com/pyupio/safety)
- [OWASP A06: Vulnerable and Outdated Components](https://owasp.org/Top10/A06_2021-Vulnerable_and_Outdated_Components/)
- Support: support@safetycli.com
