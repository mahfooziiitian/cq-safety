# cq-safety

A complete tutorial and reference for **Safety v2** — the `safety check` era of Python dependency vulnerability scanning.

---

## Table of Contents

1. [What is Safety](#what-is-safety)
2. [Installation](#installation)
3. [Quick Start](#quick-start)
4. [How Safety Works](#how-safety-works)
5. [Scanning Options](#scanning-options)
6. [Understanding the Output](#understanding-the-output)
7. [Output Formats](#output-formats)
8. [Ignoring Vulnerabilities](#ignoring-vulnerabilities)
9. [CI/CD Integration](#cicd-integration)
10. [Safety Policy Files v2](#safety-policy-files-v2)
11. [API Key & Safety DB](#api-key--safety-db)
12. [Common Workflows](#common-workflows)
13. [Exit Codes](#exit-codes)
14. [Troubleshooting](#troubleshooting)

---

## What is Safety

[Safety](https://pyup.io/safety/) is a Python dependency vulnerability scanner. It checks your installed packages (or a `requirements.txt` file) against a curated database of known CVEs and security advisories.

Safety v2 (`safety check`) is the stable, widely-used release that integrates cleanly with existing Python tooling and CI/CD pipelines using API key authentication.

---

## Installation

### pip

```bash
pip install safety
```

### uv (recommended)

```bash
uv add --dev safety
uv sync
```

### pipx (global tool)

```bash
pipx install safety
```

### Verify

```bash
safety --version
```

---

## Quick Start

```bash
# Scan installed packages
safety check

# Scan a requirements file
safety check -r requirements.txt

# Scan from pip freeze
pip freeze | safety check --stdin

# Full report with advisory text
safety check --full-report -r requirements.txt

# JSON output
safety check --json -r requirements.txt
```

---

## How Safety Works

1. Safety reads your installed packages (or a requirements file)
2. It queries the [Safety vulnerability database](https://pyup.io/safety/) for known CVEs affecting those packages
3. It reports any matches and exits with code `1` if vulnerabilities are found

The free database is updated monthly. With a commercial API key, the database is updated daily.

---

## Scanning Options

```
safety check [OPTIONS]
```

| Flag | Description |
|------|-------------|
| `-r <file>` | Check packages listed in a requirements file (repeatable) |
| `--stdin` | Read package list from stdin |
| `--full-report` | Show full advisory text per vulnerability |
| `--short-report` | Show a condensed one-line summary |
| `--bare` | Output only vulnerable package names |
| `--json` | Output as JSON array of arrays |
| `--ignore <id>` | Ignore a vulnerability by ID (repeatable) |
| `--key <api-key>` | Use API key for daily DB updates |
| `--db <path>` | Use a local vulnerability database |
| `--cache` | Cache the DB locally (speeds up CI) |
| `--policy-file <path>` | Apply a local v2 policy file |
| `--proxy-host <host>` | HTTP proxy hostname |
| `--proxy-port <port>` | HTTP proxy port |
| `--proxy-protocol <proto>` | Proxy protocol (default: https) |

---

## Understanding the Output

```
+==============================================================================+
| REPORT                                                                       |
| checked 42 packages, using free DB (updated once a month)                   |
+============================+===========+==========================+==========+
| package                    | installed | affected                 | ID       |
+============================+===========+==========================+==========+
| requests                   | 2.19.1    | <2.20.0                  | 36546    |
+============================+===========+==========================+==========+
```

| Column | Description |
|--------|-------------|
| `package` | The vulnerable package name |
| `installed` | The version you have installed |
| `affected` | The version range that is vulnerable |
| `ID` | Safety vulnerability ID |

---

## Output Formats

### Default (human-readable table)

```bash
safety check -r requirements.txt
```

### Full report

```bash
safety check --full-report -r requirements.txt
```

### Short report

```bash
safety check --short-report -r requirements.txt
```

### JSON (array of arrays)

```bash
safety check --json -r requirements.txt > safety-report.json
```

v2 JSON structure: `[package_name, affected_range, installed_version, advisory_text, vuln_id]`

```json
[
  ["requests", "<2.20.0", "2.19.1", "Advisory text...", "36546"]
]
```

Parsing in Python:

```python
import json, subprocess

result = subprocess.run(
    ["safety", "check", "--json", "-r", "requirements.txt"],
    capture_output=True, text=True, check=False,
)
for pkg, affected, installed, advisory, vid in json.loads(result.stdout):
    print(f"{pkg} {installed} — {vid} (affected: {affected})")
```

### Bare

```bash
safety check --bare -r requirements.txt
```

Outputs only vulnerable package names, one per line.

---

## Ignoring Vulnerabilities

### Via CLI flag

```bash
safety check --ignore 36546 -r requirements.txt
safety check --ignore 36546 --ignore 40291 -r requirements.txt
```

### Via policy file

```yaml
# .safety-policy.yml
version: "2.0"

security:
  ignore-cvss-severity-below: 7   # 7=ignore Low & Medium; fail on High & Critical
  ignore-cvss-unknown-severity: False
  ignore-vulnerabilities:
    36546:
      reason: "Not exploitable — no HTTP redirects in our deployment"
      expires: "2025-06-30"
  continue-on-vulnerability-error: False
```

```bash
safety check --policy-file .safety-policy.yml -r requirements.txt
```

---

## CI/CD Integration

### GitHub Actions

```yaml
- name: Run Safety check
  run: safety check --key $SAFETY_API_KEY -r requirements.txt
  env:
    SAFETY_API_KEY: ${{ secrets.SAFETY_API_KEY }}
```

### GitLab CI

```yaml
safety-check:
  stage: test
  image: python:3.11-slim
  script:
    - pip install safety
    - safety check --key $SAFETY_API_KEY -r requirements.txt
  variables:
    SAFETY_API_KEY: $SAFETY_API_KEY
```

### pre-commit

```yaml
repos:
  - repo: https://github.com/Lucas-C/pre-commit-hooks-safety
    rev: v1.3.3
    hooks:
      - id: python-safety-dependencies-check
        args: ["--short-report"]
```

### Makefile

```makefile
.PHONY: scan
scan:
safety check --full-report -r requirements.txt

.PHONY: scan-ci
scan-ci:
safety check --key $(SAFETY_API_KEY) --json -r requirements.txt > reports/safety-report.json
```

---

## Safety Policy Files v2

```yaml
version: "2.0"

security:
  # Ignore vulnerabilities with CVSS score below this number (0–10)
  # 0=all, 4=medium+, 7=high+, 9=critical only
  ignore-cvss-severity-below: 0

  # Treat unknown CVSS scores as failures
  ignore-cvss-unknown-severity: False

  # CVEs to ignore (always include reason + expiry)
  ignore-vulnerabilities:
    36546:
      reason: "Not exploitable — no HTTP redirects in our deployment"
      expires: "2025-06-30"

  # Keep False so CI fails on vulnerabilities
  continue-on-vulnerability-error: False
```

Generate a policy file:

```bash
safety generate policy_file
```

Review a report:

```bash
safety review --file reports/safety-report.json
```

---

## API Key & Safety DB

| Tier | DB update frequency | How to get |
|------|---------------------|------------|
| Free | Monthly | No key needed |
| Commercial | Daily | [pyup.io/account/api-key/](https://pyup.io/account/api-key/) |

Using the API key:

```bash
# Environment variable (recommended)
export SAFETY_API_KEY=your-key-here
safety check -r requirements.txt

# Or pass directly
safety check --key your-key-here -r requirements.txt
```

---

## Common Workflows

### 1. Check a requirements file

```bash
safety check -r requirements.txt
```

### 2. CI/CD with JSON report

```bash
safety check --key $SAFETY_API_KEY -r requirements.txt --json > reports/safety-report.json
```

### 3. Scan with policy file

```bash
safety check --policy-file .safety-policy.yml -r requirements.txt
```

### 4. Cache database in CI

```bash
safety check --cache -r requirements.txt
```

### 5. Use a local (offline) database

```bash
safety check --db /path/to/safety-db -r requirements.txt
```

---

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | ✅ No vulnerabilities found |
| `1` | ❌ One or more vulnerabilities found |
| `64` | ⚠️ Command-line usage error |
| `65` | ⚠️ No packages found to scan |
| `66` | ⚠️ Failed to fetch the vulnerability database |

---

## Troubleshooting

**Wrong environment scanned** → Pass `-r requirements.txt` explicitly.

**DB fetch failure** → Use `--cache` or `--db /path/to/local-db`.

**False positive** → Use `--ignore <id>` or add to policy file with `reason` + `expires`.

**Slow CI** → Use `--cache` to reuse the downloaded database.

**API key not working** → Verify at [pyup.io/account/api-key/](https://pyup.io/account/api-key/); pass as `--key` flag.
