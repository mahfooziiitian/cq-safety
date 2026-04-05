# Troubleshooting

## No Active Virtual Environment

Safety v2 scans the **currently installed packages** by default (no `-r` flag). If the wrong environment is active, you'll get incorrect results.

Ensure the correct virtual environment is activated:

```bash
source .venv/bin/activate
safety check
```

Or scan a requirements file explicitly:

```bash
safety check -r requirements.txt
```

---

## "Unable to load vulnerability database"

Safety cannot reach the remote database.

**Use cached database:**
```bash
safety check --cache -r requirements.txt
```

**Use a local database:**
```bash
safety check --db /path/to/safety-db -r requirements.txt
```

**Check internet access:**
```bash
curl -I https://pyup.io
```

**Use a proxy:**
```bash
safety check --proxy-host 192.168.0.1 --proxy-port 8080 -r requirements.txt
```

---

## False Positives (`--ignore`)

If Safety flags a CVE that is not exploitable in your context:

```bash
# Ignore via CLI flag
safety check --ignore 36546 -r requirements.txt

# Or add to policy file
```

```yaml
# .safety-policy.yml
version: "2.0"
security:
  ignore-vulnerabilities:
    36546:
      reason: "Not exploitable in our deployment"
      expires: "2025-06-30"
```

---

## Slow CI Scans

Cache the Safety vulnerability database between runs:

```bash
safety check --cache -r requirements.txt
```

In GitHub Actions:

```yaml
- name: Cache Safety data
  uses: actions/cache@v4
  with:
    path: ~/.safety
    key: safety-${{ runner.os }}-${{ hashFiles('**/requirements*.txt') }}

- name: Run Safety check
  run: safety check --cache -r requirements.txt
```

---

## Wrong Environment Being Scanned

Pass the requirements file explicitly to control exactly what is scanned:

```bash
safety check -r requirements.txt
safety check -r requirements-prod.txt
```

---

## API Key Not Working

- Verify the key is correct at [pyup.io/account/api-key/](https://pyup.io/account/api-key/)
- Ensure `SAFETY_API_KEY` is exported in the shell
- Pass it directly: `safety check --key your-key-here -r requirements.txt`

---

## Getting Help

```bash
safety --help
safety check --help
```

- [Safety v2 documentation](https://pyup.io/safety/)
- [Safety GitHub Issues](https://github.com/pyupio/safety/issues)
