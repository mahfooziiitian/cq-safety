# Safety Policy Files (v2)

Safety v2 uses a **version 2.0** policy schema to configure severity thresholds, ignored CVEs, and unpinned-requirements behaviour.

---

## Generate a Policy File

```bash
safety generate policy_file
# Creates .safety-policy.yml in the current directory
```

Review an existing JSON report:

```bash
safety review --file reports/safety-report.json
```

---

## Full v2 Policy File Reference

```yaml
# .safety-policy.yml
version: "2.0"

security:
  # Severity levels that trigger a scan failure (exit code 1)
  cvss-severity:
    - high
    - critical
    - medium

  # Treat vulnerabilities with unknown CVSS score as a failure
  ignore-cvss-unknown-severity: false

  # Vulnerabilities to ignore — always document reason and expiry
  ignore-vulnerabilities:
    36546:
      reason: "Not exploitable — no HTTP redirects in our deployment"
      expires: "2025-06-30"
    40291:
      reason: "Mitigated by WAF — awaiting upstream patch"
      expires: "2025-09-01"

# Treat unpinned requirements as an error
ignore-unpinned-requirements: false
```

---

## Schema Reference

### `version`

Must be `"2.0"` for the v2 schema.

### `security.cvss-severity`

List of CVSS severity levels that cause a non-zero exit code.

| Value | Description |
|-------|-------------|
| `critical` | CVSS score 9.0–10.0 |
| `high` | CVSS score 7.0–8.9 |
| `medium` | CVSS score 4.0–6.9 |
| `low` | CVSS score 0.1–3.9 |

### `security.ignore-cvss-unknown-severity`

When `true`, vulnerabilities with no CVSS score are not treated as failures.

### `security.ignore-vulnerabilities`

Map of vulnerability IDs to ignore entries.

| Field | Required | Description |
|-------|----------|-------------|
| `reason` | Recommended | Why this CVE is safe to ignore |
| `expires` | Recommended | ISO 8601 date after which the ignore should be reviewed |

### `ignore-unpinned-requirements`

When `false` (default), Safety reports unpinned packages as a warning.

---

## Using the Policy File

```bash
# Apply during a scan
safety check --policy-file .safety-policy.yml -r requirements.txt

# Generate a fresh policy file
safety generate policy_file

# Review a saved JSON report
safety review --file reports/safety-report.json
```

!!! tip
    Commit `.safety-policy.yml` to version control so all team members and CI/CD pipelines use consistent ignore rules.
