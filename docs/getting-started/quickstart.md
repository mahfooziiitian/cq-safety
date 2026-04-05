# Quick Start

## 1. Authenticate

=== "Development (browser login)"

    ```bash
    safety auth login
    # Opens platform.safetycli.com in your browser
    ```

=== "CI/CD (API key)"

    ```bash
    export SAFETY_API_KEY=your-key-here
    ```

---

## 2. Scan Your Project

```bash
# Scan the current directory (default)
safety scan

# Scan a specific directory
safety scan --target /path/to/project
```

Safety v3 scans your **entire project directory** — it auto-discovers `requirements.txt`, `pyproject.toml`, `Pipfile`, and other dependency files.

---

## 3. Detailed Output

```bash
safety scan --detailed-output
```

---

## 4. Read the Output

**No vulnerabilities found:**

```
  Safety Report
  ─────────────
  Scanned 0 vulnerabilities in 42 packages.
  No known security vulnerabilities found.
```

**Vulnerability detected (screen output):**

```
  Safety Report
  ─────────────
  → requests 2.19.1
    CVE-2018-18074 (CVSS 9.8 Critical)
    Affected: <2.20.0
    Fix: Upgrade to requests>=2.20.0
```

See [Output Formats](../usage/output-formats.md) for JSON, HTML, and SPDX options.

---

## 5. Auto-Fix Vulnerabilities

Safety v3 can patch your `requirements.txt` files automatically:

```bash
safety scan --apply-fixes
```

!!! note
    `--apply-fixes` currently supports `requirements.txt` files only.

Or upgrade manually:

```bash
pip install --upgrade requests
# or with uv:
uv add "requests>=2.20.0"
```

Then re-run the scan to confirm the issue is resolved:

```bash
safety scan
