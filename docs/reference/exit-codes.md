# Exit Codes

Safety CLI 3 uses specific exit codes to communicate scan results to calling processes.

## Codes

| Code | Name | Meaning |
|------|------|---------|
| `0` | Success | Scan passed — no actionable vulnerabilities above threshold |
| `1` | Error | Unexpected error occurred |
| `64` | Vulnerabilities found | One or more vulnerabilities exceed the policy threshold |
| `65` | Configuration error | Policy file or scan configuration is invalid |
| `66` | Database unreachable | Unable to connect to the Safety vulnerability database |

---

## Policy-Controlled Thresholds

The `fail-scan-with-exit-code` section in your policy file controls when exit code `64` is triggered:

```yaml
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
```

To allow the scan to always succeed (for reporting-only pipelines):

```yaml
fail-scan-with-exit-code:
  dependency-vulnerabilities:
    enabled: false
```

---

## Shell Script Examples

### Basic check

```bash
safety scan
EXIT_CODE=$?

case $EXIT_CODE in
  0)  echo "✅ No vulnerabilities found" ;;
  64) echo "❌ Vulnerabilities found — review required"; exit 64 ;;
  65) echo "⚠️  Policy error — check .safety-policy.yml"; exit 65 ;;
  66) echo "⚠️  Database unreachable — check connectivity"; exit 66 ;;
  *)  echo "❌ Unexpected error (exit code: $EXIT_CODE)"; exit $EXIT_CODE ;;
esac
```

### Fail on critical only

Set your policy to only fail on critical:

```yaml
fail-scan-with-exit-code:
  dependency-vulnerabilities:
    enabled: true
    fail-on-any-of:
      cvss-severity:
        - critical
```

```bash
safety scan --policy-file .safety-policy-critical-only.yml || exit $?
```

---

## Makefile Examples

```makefile
scan:
uv run safety scan --detailed-output

scan-ci:
uv run safety --key $(SAFETY_API_KEY) --stage cicd scan \
--policy-file .safety-policy.yml \
--save-as json reports/safety-report.json

scan-strict:
@uv run safety scan --policy-file .safety-policy-strict.yml; \
CODE=$$?; \
if [ $$CODE -eq 64 ]; then \
echo "Vulnerabilities found — check reports/"; \
exit 64; \
fi
```
