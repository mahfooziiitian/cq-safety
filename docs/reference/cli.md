# CLI Reference

## Global Options

These options apply to all Safety commands:

| Option | Description |
|--------|-------------|
| `--key KEY` | API key for authentication |
| `--stage STAGE` | Lifecycle stage: `development`, `cicd`, `production` |
| `--proxy-host HOST` | Proxy hostname |
| `--proxy-port PORT` | Proxy port |
| `--proxy-protocol PROTO` | Proxy protocol (`http` or `https`) |
| `--version` | Show version and exit |
| `--help` | Show help and exit |

---

## `safety scan`

Scan Python packages for known vulnerabilities.

```bash
safety scan [OPTIONS]
```

| Option | Description |
|--------|-------------|
| `--target PATH` | Directory to scan (default: current environment) |
| `--output FORMAT` | Output format: `screen`, `json`, `html`, `text`, `spdx` |
| `--detailed-output` | Show full vulnerability details |
| `--save-as FORMAT FILE` | Save report to file (repeatable) |
| `--policy-file PATH` | Path to policy file (default: `.safety-policy.yml`) |
| `--apply-fixes` | Automatically apply safe version upgrades |
| `--filter` | Filter results |
| `--help` | Show help and exit |

### Examples

```bash
safety scan
safety scan --detailed-output
safety scan --target ./src --output json
safety scan --save-as json report.json --save-as html report.html
safety --key $SAFETY_API_KEY --stage cicd scan --policy-file .safety-policy.yml
```

---

## `safety auth`

Manage authentication with the Safety Platform.

### `safety auth login`

```bash
safety auth login [--headless]
```

Opens a browser to [platform.safetycli.com](https://platform.safetycli.com) for login. Use `--headless` in SSH sessions.

### `safety auth logout`

```bash
safety auth logout
```

Removes the stored authentication token.

### `safety auth status`

```bash
safety auth status
```

Shows the current authentication status and token expiry.

### `safety auth register`

```bash
safety auth register
```

Create a new Safety Platform account from the CLI.

---

## `safety generate`

Generate configuration files.

```bash
safety generate policy_file
```

Creates a default `.safety-policy.yml` in the current directory.

---

## `safety validate`

Validate configuration files.

```bash
safety validate policy_file
```

Validates `.safety-policy.yml` against the v3 schema.

---

## `safety configure`

Configure Safety CLI settings.

```bash
safety configure --proxy-host proxy.example.com --proxy-port 8080
safety configure --proxy-host proxy.example.com --proxy-protocol https
```

---

## `safety check-updates`

Check if a newer version of Safety CLI is available.

```bash
safety check-updates
```

---

## Beta Commands

| Command | Description |
|---------|-------------|
| `safety codebase` | Scan source code for security issues (beta) |
| `safety firewall` | Package firewall — block malicious packages at install time (beta) |

---

## Deprecated Commands

| Command | Status | Replacement |
|---------|--------|-------------|
| `safety check` | Deprecated | `safety scan` |
| `safety check -r requirements.txt` | Deprecated | `safety scan --target .` |
| `safety check --ignore CVE-xxx` | Deprecated | Policy file `installation.allow.vulnerabilities` |
| `safety license` | Deprecated | `safety scan --output spdx` |
| `safety alert` | Deprecated | Platform alerts at platform.safetycli.com |
