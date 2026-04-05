# cq-safety

**Python dependency vulnerability scanning with Safety v2.**

[Safety](https://pyup.io/safety/) checks your Python packages against a curated database of known CVEs, helping you catch vulnerable dependencies before they reach production.

---

## Why Safety?

!!! danger "A06:2021 — Vulnerable and Outdated Components"
    The OWASP Top 10 lists using components with known vulnerabilities as one of the most critical web application security risks. Safety automates detection of these vulnerabilities in your Python supply chain.

| Feature | Description |
|---|---|
| 🔍 **CVE scanning** | Checks packages against the Safety vulnerability database |
| 📄 **Requirements file scan** | `safety check -r requirements.txt` |
| 🔧 **Policy files v2** | Version 2.0 schema with severity thresholds and ignore lists |
| 🔑 **API key access** | API key for CI/CD and commercial daily DB updates |
| 🚀 **CI/CD ready** | Native support for GitHub Actions, GitLab CI, and pre-commit |
| 📊 **Multiple output formats** | JSON, bare, full-report, short-report |

---

## Quick Example

```bash
# Install Safety
pip install safety

# Scan installed packages
safety check

# Scan a requirements file
safety check -r requirements.txt

# Scan from pip freeze
pip freeze | safety check --stdin

# JSON output
safety check --json

# CI/CD scan with API key
safety check --key $SAFETY_API_KEY -r requirements.txt
```

---

## This Project

This repository (`cq-safety`) is a **code-quality reference project** for the Safety v2 tool. It provides:

- A full tutorial covering installation through CI/CD integration
- Reusable GitHub Actions and GitLab CI snippets
- Policy file v2 templates for enterprise workflows

Use the navigation to explore the docs.
