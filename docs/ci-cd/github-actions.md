# GitHub Actions

!!! tip "No requirements.txt? Use environment scanning"
    If your project uses `uv` or `pyproject.toml` without a `requirements.txt`, omit the `-r` flag.
    Safety v2 will scan all packages installed in the active environment.

---

## Basic Workflow — Environment Scan (uv / pyproject.toml)

```yaml
# .github/workflows/security.yml
name: Security Scan

on:
  push:
    branches: [main]
  pull_request:

jobs:
  safety:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install uv
        uses: astral-sh/setup-uv@v4

      - name: Set up Python
        run: uv python install 3.11

      - name: Install dependencies
        run: uv sync --group dev

      - name: Run Safety check
        run: |
          uv run safety check \
            --key "$SAFETY_API_KEY" \
            --policy-file .safety-policy.yml \
            --full-report \
            --save-json reports/safety-report.json
        env:
          SAFETY_API_KEY: ${{ secrets.SAFETY_API_KEY }}
```

---

## Basic Workflow — Requirements File (pip / requirements.txt)

```yaml
jobs:
  safety:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install dependencies
        run: pip install -r requirements.txt safety

      - name: Run Safety check
        run: |
          safety check \
            --key "$SAFETY_API_KEY" \
            -r requirements.txt \
            --policy-file .safety-policy.yml \
            --full-report
        env:
          SAFETY_API_KEY: ${{ secrets.SAFETY_API_KEY }}
```

---

## With JSON + HTML Artifact (uv)

```yaml
      - name: Create reports directory
        run: mkdir -p reports

      - name: Run Safety check
        run: |
          uv run safety check \
            --key "$SAFETY_API_KEY" \
            --policy-file .safety-policy.yml \
            --full-report \
            --save-json reports/safety-report.json
        env:
          SAFETY_API_KEY: ${{ secrets.SAFETY_API_KEY }}

      - name: Upload Safety reports
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: safety-reports
          path: reports/
          retention-days: 90
```

---

## Scheduled Nightly Scan

Catch newly published CVEs against your pinned dependencies:

```yaml
on:
  schedule:
    - cron: "0 6 * * *"   # Daily at 06:00 UTC
  push:
    branches: [main]
  workflow_dispatch:
```

---

## Adding the API Key Secret

1. Go to **Settings → Secrets and variables → Actions**
2. Click **New repository secret**
3. Name: `SAFETY_API_KEY`, Value: your pyup.io API key from [pyup.io/account/api-key](https://pyup.io/account/api-key/)
