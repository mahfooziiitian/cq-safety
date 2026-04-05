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
- Use `subprocess.run(..., check=True)` when shelling out to `safety`
- Never hardcode API keys; read from environment variables (`os.environ`)

### Security-specific

- Always pin dependencies to exact versions in example `requirements.txt` snippets
- When writing scripts that invoke `safety`, always handle non-zero exit codes explicitly
- Prefer `--json` output when parsing Safety results programmatically
- Demonstrate the use of `.safety-policy.yml` for ignoring vulnerabilities with documented reasons and expiry dates
- Never suggest `--ignore` without a comment explaining the rationale

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

# Scan the current environment
uv run safety check

# Scan a requirements file
uv run safety check -r requirements.txt

# Full report with CVE details
uv run safety check --full-report

# JSON output for tooling
uv run safety check --json
```

---

## Common Tasks for Copilot

When asked to help with this project, prefer:

1. **Writing Safety CLI examples** — use `uv run safety ...` to stay consistent with the `uv`-based workflow
2. **CI/CD snippets** — default to GitHub Actions using `actions/setup-python@v5` and `uv` for setup
3. **Policy file generation** — produce `.safety-policy.yml` with `version: "2.0"`, severity thresholds, and expiry dates on all ignored CVEs
4. **Parsing Safety JSON output** — use `json.loads()` in Python; each item is `[package, affected_range, installed, advisory, vuln_id]`
5. **Adding new tutorial sections** — follow the existing heading and table style in `README.md`

---

## What to Avoid

- Do **not** suggest `pip install` for managing project deps — use `uv add` / `uv sync`
- Do **not** commit real API keys or secrets
- Do **not** suggest ignoring a CVE without an `expires` field and `reason` in the policy file
- Do **not** use `os.system()` — use `subprocess.run()` with `check=True`
- Do **not** write Python 2-compatible code

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
