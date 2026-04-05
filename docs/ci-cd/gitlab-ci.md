# GitLab CI

## Basic Job (Safety v3)

```yaml
# .gitlab-ci.yml
safety-scan:
  stage: test
  image: python:3.11-slim
  script:
    - pip install "safety>=3.0"
    - safety --key $SAFETY_API_KEY --stage cicd scan
  variables:
    SAFETY_API_KEY: $SAFETY_API_KEY   # Set in GitLab CI/CD Variables
```

---

## With JSON Artifact

```yaml
safety-scan:
  stage: test
  image: python:3.11-slim
  script:
    - pip install "safety>=3.0"
    - safety --key $SAFETY_API_KEY --stage cicd scan --save-as json safety-report.json
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
safety-scan:
  stage: test
  image: python:3.11-slim
  script:
    - pip install "safety>=3.0"
    - safety --key $SAFETY_API_KEY --stage cicd scan --policy-file .safety-policy.yml
  variables:
    SAFETY_API_KEY: $SAFETY_API_KEY
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
    - uv run safety --key $SAFETY_API_KEY --stage cicd scan
  variables:
    SAFETY_API_KEY: $SAFETY_API_KEY
```

---

## Multi-format Reports

```yaml
safety-scan:
  stage: test
  image: python:3.11-slim
  script:
    - pip install "safety>=3.0"
    - |
      safety --key $SAFETY_API_KEY --stage cicd scan \
        --save-as json safety-report.json \
        --save-as html safety-report.html
  artifacts:
    paths:
      - safety-report.json
      - safety-report.html
    when: always
    expire_in: 30 days
```

---

## Setting the API Key Variable

1. Navigate to **Settings → CI/CD → Variables**
2. Add variable: `SAFETY_API_KEY` (mark as **Masked** and **Protected**)
3. Get your API key from [platform.safetycli.com](https://platform.safetycli.com)
