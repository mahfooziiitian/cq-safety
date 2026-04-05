# Ignoring Vulnerabilities

Safety CLI 3 does **not** have a `--ignore` CLI flag. All vulnerability exceptions are managed through the **policy file** (`installation.allow.vulnerabilities`). This approach ensures exceptions are documented, version-controlled, and auditable.

---

## Policy File Exceptions

Add exceptions to your `.safety-policy.yml`:

```yaml
installation:
  allow:
    vulnerabilities:
      CVE-2024-12345:
        reason: "False positive — only affects Windows builds"
        expires: "2025-06-01"
      CVE-2023-99999:
        reason: "Accepted risk — no fix available, mitigated by network isolation"
```

Each entry requires:

| Field | Required | Description |
|-------|----------|-------------|
| `reason` | Yes | Document why this exception is accepted |
| `expires` | Recommended | Date when the exception should be reviewed |

---

## Auto-Ignore in Report

The `auto-ignore-in-report` section suppresses certain result classes from the report entirely:

```yaml
report:
  dependency-vulnerabilities:
    auto-ignore-in-report:
      python:
        # Suppress results from the active virtual environment itself
        environment-results: true
        # Suppress packages without pinned versions
        unpinned-requirements: true
      # Suppress all vulnerabilities at these severity levels
      cvss-severity: []
```

To suppress all `low` and `info` severity findings:

```yaml
cvss-severity:
  - low
  - info
```

---

## Best Practices

- [ ] **Document every exception** with a `reason` — vague reasons like "ignore" are not acceptable.
- [ ] **Set an expiry date** (`expires`) for all exceptions so they are periodically reviewed.
- [ ] **Commit the policy file** to version control so exceptions are tracked.
- [ ] **Use `auto-ignore-in-report`** to suppress noise (e.g., unpinned transitive deps) rather than creating individual exceptions.
- [ ] **Review exceptions in PRs** — treat security exceptions like code changes.
- [ ] **Run `safety validate policy_file`** after editing `.safety-policy.yml` to catch syntax errors.
- [ ] **Check the Safety Platform** audit log for a history of which exceptions were active during each scan.

---

## Migrating from v2

| v2 | v3 |
|----|-----|
| `safety check --ignore CVE-xxx` | `installation.allow.vulnerabilities` in policy file |
| `ignore-cvss-severity-below: 4.0` | `auto-ignore-in-report.cvss-severity: [low, info]` |
| `continue-on-vulnerability-error: true` | `fail-scan-with-exit-code.enabled: false` |
