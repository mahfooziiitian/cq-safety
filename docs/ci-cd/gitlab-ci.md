# GitLab CI

## Basic Job (Safety v2)

```yaml
# .gitlab-ci.yml
safety-check:
  stage: test
  image: python:3.11-slim
  script:
    - pip install safety
    - safety check --key $SAFETY_API_KEY -r requirements.txt
  variables:
    SAFETY_API_KEY: $SAFETY_API_KEY   # Set in GitLab CI/CD Variables
```

---

## With JSON Artifact

```yaml
safety-check:
  stage: test
  image: python:3.11-slim
  script:
    - pip install safety
    - safety check --key $SAFETY_API_KEY -r requirements.txt --json > safety-report.json
  artifacts:
    name: safety-report
    paths:
      - safety-report.json
    when: always
    expire_in: 30 days
  variables:
    SAFETY_API_KEY: $SAFETY_API_KEY
```

---

## With Policy File

```yaml
safety-check:
  stage: test
  image: python:3.11-slim
  script:
    - pip install safety
    - safety check --key $SAFETY_API_KEY -r requirements.txt --policy-file .safety-policy.yml
  variables:
    SAFETY_API_KEY: $SAFETY_API_KEY
```

---

## With uv

```yaml
safety-check:
  stage: test
  image: python:3.11-slim
  before_script:
    - pip install uv
    - uv sync --group dev
  script:
    - uv run safety check --key $SAFETY_API_KEY -r requirements.txt
  variables:
    SAFETY_API_KEY: $SAFETY_API_KEY
```

---

## Full Report

```yaml
safety-check:
  stage: test
  image: python:3.11-slim
  script:
    - pip install safety
    - |
      safety check \
        --key $SAFETY_API_KEY \
        -r requirements.txt \
        --full-report
  variables:
    SAFETY_API_KEY: $SAFETY_API_KEY
```

---

## Setting the API Key Variable

1. Navigate to **Settings → CI/CD → Variables**
2. Add variable: `SAFETY_API_KEY` (mark as **Masked** and **Protected**)
3. Get your API key from [pyup.io/account/api-key/](https://pyup.io/account/api-key/)
