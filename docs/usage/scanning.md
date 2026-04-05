# Scanning Options

## Flag Reference

| Flag | Description |
|------|-------------|
| `-r <file>` | Scan a requirements file |
| `--stdin` | Read package list from stdin |
| `--key <api-key>` | Use a commercial Safety API key |
| `--db <path>` | Use a local Safety DB snapshot (offline) |
| `--ignore <id>` | Ignore a specific vulnerability ID |
| `--policy-file <path>` | Apply a YAML policy file |
| `--full-report` | Show full advisory text per vulnerability |
| `--short-report` | One-line summary per vulnerability |
| `--cache` | Cache the DB locally for faster repeated scans |
| `--json` | Output in JSON format |
| `--bare` | Output only vulnerable package names |
| `--proxyhost` / `--proxyport` | Route through an HTTP proxy |

---

## Common Scan Patterns

### Active environment
```bash
safety check
```

### Single requirements file
```bash
safety check -r requirements.txt
```

### Multiple requirement files
```bash
safety check -r requirements.txt -r requirements-dev.txt
```

### Stdin (from pip freeze)
```bash
pip freeze | safety check --stdin
```

### Full advisory details
```bash
safety check --full-report -r requirements.txt
```

### Offline with local DB
```bash
safety check --db /path/to/safety-db -r requirements.txt
```

### Faster CI scans (with cache)
```bash
safety check --cache -r requirements.txt
```

---

## Using `uv run`

If your project uses `uv`, prefix commands with `uv run`:

```bash
uv run safety check -r requirements.txt
```
