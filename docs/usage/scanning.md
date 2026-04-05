# Scanning Options

!!! warning "Safety v3 — `safety check` is deprecated"
    Use `safety scan` for all new workflows. `safety check` is unsupported beyond 1 May 2024.

---

## Primary Command: `safety scan`

```bash
safety [GLOBAL-OPTIONS] scan [OPTIONS]
```

### Global Options

| Flag | Description |
|------|-------------|
| `--stage development` | Label scan as development (default, uses browser auth) |
| `--stage cicd` | Label scan as CI/CD (requires API key) |
| `--stage production` | Label scan as production (requires API key) |
| `--key <api-key>` | API key for CI/CD or production scans |
| `--proxy-host` | Proxy hostname |
| `--proxy-port` | Proxy port |
| `--proxy-protocol` | Proxy protocol (default: https) |

### Scan Options

| Flag | Description |
|------|-------------|
| `--target <path>` | Project directory to scan (default: current directory) |
| `--output <format>` | Output format: `screen`, `json`, `html`, `text`, `spdx` |
| `--detailed-output` | Verbose report (screen output only) |
| `--save-as <format> <file>` | Save results to a file in addition to regular output |
| `--policy-file <path>` | Apply a local v3 policy file |
| `--apply-fixes` | Auto-update requirements.txt files to safe versions |
| `--filter <key>` | Filter JSON output by top-level key |

---

## Common Scan Patterns

### Scan current project directory (dev)
```bash
safety auth login     # one-time setup
safety scan
```

### Scan a specific directory
```bash
safety scan --target /path/to/project
```

### Scan with verbose details
```bash
safety scan --detailed-output
```

### CI/CD scan with API key
```bash
safety --key $SAFETY_API_KEY --stage cicd scan
```

### Save results to JSON
```bash
safety scan --save-as json safety-report.json
```

### Save results to multiple formats
```bash
safety scan \
  --save-as json safety-report.json \
  --output screen
```

### Auto-fix vulnerable requirements.txt
```bash
safety scan --apply-fixes
```

### Scan with a custom policy
```bash
safety scan --policy-file .safety-policy.yml
```

---

## Using `uv run`

If your project uses `uv`, prefix commands with `uv run`:

```bash
uv run safety scan
uv run safety --key $SAFETY_API_KEY --stage cicd scan
```

---

## Legacy: `safety check` (Deprecated)

!!! danger "Deprecated — do not use in new projects"
    `safety check` was removed from active support after 1 May 2024. Migrate to `safety scan`.

    ```bash
    # OLD — deprecated
    safety check -r requirements.txt

    # NEW — Safety v3
    safety scan --target .
    ```
