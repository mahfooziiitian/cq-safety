# Scanning

## Global Flags

These flags apply to all Safety commands:

| Flag | Description |
|------|-------------|
| `--key KEY` | API key for authentication (CI/CD) |
| `--stage STAGE` | Lifecycle stage: `development`, `cicd`, `production` |
| `--proxy-host HOST` | Proxy hostname |
| `--proxy-port PORT` | Proxy port |
| `--proxy-protocol PROTO` | Proxy protocol (`http` or `https`) |

---

## `safety scan` Options

```bash
safety scan [OPTIONS]
```

| Option | Type | Description |
|--------|------|-------------|
| `--target PATH` | path | Directory to scan (default: current environment) |
| `--output FORMAT` | choice | Output format: `screen`, `json`, `html`, `text`, `spdx` |
| `--detailed-output` | flag | Show full vulnerability details |
| `--save-as FORMAT FILE` | pair | Save report to file (repeatable) |
| `--policy-file PATH` | path | Policy file path (default: `.safety-policy.yml`) |
| `--apply-fixes` | flag | Automatically apply safe version upgrades |
| `--filter` | option | Filter results by severity or status |

---

## Common Patterns

### Basic developer scan

```bash
safety scan --detailed-output
```

### Save JSON and HTML reports

```bash
safety scan \
  --save-as json reports/safety.json \
  --save-as html reports/safety.html \
  --output screen
```

### Scan a specific directory

```bash
safety scan --target /path/to/project --detailed-output
```

### CI/CD scan with API key

```bash
safety --key $SAFETY_API_KEY --stage cicd scan \
  --policy-file .safety-policy.yml \
  --save-as json reports/safety-report.json
```

### Use a custom policy file

```bash
safety scan --policy-file policies/strict.yml
```

### Scan and apply fixes

```bash
safety scan --apply-fixes
```

---

## Scanning with uv

When using [uv](https://docs.astral.sh/uv/), prefix Safety commands with `uv run`:

```bash
uv run safety scan --detailed-output
uv run safety --key $SAFETY_API_KEY --stage cicd scan
```

---

!!! warning "Deprecated: `safety check`"
    `safety check` was the v2 scanning command. It is **deprecated in Safety CLI 3** and will be removed in a future release.

    | Old (v2) | New (v3) |
    |----------|----------|
    | `safety check` | `safety scan` |
    | `safety check -r requirements.txt` | `safety scan --target .` |
    | `safety check --ignore CVE-xxx` | Policy file `installation.allow.vulnerabilities` |

    Always use `safety scan` in new code.
