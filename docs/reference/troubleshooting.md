# Troubleshooting

## "No packages found in environment"

You may be running Safety outside a virtual environment.

```bash
# Activate your virtual environment first
source .venv/bin/activate
safety check

# Or scan a requirements file directly (no active env needed)
safety check -r requirements.txt
```

---

## "Unable to load vulnerability database"

Safety cannot reach the remote database.

**Check internet access:**
```bash
curl -I https://pyup.io
```

**Use a cached local copy:**
```bash
# First run (online) — cache the DB
safety check --cache -r requirements.txt

# Subsequent runs — use the cache
safety check --cache -r requirements.txt
```

**Use a local DB snapshot (fully offline):**
```bash
safety check --db /path/to/local-safety-db -r requirements.txt
```

---

## Scan Returns False Positives

A vulnerability may not apply to your deployment context.

1. Note the vulnerability ID from the report (e.g., `36546`)
2. Add it to your policy file with a reason and expiry:

```yaml
security:
  ignore-vulnerabilities:
    36546:
      reason: "Not reachable — our app does not follow HTTP redirects"
      expires: "2025-06-30"
```

3. Re-run with the policy file:

```bash
safety check --policy-file .safety-policy.yml -r requirements.txt
```

---

## Safety is Slow in CI

Enable local caching to avoid re-fetching the database on every run:

```bash
safety check --cache -r requirements.txt
```

In GitHub Actions, cache the Safety DB between runs:

```yaml
- name: Cache Safety DB
  uses: actions/cache@v4
  with:
    path: ~/.safety
    key: safety-db-${{ runner.os }}-${{ hashFiles('requirements.txt') }}

- name: Run Safety check
  run: safety check --cache -r requirements.txt
```

---

## Wrong Python Environment Scanned

Safety scans the Python environment it is installed in. If you have multiple environments:

```bash
# Use the explicit venv Python
.venv/bin/safety check

# Or with uv
uv run safety check
```

---

## Getting Help

```bash
safety --help
safety check --help
```

- [Safety documentation](https://docs.pyup.io/docs/safety-2-cli-commands-and-options)
- [Safety GitHub Issues](https://github.com/pyupio/safety/issues)
