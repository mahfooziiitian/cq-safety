# Safety Policy Files (v2)

Safety v2 uses a **version 2.0** policy schema to configure severity thresholds, ignored CVEs, and scan behaviour.

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
# Docs: https://docs.pyup.io/docs/safety-20-policy-files
version: "2.0"

security:
  # Ignore vulnerabilities with CVSS score below this number (0–10).
  # 0  = report everything (default)
  # 4  = ignore Low; report Medium, High, Critical
  # 7  = ignore Low & Medium; report High & Critical
  # 9  = ignore all except Critical
  ignore-cvss-severity-below: 0

  # Treat vulnerabilities with unknown CVSS score as failures
  ignore-cvss-unknown-severity: False

  # Vulnerabilities to ignore — always include reason and expiry
  ignore-vulnerabilities:
    36546:
      reason: "Not exploitable — no HTTP redirects in our deployment"
      expires: "2025-06-30"
    40291:
      reason: "Mitigated by WAF — awaiting upstream patch"
      expires: "2025-09-01"

  # Set True to suppress non-zero exit codes when vulnerabilities are found.
  # Keep False in CI so pipelines fail on vulnerabilities.
  continue-on-vulnerability-error: False
```

---

## Schema Reference

### `version`

Must be `"2.0"` for the v2 schema.

### `security.ignore-cvss-severity-below`

A numeric threshold (float, 0–10). Vulnerabilities with a CVSS score **below** this value are ignored.

| Value | Effect |
|-------|--------|
| `0` | Report everything (default) |
| `4.0` | Ignore Low; report Medium, High, Critical |
| `7.0` | Ignore Low & Medium; report High & Critical |
| `9.0` | Report Critical only |

### `security.ignore-cvss-unknown-severity`

`False` — treat unknown-CVSS vulnerabilities as failures (recommended)  
`True` — silently skip vulnerabilities with no CVSS score

### `security.ignore-vulnerabilities`

Map of Safety vulnerability IDs to ignore entries.

| Field | Required | Description |
|-------|----------|-------------|
| `reason` | Recommended | Why this CVE is safe to ignore |
| `expires` | Recommended | ISO 8601 date (`YYYY-MM-DD`) after which the ignore should be reviewed |

### `security.continue-on-vulnerability-error`

`False` — exit with code `1` when vulnerabilities are found (recommended for CI)  
`True` — always exit `0` even when vulnerabilities are found

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
