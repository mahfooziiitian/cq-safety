# cq-safety

**Python dependency vulnerability scanning with Safety.**

[Safety](https://pyup.io/safety/) checks your Python packages against a curated database of known CVEs, helping you catch vulnerable dependencies before they reach production.

---

## Why Safety?

!!! danger "A06:2021 — Vulnerable and Outdated Components"
    The OWASP Top 10 lists using components with known vulnerabilities as one of the most critical web application security risks. Safety automates detection of these vulnerabilities in your Python supply chain.

| Feature | Description |
|---|---|
| 🔍 **CVE scanning** | Checks packages against the Safety vulnerability database |
| 📄 **requirements.txt support** | Scans pinned dependency files directly |
| 🔧 **Policy files** | Suppress known false-positives with documented expiry dates |
| 🚀 **CI/CD ready** | Native support for GitHub Actions, GitLab CI, and pre-commit |
| 📊 **JSON output** | Machine-readable output for dashboards and SIEM tools |

---

## Quick Example

```bash
# Install Safety
pip install safety

# Scan your current environment
safety check

# Scan a requirements file
safety check -r requirements.txt
```

---

## This Project

This repository (`cq-safety`) is a **code-quality reference project** for the Safety tool. It provides:

- A full tutorial covering installation through CI/CD integration
- Reusable GitHub Actions and GitLab CI snippets
- Policy file templates for enterprise workflows

Use the navigation to explore the docs.
