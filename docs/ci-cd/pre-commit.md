# Pre-commit Hook

Run Safety automatically before every commit to catch vulnerabilities early.

!!! note "Safety v3 and pre-commit"
    The `Lucas-C/pre-commit-hooks-safety` hook still invokes `safety check` (legacy). For Safety v3, use a local hook that calls `safety scan` directly.

---

## Setup with Local Hook (Recommended for Safety v3)

### 1. Install pre-commit

```bash
pip install pre-commit
# or with uv:
uv add --dev pre-commit
```

### 2. Add a local Safety v3 hook to `.pre-commit-config.yaml`

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: safety-scan
        name: Safety vulnerability scan
        language: system
        entry: safety
        args: ["scan", "--detailed-output"]
        pass_filenames: false
        always_run: true
```

### 3. Install the hooks

```bash
pre-commit install
```

---

## CI/CD Stage in Pre-commit (API key)

If running in a CI environment with an API key:

```yaml
repos:
  - repo: local
    hooks:
      - id: safety-scan
        name: Safety vulnerability scan
        language: system
        entry: bash
        args:
          - -c
          - 'safety --key "${SAFETY_API_KEY}" --stage cicd scan --policy-file .safety-policy.yml'
        pass_filenames: false
        always_run: true
```

---

## Running Manually

```bash
# Run Safety hook on all files
pre-commit run safety-scan --all-files

# Run all hooks
pre-commit run --all-files
```

---

## Skipping the Hook (Emergency)

```bash
# Skip all hooks for one commit (use sparingly)
git commit --no-verify -m "emergency fix"
```

!!! warning
    Skipping hooks bypasses your security gate. Always follow up with a tracked issue.

---

## Legacy Hook (Safety v2 — not recommended)

```yaml
# Only use if you are pinned to safety<3.0
repos:
  - repo: https://github.com/Lucas-C/pre-commit-hooks-safety
    rev: v1.3.3
    hooks:
      - id: python-safety-dependencies-check
        args: ["--short-report"]
```
