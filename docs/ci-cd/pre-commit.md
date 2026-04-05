# Pre-commit Hook

Run Safety automatically before every commit to catch vulnerabilities early.

---

## Setup with `Lucas-C/pre-commit-hooks-safety` (Recommended for Safety v2)

### 1. Install pre-commit

```bash
pip install pre-commit
# or with uv:
uv add --dev pre-commit
```

### 2. Add the Safety hook to `.pre-commit-config.yaml`

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/Lucas-C/pre-commit-hooks-safety
    rev: v1.3.3
    hooks:
      - id: python-safety-dependencies-check
        args: ["--short-report"]
```

### 3. Install the hooks

```bash
pre-commit install
```

---

## Running Manually

```bash
# Run Safety hook on all files
pre-commit run python-safety-dependencies-check --all-files

# Run all hooks
pre-commit run --all-files
```

---

## With Policy File Args

Pass extra arguments to `safety check` via the `args` list:

```yaml
repos:
  - repo: https://github.com/Lucas-C/pre-commit-hooks-safety
    rev: v1.3.3
    hooks:
      - id: python-safety-dependencies-check
        args: ["--policy-file", ".safety-policy.yml", "--full-report"]
```

---

## With API Key (CI environments)

```yaml
repos:
  - repo: https://github.com/Lucas-C/pre-commit-hooks-safety
    rev: v1.3.3
    hooks:
      - id: python-safety-dependencies-check
        args: ["--key", "${SAFETY_API_KEY}", "--short-report"]
```

---

## Skipping the Hook (Emergency)

```bash
# Skip all hooks for one commit (use sparingly)
git commit --no-verify -m "emergency fix"

# Skip only the safety hook
SKIP=python-safety-dependencies-check git commit -m "emergency fix"
```

!!! warning
    Skipping hooks bypasses your security gate. Always follow up with a tracked issue.
