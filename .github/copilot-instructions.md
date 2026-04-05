# GitHub Copilot Instructions — cq-safety

## Project Overview

This repository is a **Python code-quality project** focused on the [Safety](https://pyup.io/safety/) dependency vulnerability scanner. It provides:

- A tutorial and reference guide (`README.md`) for using Safety v2 to detect CVEs in Python packages
- A `pyproject.toml`-managed project using [uv](https://docs.astral.sh/uv/) with Safety as a dev dependency

**Purpose:** Teach developers how to integrate `safety check` into their Python projects and CI/CD pipelines to catch known security vulnerabilities in third-party packages.

---

## Tech Stack

| Layer | Tool |
|---|---|
| Language | Python ≥ 3.11 |
| Package manager | `uv` (see `uv.lock`) |
| Security scanner | `safety` (v2 — `safety check` era) |
| Project config | `pyproject.toml` (PEP 517/518) |

---

## Coding Conventions

### Python

- Target **Python 3.11+**; use modern syntax (`match`, `tomllib`, `|` union types, etc.)
- Follow [PEP 8](https://peps.python.org/pep-0008/) for style
- Use type hints on all function signatures
- Prefer `pathlib.Path` over `os.path`
- Use `subprocess.run(..., check=False)` when shelling out to `safety check` (exit code 1 means vulnerabilities found, not a crash)
- Never hardcode API keys; read from environment variables (`os.environ`)

### Security-specific

- Always pin dependencies to exact versions in example `requirements.txt` snippets
- Use `safety check` — **never** suggest `safety scan` (v3 only)
- Use `--key $SAFETY_API_KEY` for CI/CD examples
- Use `--json` when parsing Safety results programmatically
- v2 JSON output is an **array of arrays**: `[package_name, affected_range, installed_version, advisory_text, vuln_id]`
- Demonstrate the use of `.safety-policy.yml` **v2 schema** (`version: "2.0"`) for ignoring vulnerabilities with documented reasons
- Never suggest ignoring CVEs without a `reason` comment in the policy file
- Use `--ignore <id>` CLI flag or `ignore-vulnerabilities` in the policy file to suppress known false positives

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

# Scan installed packages (full report)
uv run safety check --full-report

# Scan a requirements file
uv run safety check -r requirements.txt

# CI/CD scan with API key
uv run safety check --key $SAFETY_API_KEY -r requirements.txt

# JSON output
uv run safety check --json

# Ignore a specific CVE
uv run safety check --ignore 36546

# Use a policy file
uv run safety check --policy-file .safety-policy.yml

# Generate policy file
uv run safety generate policy_file

# Review a JSON report
uv run safety review --file reports/safety-report.json
```

---

## Common Tasks for Copilot

When asked to help with this project, prefer:

1. **Writing Safety CLI examples** — use `uv run safety check ...` (NOT `safety scan` — that is v3 only)
2. **Auth examples** — API key via `--key $SAFETY_API_KEY` or `SAFETY_API_KEY` env var; no browser login in v2
3. **CI/CD snippets** — default to GitHub Actions using `uv` for setup, `safety check --key $SAFETY_API_KEY -r requirements.txt`
4. **Policy file generation** — produce `.safety-policy.yml` with `version: "2.0"` schema; use `ignore-vulnerabilities` for ignores with `reason` and `expires` fields
5. **Parsing Safety JSON output** — parse `result.stdout` from `safety check --json`; output is a list of lists: `[package_name, affected_range, installed_version, advisory_text, vuln_id]`
6. **Adding new tutorial sections** — follow the existing heading and table style in `README.md`

---

## What to Avoid

- Do **not** suggest `pip install` for managing project deps — use `uv add` / `uv sync`
- Do **not** commit real API keys or secrets
- Do **not** use `safety scan` — it is **v3 only** and does not exist in Safety v2
- Do **not** use `safety auth` — browser login does not exist in Safety v2
- Do **not** use `--stage` flag — it does not exist in Safety v2
- Do **not** use `--apply-fixes` — it does not exist in Safety v2
- Do **not** use `--save-as` — it does not exist in Safety v2
- Do **not** use v3 policy schema (`version: '3.0'`) — use v2 schema (`version: "2.0"`)
- Do **not** reference `platform.safetycli.com` — the v2 portal is `https://pyup.io/account/api-key/`
- Do **not** use `os.system()` — use `subprocess.run()` with `check=False` (exit 1 = vulns found)

---

## Project Structure

```
cq-safety/
├── .github/
│   └── copilot-instructions.md   # ← You are here
├── README.md                     # Full Safety v2 tutorial and reference
├── pyproject.toml                # Project metadata and dev dependencies
└── uv.lock                       # Locked dependency graph
```
