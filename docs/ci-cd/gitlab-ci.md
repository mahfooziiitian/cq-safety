# GitLab CI

!!! tip "No requirements.txt? Use environment scanning"
    If your project uses `uv` or `pyproject.toml` without a `requirements.txt`, omit the `-r` flag.
    Safety v2 scans all packages installed in the active environment.

---

## Basic Job — Environment Scan (uv / pyproject.toml)

```yaml
# .gitlab-ci.yml
safety-scan:
  stage: test
  image: python:3.11-slim
  before_script:
    - pip install uv
    - uv sync --group dev
  script:
    - uv run safety check
        --key "$SAFETY_API_KEY"
        --policy-file .safety-policy.yml
        --full-report
        --save-json reports/safety-report.json
  variables:
    SAFETY_API_KEY: $SAFETY_API_KEY
```

---

## Basic Job — Requirements File (pip / requirements.txt)

```yaml
safety-scan:
  stage: test
  image: python:3.11-slim
  script:
    - pip install safety
    - pip install -r requirements.txt
    - safety check
        --key "$SAFETY_API_KEY"
        -r requirements.txt
        --policy-file .safety-policy.yml
        --full-report
  variables:
    SAFETY_API_KEY: $SAFETY_API_KEY
```

---

## With JSON Artifact (uv)

```yaml
safety-scan:
  stage: test
  image: python:3.11-slim
  before_script:
    - pip install uv
    - uv sync --group dev
  script:
    - mkdir -p reports
    - uv run safety check
        --key "$SAFETY_API_KEY"
        --policy-file .safety-policy.yml
        --full-report
        --save-json reports/safety-report.json
  artifacts:
    name: safety-report
    paths:
      - reports/safety-report.json
    when: always
    expire_in: 30 days
  variables:
    SAFETY_API_KEY: $SAFETY_API_KEY
```

---

## Setting the API Key Variable

1. Navigate to **Settings → CI/CD → Variables**
2. Add variable: `SAFETY_API_KEY` (mark as **Masked**)
3. Get your API key from [pyup.io/account/api-key](https://pyup.io/account/api-key/)
