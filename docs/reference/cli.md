# CLI Reference

## `safety check`

Scan packages for known security vulnerabilities.

```
safety check [OPTIONS]
```

### Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `-r, --file` | path | — | Requirements file to scan (repeatable) |
| `--stdin` | flag | off | Read packages from stdin |
| `--key` | string | — | Safety API key |
| `--db` | path | — | Path to a local Safety DB |
| `--ignore` | integer | — | Vulnerability ID to ignore (repeatable) |
| `--policy-file` | path | — | Path to `.safety-policy.yml` |
| `--full-report` | flag | off | Show full advisory text |
| `--short-report` | flag | off | Show condensed one-line summary |
| `--json` | flag | off | Output in JSON format |
| `--bare` | flag | off | Output only package names |
| `--cache` | flag | off | Cache the DB locally |
| `--proxyhost` | string | — | HTTP proxy hostname |
| `--proxyport` | integer | — | HTTP proxy port |
| `--proxyprotocol` | string | `http` | HTTP proxy protocol |

---

## `safety generate policy_file`

Generate a default `.safety-policy.yml` in the current directory.

```bash
safety generate policy_file
```

---

## `safety review`

Review a previously generated JSON report file.

```bash
safety review --file safety-report.json
safety review --file safety-report.json --full-report
```

---

## Global Options

| Option | Description |
|--------|-------------|
| `--version` | Show version and exit |
| `--help` | Show help and exit |
