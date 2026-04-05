# Troubleshooting

## Authentication Errors

### "Not authenticated" in development

```bash
# Log in once using browser auth
safety auth login

# Verify status
safety auth status
```

For headless environments (remote SSH, Docker):

```bash
safety auth login --headless
# Prints a URL — paste it into a browser on another machine
```

### "API key required" in CI/CD

The `cicd` and `production` stages require `--key` or `SAFETY_API_KEY`:

```bash
export SAFETY_API_KEY=your-key-here
safety --key $SAFETY_API_KEY --stage cicd scan
```

Get an API key from [platform.safetycli.com](https://platform.safetycli.com).

---

## "No packages found in environment"

Safety v3 scans the **project directory** (not just the active environment). Make sure you're pointing at the right path:

```bash
safety scan --target /path/to/project
```

If no dependency files are found, add them explicitly via the policy file:

```yaml
scanning-settings:
  include-files:
    - requirements-prod.txt
```

---

## "Unable to load vulnerability database"

Safety cannot reach the remote database.

**Check internet access:**
```bash
curl -I https://platform.safetycli.com
```

**Use a proxy:**
```bash
safety configure --proxy-host 192.168.0.1 --proxy-port 8080
safety --stage cicd scan
```

---

## Policy File Validation Errors

If `safety scan` fails with a policy error:

```bash
# Validate the policy file before scanning
safety validate policy_file

# Or validate a file at a specific path
safety validate policy_file --path .safety-policy.yml
```

Common issues:
- Using old **v2 schema** (`version: "2.0"`) — regenerate with `safety generate policy_file`
- Incorrect indentation in YAML
- Invalid CVE ID format in `allow.vulnerabilities`

---

## Scan is Slow in CI

Cache Safety's data between runs in GitHub Actions:

```yaml
- name: Cache Safety data
  uses: actions/cache@v4
  with:
    path: ~/.safety
    key: safety-${{ runner.os }}-${{ hashFiles('**/requirements*.txt') }}
```

---

## Wrong Python Environment Scanned

Safety v3 scans the project directory, not an environment. If you want to restrict the scan to a specific requirements file, set `include-files` in your policy:

```yaml
scanning-settings:
  include-files:
    - requirements.txt
  exclude:
    - tests/
```

---

## Auto-Fix Didn't Work

`--apply-fixes` only supports `requirements.txt` files. It will not modify:

- `pyproject.toml`
- `Pipfile` / `Pipfile.lock`
- `setup.cfg` / `setup.py`

For those, update manually:

```bash
# pip
pip install --upgrade <package>

# uv
uv add "<package>>=<safe-version>"
```

---

## Getting Help

```bash
safety --help
safety scan --help
safety auth --help
```

- [Safety CLI 3 documentation](https://docs.safetycli.com)
- [Safety Platform](https://platform.safetycli.com)
- [Safety GitHub Issues](https://github.com/pyupio/safety/issues)
- Support: support@safetycli.com
