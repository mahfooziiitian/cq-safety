# GitHub Copilot Instructions — cq-safety

## Project Overview

This repository is a **Python code-quality project** focused on the [Safety](https://pyup.io/safety/) dependency vulnerability scanner. It provides:

- A tutorial and reference guide (`README.md`) for using Safety to detect CVEs in Python packages
- A `pyproject.toml`-managed project using [uv](https://docs.astral.sh/uv/) with Safety ≥ 3.7.0 as a dev dependency

**Purpose:** Teach developers how to integrate `safety check` into their Python projects and CI/CD pipelines to catch known security vulnerabilities in third-party packages.

---

## Tech Stack

| Layer | Tool |
|---|---|
| Language | Python ≥ 3.11 |
| Package manager | `uv` (see `uv.lock`) |
| Security scanner | `safety` ≥ 3.7.0 |
| Project config | `pyproject.toml` (PEP 517/518) |

---

## Coding Conventions

### Python

- Target **Python 3.11+**; use modern syntax (`match`, `tomllib`, `|` union types, etc.)
- Follow [PEP 8](https://peps.python.org/pep-0008/) for style
- Use type hints on all function signatures
- Prefer `pathlib.Path` over `os.path`
- Use `subprocess.run(..., check=False)` when shelling out to `safety scan` (exit code 1 means vulnerabilities found, not a crash)
- Never hardcode API keys; read from environment variables (`os.environ`)

### Security-specific

- Always pin dependencies to exact versions in example `requirements.txt` snippets
- Use `safety scan` — **never** suggest the deprecated `safety check`
- Use `--stage cicd` and `--key $SAFETY_API_KEY` in all CI/CD examples
- Use `safety auth login` for development examples (not API key)
- Prefer `--save-as json report.json` when parsing Safety results programmatically
- Demonstrate the use of `.safety-policy.yml` **v3 schema** (`version: '3.0'`) for ignoring vulnerabilities with documented reasons
- Never suggest ignoring CVEs without a `reason` comment in the policy file
- Always validate policy files with `safety validate policy_file`

### Documentation

- Keep `README.md` as the authoritative reference; all tutorials live there
- Use fenced code blocks with language tags (` ```bash `, ` ```yaml `, ` ```python `)
- Table of Contents must be kept in sync with section headings
- Prefer real, runnable examples over abstract descriptions

---

## Running Safety

```bash
# Install dev dependencies
uv sync --group dev

# Authenticate (development, one-time)
uv run safety auth login

# Scan the project directory
uv run safety scan

# CI/CD scan with API key
uv run safety --key $SAFETY_API_KEY --stage cicd scan

# Scan with policy file
uv run safety scan --policy-file .safety-policy.yml

# Save JSON report
uv run safety --key $SAFETY_API_KEY --stage cicd scan --save-as json report.json

# Auto-fix requirements.txt
uv run safety scan --apply-fixes

# Validate policy file
uv run safety validate policy_file
```

---

## Common Tasks for Copilot

When asked to help with this project, prefer:

1. **Writing Safety CLI examples** — use `uv run safety scan ...` (NOT `safety check` — it's deprecated)
2. **Auth examples** — `safety auth login` for dev, `safety --key $SAFETY_API_KEY --stage cicd scan` for CI
3. **CI/CD snippets** — default to GitHub Actions using `actions/setup-python@v5` and `uv` for setup
4. **Policy file generation** — produce `.safety-policy.yml` with `version: '3.0'` schema; use `installation.allow.vulnerabilities` for ignores with `reason` comments
5. **Parsing Safety JSON output** — parse `result.stdout` from `safety scan --output json`; top-level key is `vulnerabilities`, each entry has `package_name`, `installed_version`, `vulnerability_id`, `severity.cvss_v3`
6. **Adding new tutorial sections** — follow the existing heading and table style in `README.md`

---

## What to Avoid

- Do **not** suggest `pip install` for managing project deps — use `uv add` / `uv sync`
- Do **not** commit real API keys or secrets
- Do **not** use `safety check` — it is **deprecated** in Safety v3; use `safety scan`
- Do **not** use old v2 policy schema (`version: "2.0"`) — use v3 schema (`version: '3.0'`)
- Do **not** suggest `--ignore <id>` flag — it does not exist in `safety scan`; use policy file `installation.allow.vulnerabilities` instead
- Do **not** use `os.system()` — use `subprocess.run()` with `check=False` (exit 1 = vulns found)

---

## Project Structure

```
cq-safety/
├── .github/
│   └── copilot-instructions.md   # ← You are here
├── README.md                     # Full Safety tutorial and reference
├── pyproject.toml                # Project metadata and dev dependencies
└── uv.lock                       # Locked dependency graph
```
