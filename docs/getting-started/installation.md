# Installation

## Requirements

- Python **3.7+** (3.11+ recommended)
- `pip` or `uv`

---

## Install Safety v2

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
# safety, version 2.x.x
```

---

## API Key Setup

Safety v2 uses an API key for CI/CD access and to unlock daily database updates.

### Get an API Key

Register for a free account and get your API key at [pyup.io/account/api-key/](https://pyup.io/account/api-key/).

- **Free tier**: database updated monthly
- **Commercial tier**: database updated daily

### Configure the API Key

```bash
# Set as environment variable (recommended)
export SAFETY_API_KEY=your-key-here

# Or pass directly on the command line
safety check --key your-key-here -r requirements.txt
```

!!! tip
    Store the key as a repository secret (`SAFETY_API_KEY`) in GitHub or GitLab — never commit it to source control.

---

## No Browser Login

Safety v2 does **not** use browser-based authentication. Authentication is via API key only.
