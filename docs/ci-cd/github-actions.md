# GitHub Actions

## Basic Workflow (Safety v3)

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
        run: pip install "safety>=3.0"

      - name: Run Safety scan
        run: safety --key $SAFETY_API_KEY --stage cicd scan
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

      - name: Run Safety scan
        run: uv run safety --key $SAFETY_API_KEY --stage cicd scan
        env:
          SAFETY_API_KEY: ${{ secrets.SAFETY_API_KEY }}
```

---

## With Policy File and JSON Artifact

```yaml
      - name: Run Safety scan
        run: |
          safety --key $SAFETY_API_KEY --stage cicd scan \
            --policy-file .safety-policy.yml \
            --save-as json safety-report.json
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

## Multi-format Report

```yaml
      - name: Run Safety scan
        run: |
          safety --key $SAFETY_API_KEY --stage cicd scan \
            --save-as json safety-report.json \
            --save-as html safety-report.html
        env:
          SAFETY_API_KEY: ${{ secrets.SAFETY_API_KEY }}

      - name: Upload reports
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: safety-reports
          path: |
            safety-report.json
            safety-report.html
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
3. Name: `SAFETY_API_KEY`, Value: your Safety Platform API key from [platform.safetycli.com](https://platform.safetycli.com)
