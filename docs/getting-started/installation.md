# Installation

## Requirements

- Python **3.7+** (3.11+ recommended)
- `pip` or `uv`

---

## Install Safety CLI 3

=== "pip"

    ```bash
    pip install "safety>=3.0"
    ```

=== "uv (recommended)"

    ```bash
    # Add as a dev dependency
    uv add --dev "safety>=3.0"

    # Sync the environment
    uv sync
    ```

=== "pipx (global tool)"

    ```bash
    pipx install safety
    ```

---

## Verify Installation

```bash
safety --version
# safety, version 3.7.x
```

---

## Authentication

Safety v3 introduces two authentication modes:

### Development (browser-based OAuth)

For local development, authenticate once with your Safety Platform account:

```bash
safety auth login
# Opens https://platform.safetycli.com in your browser

# Check status
safety auth status

# Log out
safety auth logout
```

Register for a free account at [platform.safetycli.com](https://platform.safetycli.com).

### CI/CD (API key)

For automated pipelines, use an API key passed as a global flag or environment variable:

```bash
# Environment variable (recommended)
export SAFETY_API_KEY=your-key-here

# Or pass directly
safety --key your-key-here --stage cicd scan
```

!!! tip
    Store the key as a repository secret (`SAFETY_API_KEY`) in GitHub or GitLab — never commit it to source control.

---

## Lifecycle Stages

Safety v3 introduces a `--stage` global flag to label scans:

| Stage | Use Case | Auth Required |
|---|---|---|
| `development` | Local dev (default) | `safety auth login` |
| `cicd` | CI/CD pipelines | `--key` or `SAFETY_API_KEY` |
| `production` | Production systems | `--key` or `SAFETY_API_KEY` |

```bash
# Development scan (uses browser auth)
safety scan

# CI/CD scan (uses API key)
safety --key $SAFETY_API_KEY --stage cicd scan

# Production scan
safety --key $SAFETY_API_KEY --stage production scan
```
