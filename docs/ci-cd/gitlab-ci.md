# GitLab CI

## Basic Job

```yaml
# .gitlab-ci.yml
safety-scan:
  stage: test
  image: python:3.11-slim
  script:
    - pip install safety
    - pip install -r requirements.txt
    - safety check -r requirements.txt --full-report
  variables:
    SAFETY_API_KEY: $SAFETY_API_KEY   # Set in GitLab CI/CD variables
```

---

## With JSON Artifact

```yaml
safety-scan:
  stage: test
  image: python:3.11-slim
  script:
    - pip install safety
    - pip install -r requirements.txt
    - safety check -r requirements.txt --json 2>/dev/null | tee safety-report.json
  artifacts:
    name: safety-report
    paths:
      - safety-report.json
    when: always
    expire_in: 30 days
```

---

## With Policy File

```yaml
safety-scan:
  stage: test
  image: python:3.11-slim
  script:
    - pip install safety
    - pip install -r requirements.txt
    - safety check --policy-file .safety-policy.yml -r requirements.txt
```

---

## With uv

```yaml
safety-scan:
  stage: test
  image: python:3.11-slim
  before_script:
    - pip install uv
    - uv sync --group dev
  script:
    - uv run safety check -r requirements.txt
```

---

## Setting the API Key Variable

1. Navigate to **Settings → CI/CD → Variables**
2. Add variable: `SAFETY_API_KEY` (mark as **Masked**)
3. Reference it in your job with `$SAFETY_API_KEY`
