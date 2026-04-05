# Installation

## Install Safety CLI 3

```bash
# pip
pip install safety

# uv (recommended for modern Python projects)
uv add --dev safety

# pipx (isolated global install)
pipx install safety

# Verify installation
safety --version
```

---

## Authentication

Safety CLI 3 requires authentication to access the vulnerability database. There are two modes:

### Development — Browser Login

```bash
safety auth login
```

This opens [platform.safetycli.com](https://platform.safetycli.com) in a browser. Sign in and the CLI stores a local token.

```bash
# Headless (SSH sessions, no browser available)
safety auth login --headless

# Check auth status
safety auth status

# Logout
safety auth logout
```

### CI/CD — API Key

Create an API key at [platform.safetycli.com](https://platform.safetycli.com) under **Settings → API Keys**.

Store the key as a secret named `SAFETY_API_KEY` in your CI/CD system, then pass it via:

```bash
safety --key $SAFETY_API_KEY --stage cicd scan
```

---

## Lifecycle Stages

The `--stage` flag tells Safety what context the scan is running in, adjusting output verbosity and reporting behaviour:

| Stage | Flag | Use Case |
|-------|------|----------|
| `development` | `--stage development` | Local developer scans |
| `cicd` | `--stage cicd` | Automated CI/CD pipelines |
| `production` | `--stage production` | Production environment scans |

The `development` stage is the default when using `safety auth login`. CI/CD pipelines should always use `--stage cicd`.
