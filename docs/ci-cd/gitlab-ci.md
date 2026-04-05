# GitLab CI

## Prerequisites

1. Create an API key at [platform.safetycli.com](https://platform.safetycli.com).
2. Add it as a CI/CD variable named `SAFETY_API_KEY` in **Settings → CI/CD → Variables**.

---

## Basic Scan

```yaml
safety-scan:
  stage: test
  image: python:3.11-slim
  before_script:
    - pip install uv
    - uv sync --group dev
  script:
    - uv run safety --key "$SAFETY_API_KEY" --stage cicd scan
      --policy-file .safety-policy.yml
  variables:
    SAFETY_API_KEY: $SAFETY_API_KEY
```

---

## With Artifacts

```yaml
safety-scan:
  stage: security
  image: python:3.11-slim
  before_script:
    - pip install uv
    - uv sync --group dev
    - mkdir -p reports
  script:
    - |
      uv run safety --key "$SAFETY_API_KEY" --stage cicd scan \
        --policy-file .safety-policy.yml \
        --save-as json reports/safety-report.json \
        --save-as html reports/safety-report.html
  artifacts:
    when: always
    paths:
      - reports/
    expire_in: 90 days
  variables:
    SAFETY_API_KEY: $SAFETY_API_KEY
```

---

## With uv Cache

```yaml
safety-scan:
  stage: security
  image: python:3.11-slim
  cache:
    key: uv-$CI_COMMIT_REF_SLUG
    paths:
      - .uv/
  variables:
    UV_CACHE_DIR: .uv
    SAFETY_API_KEY: $SAFETY_API_KEY
  before_script:
    - pip install uv
    - uv sync --group dev
    - mkdir -p reports
  script:
    - |
      uv run safety --key "$SAFETY_API_KEY" --stage cicd scan \
        --policy-file .safety-policy.yml \
        --save-as json reports/safety-report.json
  artifacts:
    when: always
    paths:
      - reports/
    expire_in: 30 days
```

---

## Scheduled Scan

In GitLab, use **CI/CD → Schedules** to configure a daily scan, and add this job:

```yaml
daily-safety-scan:
  stage: security
  image: python:3.11-slim
  rules:
    - if: $CI_PIPELINE_SOURCE == "schedule"
  before_script:
    - pip install uv
    - uv sync --group dev
    - mkdir -p reports
  script:
    - |
      uv run safety --key "$SAFETY_API_KEY" --stage cicd scan \
        --policy-file .safety-policy.yml \
        --save-as json reports/safety-report.json
  artifacts:
    when: always
    paths:
      - reports/
    expire_in: 30 days
  variables:
    SAFETY_API_KEY: $SAFETY_API_KEY
```
