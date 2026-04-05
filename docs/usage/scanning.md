# Scanning Options

## Primary Command: `safety check`

```bash
safety check [OPTIONS]
```

---

## Full Flag Reference

| Flag | Description |
|------|-------------|
| `-r <file>` | Check packages listed in a requirements file (repeatable) |
| `--stdin` | Read package list from stdin (e.g., `pip freeze | safety check --stdin`) |
| `--full-report` | Show full advisory text for each vulnerability |
| `--short-report` | Show a short, one-line summary per vulnerability |
| `--bare` | Output only vulnerable package names (one per line) |
| `--json` | Output results in JSON format (array of arrays) |
| `--ignore <id>` | Ignore a vulnerability by ID (repeatable) |
| `--key <api-key>` | API key for daily DB updates |
| `--db <path>` | Use a local vulnerability database directory |
| `--cache` | Cache the vulnerability database locally (speeds up CI) |
| `--policy-file <path>` | Apply a local v2 policy file |
| `--proxy-host <host>` | HTTP proxy hostname |
| `--proxy-port <port>` | HTTP proxy port |
| `--proxy-protocol <proto>` | Proxy protocol (default: https) |

---

## Common Scan Patterns

### Scan installed packages
```bash
safety check
```

### Scan a requirements file
```bash
safety check -r requirements.txt
```

### Scan multiple files
```bash
safety check -r requirements.txt -r requirements-dev.txt
```

### Scan from pip freeze
```bash
pip freeze | safety check --stdin
```

### Full report with advisory text
```bash
safety check --full-report -r requirements.txt
```

### CI/CD scan with API key
```bash
safety check --key $SAFETY_API_KEY -r requirements.txt
```

### JSON output
```bash
safety check --json -r requirements.txt
```

### Ignore a specific CVE
```bash
safety check --ignore 36546 -r requirements.txt
```

### Use a local vulnerability database
```bash
safety check --db /path/to/safety-db -r requirements.txt
```

### Cache the database for faster CI
```bash
safety check --cache -r requirements.txt
```

### Scan with a policy file
```bash
safety check --policy-file .safety-policy.yml -r requirements.txt
```

---

## Using `uv run`

If your project uses `uv`, prefix commands with `uv run`:

```bash
uv run safety check -r requirements.txt
uv run safety check --key $SAFETY_API_KEY --json -r requirements.txt
```
