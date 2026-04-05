# cq-safety

**Python dependency vulnerability scanning with Safety CLI 3.**

[Safety CLI 3](https://docs.safetycli.com) checks your Python packages against a curated database of known CVEs, helping you catch vulnerable dependencies before they reach production.

!!! warning "Safety v3 — Breaking Changes"
    `safety check` is **deprecated** as of Safety 3 and was unsupported after 1 May 2024.
    The new primary command is **`safety scan`**. All docs here target Safety ≥ 3.0.

---

## Why Safety?

!!! danger "A06:2021 — Vulnerable and Outdated Components"
    The OWASP Top 10 lists using components with known vulnerabilities as one of the most critical web application security risks. Safety automates detection of these vulnerabilities in your Python supply chain.

| Feature | Description |
|---|---|
| 🔍 **CVE scanning** | Checks packages against the Safety vulnerability database |
| 📁 **Project directory scan** | Scans your entire project tree, not just one file |
| 🔧 **Policy files v3** | Version 3.0 schema with fail thresholds, auto-ignore, and firewall rules |
| 🔐 **Auth-based access** | Browser-based OAuth login or API key for CI/CD |
| 🚀 **CI/CD ready** | Native support for GitHub Actions, GitLab CI, and pre-commit |
| 📊 **Multiple output formats** | JSON, HTML, SPDX, text, and screen output |
| 🔨 **Auto-fix** | `--apply-fixes` updates requirements.txt to safe versions |
| 🔥 **Safety Firewall** | [Beta] Block malicious packages at install time |

---

## Quick Example

```bash
# Install Safety
pip install "safety>=3.0"

# Authenticate (development — one-time setup)
safety auth login

# Scan your project directory
safety scan

# Scan with JSON output
safety scan --output json

# CI/CD scan with API key
safety --key $SAFETY_API_KEY --stage cicd scan
```

---

## This Project

This repository (`cq-safety`) is a **code-quality reference project** for the Safety CLI 3 tool. It provides:

- A full tutorial covering installation through CI/CD integration
- Reusable GitHub Actions and GitLab CI snippets
- Policy file v3 templates for enterprise workflows

Use the navigation to explore the docs.
