# Exit Codes

Safety v2 uses the following exit codes, making it easy to integrate into shell scripts and CI/CD pipelines.

| Code | Meaning |
|------|---------|
| `0` | ✅ No vulnerabilities found |
| `1` | ❌ One or more vulnerabilities found |
| `64` | ⚠️ Command-line usage error |
| `65` | ⚠️ No packages found to scan |
| `66` | ⚠️ Failed to fetch the vulnerability database |

!!! tip "Controlling what causes a non-zero exit"
    Use `security.cvss-severity` in your `.safety-policy.yml` to control which severity levels trigger a failure exit code.
    ```yaml
    version: "2.0"
    security:
      cvss-severity:
        - high
        - critical
    ```

---

## Shell Script Example

```bash
#!/bin/bash
set -e

safety check --key "$SAFETY_API_KEY" -r requirements.txt --policy-file .safety-policy.yml
EXIT_CODE=$?

case $EXIT_CODE in
  0)
    echo "✅ No vulnerabilities found."
    ;;
  1)
    echo "❌ Vulnerabilities detected — aborting deployment."
    exit 1
    ;;
  66)
    echo "⚠️  Could not reach Safety DB. Check network connectivity."
    exit 1
    ;;
esac
```

---

## Makefile Integration

```makefile
.PHONY: security
security:
@safety check --key "$(SAFETY_API_KEY)" -r requirements.txt || (echo "Security check failed"; exit 1)
```

---

## GitHub Actions — Fail on Vulnerabilities

```yaml
- name: Run Safety check
  run: safety check --key $SAFETY_API_KEY -r requirements.txt
  env:
    SAFETY_API_KEY: ${{ secrets.SAFETY_API_KEY }}
  # Step fails automatically when exit code is non-zero
```
