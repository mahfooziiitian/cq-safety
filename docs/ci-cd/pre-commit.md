# Pre-commit Hook

Run Safety automatically before each commit to catch vulnerabilities early.

!!! note
    This hook calls `safety scan` directly. Do **not** use the `Lucas-C/pre-commit-hooks-safety` hook — it uses the deprecated `safety check` command.

---

## Setup

### 1. Install pre-commit

```bash
pip install pre-commit
# or
uv add --dev pre-commit
```

### 2. Add to `.pre-commit-config.yaml`

```yaml
repos:
  - repo: local
    hooks:
      - id: safety-scan
        name: Safety vulnerability scan
        entry: safety scan
        language: system
        pass_filenames: false
        stages: [pre-commit]
```

### 3. Install the hooks

```bash
pre-commit install
```

Now `safety scan` runs automatically before each commit.

---

## With uv

If your project uses uv, use `uv run` in the entry:

```yaml
repos:
  - repo: local
    hooks:
      - id: safety-scan
        name: Safety vulnerability scan
        entry: uv run safety scan
        language: system
        pass_filenames: false
        stages: [pre-commit]
```

---

## CI Variant (with API Key)

For CI environments where `safety auth login` is not available, use the API key:

```yaml
repos:
  - repo: local
    hooks:
      - id: safety-scan
        name: Safety vulnerability scan
        entry: bash -c 'uv run safety --key "$SAFETY_API_KEY" --stage cicd scan'
        language: system
        pass_filenames: false
```

Set `SAFETY_API_KEY` in your CI environment variables.

---

## Skip the Hook

To skip Safety for a specific commit:

```bash
SKIP=safety-scan git commit -m "chore: update docs"
```

Or to skip all hooks:

```bash
git commit --no-verify -m "emergency fix"
```

---

## Run Manually

```bash
# Run all hooks on all files
pre-commit run --all-files

# Run only the safety hook
pre-commit run safety-scan --all-files
```
