# GitHub Actions

## Prerequisites

1. Create an API key at [platform.safetycli.com](https://platform.safetycli.com) under **Settings → API Keys**.
2. Add it as a repository secret named `SAFETY_API_KEY` in **Settings → Secrets and variables → Actions**.

---

## Basic Scan

```yaml
name: Security Scan

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  safety-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: astral-sh/setup-uv@v4
        with:
          version: "latest"

      - run: uv python install 3.11

      - run: uv sync --group dev

      - name: Run Safety scan
        run: |
          uv run safety --key "$SAFETY_API_KEY" --stage cicd scan \
            --policy-file .safety-policy.yml
        env:
          SAFETY_API_KEY: ${{ secrets.SAFETY_API_KEY }}
```

---

## With Reports and Artifacts

```yaml
name: Security Scan

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  safety-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: astral-sh/setup-uv@v4
        with:
          version: "latest"

      - run: uv python install 3.11

      - run: uv sync --group dev

      - run: mkdir -p reports

      - name: Run Safety scan
        run: |
          uv run safety --key "$SAFETY_API_KEY" --stage cicd scan \
            --policy-file .safety-policy.yml \
            --save-as json reports/safety-report.json \
            --save-as html reports/safety-report.html
        env:
          SAFETY_API_KEY: ${{ secrets.SAFETY_API_KEY }}

      - name: Upload reports
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: safety-reports-${{ github.run_number }}
          path: reports/
          retention-days: 90
```

---

## Scheduled Daily Scan

Catch newly published CVEs even when no code has changed:

```yaml
name: Daily Security Scan

on:
  schedule:
    - cron: "0 6 * * *"   # Daily at 06:00 UTC
  workflow_dispatch:

jobs:
  safety-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@v4
        with:
          version: "latest"
      - run: uv python install 3.11
      - run: uv sync --group dev
      - run: mkdir -p reports
      - name: Run Safety scan
        run: |
          uv run safety --key "$SAFETY_API_KEY" --stage cicd scan \
            --policy-file .safety-policy.yml \
            --save-as json reports/safety-report.json
        env:
          SAFETY_API_KEY: ${{ secrets.SAFETY_API_KEY }}
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: daily-safety-report
          path: reports/
          retention-days: 30
```

---

## PR Annotation on Failure

```yaml
      - name: Annotate PR on failure
        if: failure() && github.event_name == 'pull_request'
        run: |
          echo "## ❌ Safety Scan Failed" >> $GITHUB_STEP_SUMMARY
          echo "Vulnerabilities found above policy threshold." >> $GITHUB_STEP_SUMMARY
          echo "Run \`make scan\` locally to investigate." >> $GITHUB_STEP_SUMMARY
```

---

## Caching uv

Speed up CI by caching uv's download cache:

```yaml
      - uses: astral-sh/setup-uv@v4
        with:
          version: "latest"
          enable-cache: true
          cache-dependency-glob: "uv.lock"
```

---

## Secret Setup

1. Navigate to your GitHub repository
2. Go to **Settings → Secrets and variables → Actions**
3. Click **New repository secret**
4. Name: `SAFETY_API_KEY`, Value: your API key from [platform.safetycli.com](https://platform.safetycli.com)
