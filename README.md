# Safety — Python Dependency Vulnerability Scanner

A tutorial and reference guide for using [Safety](https://pyup.io/safety/) to detect known security vulnerabilities in Python dependencies.

---

## Table of Contents

1. [What is Safety?](#what-is-safety)
2. [Installation](#installation)
3. [Quick Start](#quick-start)
4. [How Safety Works](#how-safety-works)
5. [Scanning Options](#scanning-options)
6. [Understanding the Output](#understanding-the-output)
7. [Output Formats](#output-formats)
8. [Ignoring Vulnerabilities](#ignoring-vulnerabilities)
9. [CI/CD Integration](#cicd-integration)
10. [Safety Policy Files](#safety-policy-files)
11. [API Key & Safety DB](#api-key--safety-db)
12. [Common Workflows](#common-workflows)
13. [Exit Codes](#exit-codes)
14. [Troubleshooting](#troubleshooting)

---

## What is Safety?

Safety is an open-source CLI tool and Python library that checks your project's dependencies against a curated database of known security vulnerabilities (CVEs). It integrates with `pip`, `requirements.txt`, `Pipfile`, and `pyproject.toml` workflows.

**Key features:**
- Scans installed packages or `requirements.txt` files
- Uses the [Safety DB](https://github.com/pyupio/safety-db) (updated daily)
- Supports JSON, text, and bare output formats
- Policy-file support for enterprise workflows
- Native GitHub Actions support

---

## Installation

```bash
# Recommended: install in your project's virtual environment
pip install safety

# Verify installation
safety --version
```

> **Python support:** Safety requires Python 3.6+.

---

## Quick Start

```bash
# Scan all packages currently installed in the active environment
safety check

# Scan a specific requirements file
safety check -r requirements.txt

# Scan multiple requirement files
safety check -r requirements.txt -r requirements-dev.txt
```

---

## How Safety Works

1. Safety reads your installed packages (or a requirements file).
2. It queries the Safety vulnerability database (local or remote).
3. Each package version is checked against known CVE entries.
4. Any matched vulnerabilities are reported with severity, CVE IDs, and remediation advice.

```
Your packages  →  Safety DB lookup  →  Vulnerability report
```

---

## Scanning Options

| Flag | Description |
|------|-------------|
| `-r <file>` | Scan a requirements file instead of the active environment |
| `--stdin` | Read packages from stdin (e.g., piped from `pip freeze`) |
| `--key <api-key>` | Use a Safety API key for the full commercial database |
| `--db <path>` | Use a local copy of the Safety DB (offline mode) |
| `--ignore <id>` | Ignore a specific vulnerability ID |
| `--policy-file <path>` | Apply a YAML policy file |
| `--full-report` | Show the full advisory text for each vulnerability |
| `--short-report` | Show a condensed one-line summary per vulnerability |
| `--cache` | Cache the database locally for faster repeated scans |
| `--proxyhost` / `--proxyport` | Use an HTTP proxy |

### Examples

```bash
# Pipe from pip freeze (useful in Docker builds)
pip freeze | safety check --stdin

# Full advisory text
safety check --full-report -r requirements.txt

# Offline scan with a local DB copy
safety check --db /path/to/local-safety-db -r requirements.txt
```

---

## Understanding the Output

A typical vulnerability report looks like:

```
+===========================================================================+
| REPORT                                                                    |
| checked 42 packages, using free DB (updated once a month)                 |
+===========================================================================+
| No known security vulnerabilities found.                                  |
+===========================================================================+
```

When vulnerabilities are found:

```
+===========================================================================+
| REPORT                                                                    |
| checked 42 packages, using free DB (updated once a month)                 |
+============================+===========+==========================+=======+
| package                    | installed | affected                | ID    |
+============================+===========+==========================+=======+
| requests                   | 2.19.1    | <2.20.0                 | 36546 |
+============================+===========+==========================+=======+

requests 2.19.1 has a known security vulnerability:
  CVE-2018-18074 - Requests library before 2.20.0 sends an HTTP
  Authorization header to an http URI upon receiving a same-hostname
  https-to-http redirect, which makes it easier for remote attackers
  to discover credentials by sniffing the network.

  Remediation: Upgrade to requests>=2.20.0
```

**Fields explained:**
- **package** — the vulnerable package name
- **installed** — version you currently have
- **affected** — version range that is vulnerable
- **ID** — Safety DB vulnerability ID (maps to CVE)

---

## Output Formats

### Default (human-readable)

```bash
safety check -r requirements.txt
```

### JSON (for tooling / CI parsing)

```bash
safety check -r requirements.txt --json
```

Output structure:
```json
[
  [
    "requests",
    "<2.20.0",
    "2.19.1",
    "Requests before 2.20.0 sends Authorization headers on redirect...",
    "36546"
  ]
]
```

### Bare (package names only)

```bash
safety check -r requirements.txt --bare
```

---

## Ignoring Vulnerabilities

Use `--ignore` to suppress a known/accepted vulnerability by its Safety ID:

```bash
safety check --ignore 36546 -r requirements.txt
```

For persistent ignores, use a **policy file** (see next section).

> ⚠️ Always document *why* a vulnerability is ignored in your policy file or PR description.

---

## Safety Policy Files

A policy file (`.safety-policy.yml`) lets you configure ignores, severity thresholds, and scan targets declaratively.

### Create the default policy file

```bash
safety generate policy_file
```

### Example `.safety-policy.yml`

```yaml
# .safety-policy.yml
version: "2.0"

security:
  # Fail the scan only for vulnerabilities with CVSS score >= 7.0 (High/Critical)
  cvss-severity: ["high", "critical"]

  ignore-cvss-unknown-severity: False

  ignore-vulnerabilities:
    36546:
      reason: "Not exploitable in our deployment (no HTTP redirects used)"
      expires: "2024-06-30"   # Re-evaluate after this date

# Optionally ignore dev/test packages
ignore-unpinned-requirements: False
```

### Use the policy file

```bash
safety check --policy-file .safety-policy.yml -r requirements.txt
```

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

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install dependencies
        run: pip install -r requirements.txt safety

      - name: Run Safety check
        run: safety check -r requirements.txt --full-report
        env:
          SAFETY_API_KEY: ${{ secrets.SAFETY_API_KEY }}   # Optional: commercial DB
```

### GitLab CI

```yaml
# .gitlab-ci.yml
safety-scan:
  image: python:3.11
  script:
    - pip install safety
    - pip install -r requirements.txt
    - safety check -r requirements.txt --json > safety-report.json
  artifacts:
    paths:
      - safety-report.json
    when: always
```

### Pre-commit Hook

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/Lucas-C/pre-commit-hooks-safety
    rev: v1.3.3
    hooks:
      - id: python-safety-dependencies-check
        args: ["--short-report"]
```

### Makefile

```makefile
.PHONY: security
security:
	safety check -r requirements.txt --full-report
```

---

## API Key & Safety DB

| Tier | Database | Update Frequency |
|------|----------|-----------------|
| Free (no key) | Safety DB (open source) | Monthly |
| API key (pyup.io) | Commercial DB | Daily |

### Setting the API key

```bash
# Environment variable (recommended for CI)
export SAFETY_API_KEY=your-key-here

# Or pass directly
safety check --key your-key-here -r requirements.txt
```

Get a free API key at [pyup.io](https://pyup.io/account/api-key/).

---

## Common Workflows

### Workflow 1: Audit before releasing

```bash
# Pin all dependencies first
pip freeze > requirements-lock.txt

# Run audit
safety check -r requirements-lock.txt --full-report
```

### Workflow 2: Scan only direct dependencies

```bash
# requirements.txt contains only your direct deps (not transitive)
safety check -r requirements.txt
```

### Workflow 3: Generate a JSON report for SIEM/dashboards

```bash
safety check -r requirements.txt --json 2>/dev/null | tee safety-report.json
```

### Workflow 4: Fail the build on High/Critical only

```bash
# Use a policy file that only fails on high/critical CVEs
safety check --policy-file .safety-policy.yml -r requirements.txt
```

### Workflow 5: Scan inside a Docker container

```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt safety \
    && safety check -r requirements.txt \
    && pip uninstall -y safety   # Remove from production image
```

---

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | No vulnerabilities found |
| `1` | One or more vulnerabilities found |
| `64` | Command-line usage error |
| `65` | No packages to scan |
| `66` | Database fetch error |

Use these in shell scripts:

```bash
safety check -r requirements.txt
if [ $? -ne 0 ]; then
  echo "Vulnerabilities detected — aborting deployment"
  exit 1
fi
```

---

## Troubleshooting

### "No packages found in environment"

You may be outside a virtual environment. Activate it first:
```bash
source .venv/bin/activate
safety check
```

### "Unable to load vulnerability database"

Check your internet connection, or use `--db` with a local snapshot:
```bash
safety check --db /path/to/safety-db -r requirements.txt
```

### Scan returns false positives

Use `--ignore <id>` or add the ID to your `.safety-policy.yml` with a documented reason and expiry date.

### Safety is slow in CI

Enable caching:
```bash
safety check --cache -r requirements.txt
```

---

## Additional Resources

- [Safety documentation](https://docs.pyup.io/docs/safety-2-cli-commands-and-options)
- [Safety DB (open source)](https://github.com/pyupio/safety-db)
- [pyup.io](https://pyup.io) — commercial vulnerability database and dependency bot
- [CVE database](https://cve.mitre.org/) — upstream CVE source
- [OWASP Top 10 — A06: Vulnerable and Outdated Components](https://owasp.org/Top10/A06_2021-Vulnerable_and_Outdated_Components/)


https://github.com/pyupio/safety
