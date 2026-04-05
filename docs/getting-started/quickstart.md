# Quickstart

Get up and running with Safety CLI 3 in five steps.

---

## Step 1 — Authenticate

```bash
safety auth login
```

This opens a browser tab to [platform.safetycli.com](https://platform.safetycli.com). Log in with your account. The CLI stores a local token.

```bash
# Verify authentication succeeded
safety auth status
```

---

## Step 2 — Run Your First Scan

```bash
safety scan
```

Safety inventories all packages in the current Python environment and checks them against the Safety Vulnerability Database.

---

## Step 3 — Detailed Output

```bash
safety scan --detailed-output
```

Shows the full description, CVE IDs, CVSS scores, affected versions, and fix recommendations for each finding.

---

## Step 4 — Read the Output

The scan output shows:

- **Package name** and installed version
- **Vulnerability ID** (CVE or Safety ID)
- **CVSS severity** (critical / high / medium / low / info)
- **Fixed version** (the minimum safe version)
- **Description** (with `--detailed-output`)

**Exit codes:**

| Code | Meaning |
|------|---------|
| `0` | No actionable vulnerabilities |
| `64` | Vulnerabilities found above policy threshold |
| `65` | Configuration or policy error |
| `66` | Database unreachable |

---

## Step 5 — Auto-Fix or Manual Fix

### Auto-fix (recommended for patch updates)

```bash
safety scan --apply-fixes
```

Safety updates `pyproject.toml` or `requirements.txt` to the minimum safe version. Then regenerate your lock file:

```bash
uv lock
# or
pip-compile
```

### Manual fix

Update the vulnerable package in your dependency file and regenerate the lock:

```bash
uv add "somepackage>=2.1.0"
uv lock
```

Review and commit the changes.
