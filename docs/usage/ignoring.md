# Ignoring Vulnerabilities

In Safety v3, vulnerability ignores are configured via the **policy file** (v3 schema). The old `--ignore` CLI flag is no longer available in `safety scan`.

---

## Using the Policy File

Generate a default policy file:

```bash
safety generate policy_file
# Creates .safety-policy.yml in the current directory
```

Then configure ignores under `installation.allow.vulnerabilities`:

```yaml
# .safety-policy.yml
version: '3.0'

installation:
  default-action: allow
  allow:
    vulnerabilities:
      CVE-2018-18074:
        reason: "Not exploitable — our app does not follow HTTP redirects"
        # Re-evaluate periodically; remove when package is upgraded
```

Apply the policy:

```bash
safety scan --policy-file .safety-policy.yml
```

---

## Auto-Ignore in Reports

You can suppress categories of results from the report (they still scan, just not shown):

```yaml
report:
  dependency-vulnerabilities:
    auto-ignore-in-report:
      python:
        environment-results: true      # ignore env-level results
        unpinned-requirements: true    # ignore unpinned packages
      cvss-severity:
        - low                          # suppress Low severity from report
```

---

## Blocking vs Warning

Safety v3 lets you set per-severity **block** or **warn** behaviour:

```yaml
installation:
  deny:
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

## Best Practices

- [ ] Always add a `reason` comment for every ignored CVE
- [ ] Set a calendar reminder to re-evaluate ignored CVEs after package upgrades
- [ ] Never allow `critical` severity without a security team approval
- [ ] Commit `.safety-policy.yml` to version control for team-wide consistency
- [ ] Run `safety validate policy_file` after every policy change
