# Troubleshooting

## Authentication Errors

### Development

**Symptom:** `AuthenticationError: Not authenticated`

**Fix:** Run the browser login flow:

```bash
safety auth login
safety auth status
```

If the browser doesn't open, use headless mode:

```bash
safety auth login --headless
```

---

### CI/CD

**Symptom:** `AuthenticationError` in CI pipeline

**Fix:** Verify `SAFETY_API_KEY` is set and valid:

```bash
echo $SAFETY_API_KEY   # Should print the key
```

Ensure you pass it correctly:

```bash
safety --key "$SAFETY_API_KEY" --stage cicd scan
```

Check the key is active at [platform.safetycli.com](https://platform.safetycli.com).

---

## No Packages Found

**Symptom:** `No packages were found` or empty scan results

**Fix:** Point Safety at your project directory:

```bash
safety scan --target .
safety scan --target /path/to/project
```

Ensure you're in the correct Python environment (activated venv or uv shell).

---

## Database Unreachable

**Symptom:** `Exit code 66` — unable to fetch vulnerability database

**Fix:** Configure proxy settings:

```bash
safety configure \
  --proxy-host proxy.example.com \
  --proxy-port 8080 \
  --proxy-protocol http
```

Or set environment variables:

```bash
export HTTP_PROXY=http://proxy.example.com:8080
export HTTPS_PROXY=http://proxy.example.com:8080
safety scan
```

---

## Policy Validation Errors

**Symptom:** `PolicyValidationError` or unexpected scan behaviour

**Fix:** Validate your policy file:

```bash
safety validate policy_file
```

Common issues:
- Missing `version: '3.0'` at the top of the file
- Using v2 keys like `ignore-cvss-severity-below` (use `auto-ignore-in-report.cvss-severity` instead)
- YAML indentation errors

---

## Slow CI Scans

**Symptom:** Safety scan takes a long time in CI

**Fix:** Cache uv's download cache between CI runs.

**GitHub Actions:**

```yaml
- uses: astral-sh/setup-uv@v4
  with:
    version: "latest"
    enable-cache: true
    cache-dependency-glob: "uv.lock"
```

**GitLab CI:**

```yaml
cache:
  key: uv-$CI_COMMIT_REF_SLUG
  paths:
    - .uv/
variables:
  UV_CACHE_DIR: .uv
```

---

## Auto-Fix Limitations

**Symptom:** `--apply-fixes` does not update a vulnerable package

**Causes:**
- No safe version exists within the allowed update range (patch-only by default)
- The package is pinned to an exact version in a lock file
- The fix requires a major version bump (not allowed by default)

**Fix:** Relax the auto-fix limit in your policy:

```yaml
security-updates:
  dependency-vulnerabilities:
    auto-security-updates-limit:
      - patch
      - minor
```

Or manually update the package:

```bash
uv add "somepackage>=2.1.0"
uv lock
```

---

## `safety check` Not Working

**Symptom:** Old `safety check` command produces errors or unexpected output

**Fix:** `safety check` is deprecated in Safety CLI 3. Use `safety scan` instead:

```bash
# Old (deprecated)
safety check

# New (v3)
safety scan
```

See the [CLI Reference](cli.md) for all v3 commands.
