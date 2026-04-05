# CLI Reference

Safety v2 is built around `safety check` as the primary command.

---

## `safety check`

Scan packages for known vulnerabilities.

```bash
safety check [OPTIONS]
```

| Option | Default | Description |
|--------|---------|-------------|
| `-r <file>` | — | Requirements file to check (repeatable) |
| `--stdin` | off | Read package list from stdin |
| `--full-report` | off | Show full advisory text |
| `--short-report` | off | Show short one-line summary |
| `--bare` | off | Output only vulnerable package names |
| `--json` | off | Output results as JSON array of arrays |
| `--ignore <id>` | — | Ignore a vulnerability ID (repeatable) |
| `--key <api-key>` | — | API key for daily DB updates |
| `--db <path>` | — | Use a local vulnerability database |
| `--cache` | off | Cache the vulnerability database |
| `--policy-file <path>` | — | Apply a local v2 policy file |
| `--proxy-host <host>` | — | HTTP proxy hostname |
| `--proxy-port <port>` | — | HTTP proxy port |
| `--proxy-protocol <proto>` | https | Proxy protocol |

### Examples

```bash
# Scan installed packages
safety check

# Scan a requirements file
safety check -r requirements.txt

# Scan from pip freeze
pip freeze | safety check --stdin

# Full report
safety check --full-report -r requirements.txt

# CI/CD with API key and JSON output
safety check --key $SAFETY_API_KEY --json -r requirements.txt > report.json

# Ignore a CVE
safety check --ignore 36546 -r requirements.txt

# Use a policy file
safety check --policy-file .safety-policy.yml -r requirements.txt

# Use local database
safety check --db /path/to/safety-db -r requirements.txt

# Cache database for faster repeated runs
safety check --cache -r requirements.txt
```

---

## `safety generate`

```bash
# Generate a default v2 policy file
safety generate policy_file
```

---

## `safety review`

```bash
# Review a saved JSON report
safety review --file reports/safety-report.json
```

---

## `safety alert` (Deprecated)

```bash
# alert is deprecated — use Safety integrations instead
safety alert
```

---

## Commands that do NOT exist in v2

| Command | Note |
|---------|------|
| `safety scan` | v3 only |
| `safety auth` | v3 only — v2 uses API keys |
| `safety validate` | v3 only |
| `safety configure` | v3 only |

---

## `safety check-updates`

Check if a newer version of Safety CLI is available:

```bash
safety check-updates
```
