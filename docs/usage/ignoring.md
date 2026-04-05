# Ignoring Vulnerabilities

Safety v2 provides two ways to ignore known false positives: the `--ignore` CLI flag and the policy file.

---

## `--ignore` CLI Flag

Pass one or more vulnerability IDs to skip:

```bash
safety check --ignore 36546 -r requirements.txt

# Ignore multiple CVEs
safety check --ignore 36546 --ignore 40291 -r requirements.txt
```

This is suitable for one-off overrides. For persistent, team-wide ignores, use the policy file.

---

## Policy File `ignore-vulnerabilities`

Generate a default policy file:

```bash
safety generate policy_file
# Creates .safety-policy.yml in the current directory
```

Then configure ignores under `security.ignore-vulnerabilities`:

```yaml
# .safety-policy.yml
version: "2.0"

security:
  ignore-cvss-severity-below: 0        # 0=all, 4=medium+, 7=high+, 9=critical only
  ignore-cvss-unknown-severity: False
  ignore-vulnerabilities:
    36546:
      reason: "Not exploitable — our app does not follow HTTP redirects"
      expires: "2025-06-30"
  continue-on-vulnerability-error: False
```

Apply the policy:

```bash
safety check --policy-file .safety-policy.yml -r requirements.txt
```

---

## Best Practices

- [ ] Always add a `reason` field for every ignored CVE in the policy file
- [ ] Always add an `expires` date — re-evaluate when it passes
- [ ] Never ignore `critical` severity without security team approval
- [ ] Commit `.safety-policy.yml` to version control for team-wide consistency
- [ ] Remove an ignore entry as soon as the package is upgraded past the affected version
