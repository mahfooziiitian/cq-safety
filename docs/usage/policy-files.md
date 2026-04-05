# Safety Policy Files (v3)

Safety v3 uses a completely redesigned **version 3.0** policy schema. The old v2 schema is **not compatible**.

---

## Generate a Policy File

```bash
safety generate policy_file
# Creates .safety-policy.yml in the current directory

# Validate a policy file
safety validate policy_file
```

---

## Full v3 Policy File Reference

```yaml
# .safety-policy.yml
version: '3.0'

# ── Scanning settings ─────────────────────────────────────────────────────────
scanning-settings:
  max-depth: 6              # How deep to recurse into the project tree
  exclude:                  # Paths to exclude from scanning
    - tests/
    - docs/
  include-files:            # Explicitly include additional requirement files
    - requirements-prod.txt
  system:
    targets: []             # OS-level package targets (advanced)

# ── Report settings ───────────────────────────────────────────────────────────
report:
  dependency-vulnerabilities:
    enabled: true
    auto-ignore-in-report:
      python:
        environment-results: true      # Hide env-level scan results from report
        unpinned-requirements: true    # Hide unpinned package warnings
      cvss-severity:
        - low                          # Suppress low-severity from report output

# ── Fail thresholds ───────────────────────────────────────────────────────────
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

# ── Auto security updates ─────────────────────────────────────────────────────
security-updates:
  dependency-vulnerabilities:
    auto-security-updates-limit:
      - patch           # Only apply patch-level auto-fixes (not minor/major)

# ── Package installation firewall ─────────────────────────────────────────────
installation:
  default-action: allow   # allow or deny by default
  audit-logging:
    enabled: true

  allow:
    packages: []          # Explicitly allow-listed package names
    vulnerabilities:
      CVE-2018-18074:
        reason: "Not exploitable — no HTTP-to-HTTPS redirects in our stack"

  deny:
    packages: {}          # Block specific packages entirely
    vulnerabilities:
      warning-on-any-of:
        cvss-severity:
          - low
          - medium
      block-on-any-of:
        cvss-severity:
          - high
          - critical
```

---

## Schema Reference

### `scanning-settings`

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `max-depth` | int | `6` | Directory recursion depth |
| `exclude` | list | `[]` | Paths to exclude |
| `include-files` | list | `[]` | Extra files to scan |

### `report.dependency-vulnerabilities.auto-ignore-in-report`

| Key | Type | Description |
|-----|------|-------------|
| `python.environment-results` | bool | Suppress environment-level results |
| `python.unpinned-requirements` | bool | Suppress unpinned package warnings |
| `cvss-severity` | list | Severity levels to hide from report |

### `fail-scan-with-exit-code.dependency-vulnerabilities.fail-on-any-of`

| Key | Values |
|-----|--------|
| `cvss-severity` | `critical`, `high`, `medium`, `low` |
| `exploitability` | `critical`, `high`, `medium`, `low` |

### `security-updates.dependency-vulnerabilities.auto-security-updates-limit`

| Value | Description |
|-------|-------------|
| `patch` | Allow only patch version bumps |
| `minor` | Allow patch and minor version bumps |
| `major` | Allow any version bump |

### `installation.allow.vulnerabilities`

Map of CVE IDs to ignore entries. Include a `reason` comment for auditability.

---

## Using the Policy File

```bash
# Apply during a scan
safety scan --policy-file .safety-policy.yml

# Validate the policy syntax
safety validate policy_file

# Validate a policy at a specific path
safety validate policy_file --path /path/to/.safety-policy.yml
```

!!! tip
    Commit `.safety-policy.yml` to version control. Safety Platform policies will override local policy files if you're using the Safety Platform integration.
