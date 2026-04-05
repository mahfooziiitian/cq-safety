# Installation

## Requirements

- Python **3.6+** (3.11+ recommended)
- `pip` or `uv`

---

## Install Safety

=== "pip"

    ```bash
    pip install safety
    ```

=== "uv (recommended)"

    ```bash
    # Add as a dev dependency
    uv add --dev safety

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
# safety, version 3.x.x
```

---

## API Key (Optional)

The free tier uses the open-source Safety DB, updated **monthly**. For daily-updated CVE coverage, get a free API key:

1. Sign up at [pyup.io](https://pyup.io/account/api-key/)
2. Export the key in your shell or CI environment:

```bash
export SAFETY_API_KEY=your-key-here
```

!!! tip
    Store the key as a repository secret (`SAFETY_API_KEY`) in GitHub or GitLab — never commit it to source control.
