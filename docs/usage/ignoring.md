# Ignoring Vulnerabilities

Sometimes a vulnerability is not exploitable in your specific deployment context. Safety provides two ways to suppress it.

---

## One-off Ignore (CLI flag)

```bash
safety check --ignore 36546 -r requirements.txt
```

!!! warning
    Always document *why* a vulnerability is ignored. Use a policy file for persistent ignores.

---

## Persistent Ignores (Policy File)

For team-wide, version-controlled ignores, use a `.safety-policy.yml` file.

```bash
# Generate a default policy file
safety generate policy_file
```

Then add your ignores:

```yaml
# .safety-policy.yml
version: "2.0"

security:
  ignore-vulnerabilities:
    36546:
      reason: "Not exploitable — our deployment does not follow HTTP redirects"
      expires: "2025-06-30"
```

Apply the policy:

```bash
safety check --policy-file .safety-policy.yml -r requirements.txt
```

See [Policy Files](policy-files.md) for the full schema.

---

## Best Practices

- [ ] Always add a `reason` explaining why the CVE is not exploitable
- [ ] Always set an `expires` date to force a re-evaluation
- [ ] Review ignored CVEs in every security audit
- [ ] Never ignore `critical` severity CVEs without an approved security exception
