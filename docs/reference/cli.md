# CLI Reference

Safety v3 is built around `safety scan` as the primary command.

---

## Global Options

These apply before any subcommand:

```bash
safety [GLOBAL-OPTIONS] COMMAND [OPTIONS]
```

| Option | Description |
|--------|-------------|
| `--stage <stage>` | Lifecycle stage: `development` (default), `cicd`, `production` |
| `--key <api-key>` | API key (required for `cicd` and `production` stages) |
| `--proxy-host` | HTTP proxy hostname |
| `--proxy-port` | HTTP proxy port |
| `--proxy-protocol` | Proxy protocol (`https` default) |
| `--version` | Show version and exit |
| `--help` | Show help and exit |

---

## `safety scan`

Scan a Python project directory for vulnerable dependencies.

```bash
safety [GLOBAL-OPTIONS] scan [OPTIONS]
```

| Option | Default | Description |
|--------|---------|-------------|
| `--target <path>` | `.` (current dir) | Project directory to scan |
| `--output <format>` | `screen` | Output format: `screen`, `json`, `html`, `text`, `spdx` |
| `--detailed-output` | off | Verbose screen report |
| `--save-as <format> <file>` | — | Save results to a file (repeatable) |
| `--policy-file <path>` | — | Local v3 policy file |
| `--apply-fixes` | off | Auto-update requirements.txt to safe versions |
| `--filter <key>` | — | Filter JSON output by top-level key |

### Examples

```bash
# Scan current directory (dev auth)
safety scan

# Scan with verbose output
safety scan --detailed-output

# Scan a specific target
safety scan --target /path/to/project

# Scan for CI/CD with JSON output saved to file
safety --key $SAFETY_API_KEY --stage cicd scan --save-as json report.json

# Scan with policy and auto-fix
safety scan --policy-file .safety-policy.yml --apply-fixes
```

---

## `safety auth`

Manage browser-based authentication for development scans.

| Subcommand | Description |
|------------|-------------|
| `safety auth login` | Open browser to authenticate |
| `safety auth login --headless` | Print a URL for headless environments |
| `safety auth logout` | Log out of the current session |
| `safety auth status` | Show current authentication status |
| `safety auth register` | Create a new Safety Platform account |

---

## `safety generate`

```bash
# Generate a default v3 policy file
safety generate policy_file
```

---

## `safety validate`

```bash
# Validate the default .safety-policy.yml
safety validate policy_file

# Validate a policy file at a specific path
safety validate policy_file --path /path/to/.safety-policy.yml
```

---

## `safety configure`

Set global proxy and organization settings:

```bash
safety configure --proxy-host 192.168.0.1 --proxy-port 8080 --proxy-protocol https
```

---

## `safety check-updates`

Check if a newer version of Safety CLI is available:

```bash
safety check-updates
```

---

## Deprecated Commands

| Command | Status | Replacement |
|---------|--------|-------------|
| `safety check` | ❌ Deprecated (unsupported after 1 May 2024) | `safety scan` |
| `safety license` | ❌ Deprecated | `safety scan` |
| `safety alert` | ❌ Deprecated | Safety Platform integrations |

---

## Beta Commands

| Command | Description |
|---------|-------------|
| `safety codebase init` | Initialize a Safety Codebase integration |
| `safety firewall` | Manage Safety Firewall package blocking |
