# Safety Policy Files

A `.safety-policy.yml` file lets you configure Safety declaratively — setting severity thresholds, ignoring specific CVEs, and controlling scan behaviour across your whole team.

---

## Generate a Default Policy File

```bash
safety generate policy_file
# Creates .safety-policy.yml in the current directory
```

---

## Full Example

```yaml
# .safety-policy.yml
version: "2.0"

security:
  # Only fail on High and Critical CVEs (ignore Low/Medium)
  cvss-severity:
    - high
    - critical

  # Treat vulnerabilities with unknown CVSS score as failures
  ignore-cvss-unknown-severity: false

  # Per-CVE ignores — always include reason and expiry
  ignore-vulnerabilities:
    36546:
      reason: "Not exploitable — no HTTP-to-HTTPS redirect in our stack"
      expires: "2025-06-30"

    38624:
      reason: "Mitigated by WAF rule WAF-2023-041 (approved by security team)"
      expires: "2025-12-31"

# Fail on unpinned (non-exact-version) requirements
ignore-unpinned-requirements: false
```

---

## Schema Reference

### `security.cvss-severity`

List of severity levels that should cause a non-zero exit code.

| Value | CVSS Score Range |
|---|---|
| `critical` | 9.0 – 10.0 |
| `high` | 7.0 – 8.9 |
| `medium` | 4.0 – 6.9 |
| `low` | 0.1 – 3.9 |

### `security.ignore-cvss-unknown-severity`

`true` — silently skip vulnerabilities with no CVSS score  
`false` — treat them as failures (recommended)

### `security.ignore-vulnerabilities`

Map of Safety vulnerability IDs to ignore entries.

| Field | Required | Description |
|---|---|---|
| `reason` | ✅ | Why this CVE is not exploitable or has been mitigated |
| `expires` | ✅ | ISO date (`YYYY-MM-DD`) after which the ignore should be reviewed |

### `ignore-unpinned-requirements`

`true` — skip packages without exact version pins  
`false` — fail on unpinned requirements (recommended for production)

---

## Using the Policy File

```bash
safety check --policy-file .safety-policy.yml -r requirements.txt
```

Commit `.safety-policy.yml` to version control so the whole team uses the same rules.
