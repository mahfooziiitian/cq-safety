# Safety CLI 3

**Safety CLI 3** is a Python dependency security scanner by [safetycli.com](https://safetycli.com). It detects known vulnerabilities, enforces security policies, and integrates with [platform.safetycli.com](https://platform.safetycli.com) for team dashboards and audit logging.

---

## Features

| Feature | Description |
|---------|-------------|
| **Vulnerability scanning** | Check all installed packages against the Safety database |
| **Policy enforcement** | Define severity thresholds and approved exceptions |
| **Auto-fix** | Apply safe version upgrades automatically |
| **Multi-format output** | screen, JSON, HTML, plain text, SPDX SBOM |
| **CI/CD integration** | GitHub Actions, GitLab CI, pre-commit hooks |
| **Platform integration** | Dashboards, audit logs, team management |

---

## Quick Example

```bash
# Install
pip install safety

# Authenticate (development)
safety auth login

# Scan your environment
safety scan

# Scan with detailed output
safety scan --detailed-output

# CI/CD scan with API key
safety --key $SAFETY_API_KEY --stage cicd scan \
  --policy-file .safety-policy.yml \
  --save-as json reports/safety-report.json
```

---

## Navigation

- **Getting Started** — [Installation](getting-started/installation.md) · [Quickstart](getting-started/quickstart.md)
- **Usage** — [Scanning](usage/scanning.md) · [Output Formats](usage/output-formats.md) · [Ignoring Vulnerabilities](usage/ignoring.md) · [Policy Files](usage/policy-files.md)
- **CI/CD** — [GitHub Actions](ci-cd/github-actions.md) · [GitLab CI](ci-cd/gitlab-ci.md) · [Pre-commit](ci-cd/pre-commit.md)
- **Reference** — [CLI Reference](reference/cli.md) · [Exit Codes](reference/exit-codes.md) · [Troubleshooting](reference/troubleshooting.md)

---

## Links

- **Documentation:** https://docs.safetycli.com
- **Platform:** https://platform.safetycli.com
- **PyPI:** https://pypi.org/project/safety/
- **GitHub:** https://github.com/pyupio/safety
