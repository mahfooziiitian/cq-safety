# GitHub Actions

## Basic Workflow (Safety v2)

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

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install dependencies
        run: pip install safety

      - name: Run Safety check
        run: safety check --key $SAFETY_API_KEY -r requirements.txt
        env:
          SAFETY_API_KEY: ${{ secrets.SAFETY_API_KEY }}
```

---

## With uv

```yaml
name: Security Scan

on: [push, pull_request]

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
        run: uv run safety check --key $SAFETY_API_KEY -r requirements.txt
        env:
          SAFETY_API_KEY: ${{ secrets.SAFETY_API_KEY }}
```

---

## With Policy File and JSON Artifact

```yaml
      - name: Run Safety check
        run: |
          safety check \
            --key $SAFETY_API_KEY \
            -r requirements.txt \
            --policy-file .safety-policy.yml \
            --json > safety-report.json
        env:
          SAFETY_API_KEY: ${{ secrets.SAFETY_API_KEY }}

      - name: Upload Safety report
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: safety-report
          path: safety-report.json
```

---

## Full Report Variant

```yaml
      - name: Run Safety check (full report)
        run: |
          safety check \
            --key $SAFETY_API_KEY \
            -r requirements.txt \
            --full-report
        env:
          SAFETY_API_KEY: ${{ secrets.SAFETY_API_KEY }}
```

---

## Scheduled Scans

Run a nightly scan to catch newly published CVEs against your pinned dependencies:

```yaml
on:
  schedule:
    - cron: "0 6 * * *"   # Daily at 06:00 UTC
  push:
    branches: [main]
```

---

## Adding the API Key Secret

1. Go to **Settings → Secrets and variables → Actions** in your repository
2. Click **New repository secret**
3. Name: `SAFETY_API_KEY`, Value: your Safety API key from [pyup.io/account/api-key/](https://pyup.io/account/api-key/)
