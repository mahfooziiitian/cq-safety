# Policy Files

Safety CLI 3 uses a YAML policy file (default: `.safety-policy.yml`) to configure scan behaviour, reporting, and failure thresholds.

---

## Generate and Validate

```bash
# Generate a default policy file
safety generate policy_file
# Creates .safety-policy.yml in the current directory

# Validate the policy file
safety validate policy_file
```

---

## Full v3 Schema

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

## Key Reference

### `scanning-settings`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `max-depth` | int | `6` | Maximum directory depth to scan |
| `exclude` | list | `[]` | Glob patterns to exclude from scanning |
| `include-files` | list | `[]` | Files to always include even if excluded |
| `system.targets` | list | `[]` | Additional system-level scan targets |

### `report.dependency-vulnerabilities`

| Key | Type | Description |
|-----|------|-------------|
| `enabled` | bool | Enable dependency vulnerability reporting |
| `auto-ignore-in-report.python.environment-results` | bool | Suppress results from the active venv |
| `auto-ignore-in-report.python.unpinned-requirements` | bool | Suppress packages without pinned versions |
| `auto-ignore-in-report.cvss-severity` | list | CVSS severity levels to suppress |

### `fail-scan-with-exit-code.dependency-vulnerabilities`

| Key | Type | Description |
|-----|------|-------------|
| `enabled` | bool | Enable exit code 64 on threshold breaches |
| `fail-on-any-of.cvss-severity` | list | CVSS levels that trigger failure: `critical`, `high`, `medium`, `low`, `info` |
| `fail-on-any-of.exploitability` | list | Exploitability levels that trigger failure |

### `security-updates.dependency-vulnerabilities`

| Key | Type | Description |
|-----|------|-------------|
| `auto-security-updates-limit` | list | Version bump types allowed for `--apply-fixes`: `patch`, `minor`, `major` |

### `installation`

| Key | Type | Description |
|-----|------|-------------|
| `default-action` | string | `allow` or `deny` — default for unmatched packages |
| `audit-logging.enabled` | bool | Log installation events to Safety Platform |
| `allow.packages` | list | Package names explicitly allowed |
| `allow.vulnerabilities` | map | Vulnerability IDs allowed with reason + optional expiry |
| `deny.packages` | map | Package names that must never be installed |
| `deny.vulnerabilities.warning-on-any-of.cvss-severity` | list | CVSS levels that trigger a warning |
| `deny.vulnerabilities.block-on-any-of.cvss-severity` | list | CVSS levels that block installation |

---

## Example: Strict Production Policy

```yaml
version: '3.0'

scanning-settings:
  max-depth: 6
  exclude:
    - "tests/**"
    - "docs/**"

fail-scan-with-exit-code:
  dependency-vulnerabilities:
    enabled: true
    fail-on-any-of:
      cvss-severity:
        - critical
        - high
        - medium
        - low

installation:
  default-action: allow
  allow:
    vulnerabilities:
      CVE-2024-12345:
        reason: "False positive — Windows-only, mitigated in deployment"
        expires: "2025-03-01"
```

---

## v2 → v3 Migration

| v2 Key | v3 Equivalent |
|--------|---------------|
| `ignore-cvss-severity-below` | `auto-ignore-in-report.cvss-severity` |
| `continue-on-vulnerability-error` | `fail-scan-with-exit-code.enabled: false` |
| `--ignore CVE-xxx` CLI flag | `installation.allow.vulnerabilities` |
