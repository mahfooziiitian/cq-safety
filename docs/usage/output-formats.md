# Output Formats

Safety supports three output formats.

---

## Default (Human-readable)

```bash
safety check -r requirements.txt
```

Best for local development and manual review.

```
+============================+===========+==========================+=======+
| package                    | installed | affected                | ID    |
+============================+===========+==========================+=======+
| requests                   | 2.19.1    | <2.20.0                 | 36546 |
+============================+===========+==========================+=======+
```

---

## JSON

```bash
safety check -r requirements.txt --json
```

Best for CI/CD pipelines, SIEM tools, and dashboards.

```json
[
  [
    "requests",
    "<2.20.0",
    "2.19.1",
    "Requests before 2.20.0 sends Authorization headers on redirect...",
    "36546"
  ]
]
```

**Array structure per vulnerability:**

| Index | Field |
|---|---|
| `0` | Package name |
| `1` | Affected version range |
| `2` | Installed version |
| `3` | Advisory text |
| `4` | Safety vulnerability ID |

### Parsing in Python

```python
import json
import subprocess

result = subprocess.run(
    ["safety", "check", "-r", "requirements.txt", "--json"],
    capture_output=True,
    text=True,
)
vulnerabilities = json.loads(result.stdout)
for vuln in vulnerabilities:
    package, affected, installed, advisory, vuln_id = vuln
    print(f"{package} {installed} — CVE ID: {vuln_id}")
```

---

## Bare

```bash
safety check -r requirements.txt --bare
```

Returns only vulnerable package names, one per line. Useful for scripting.

```
requests
django
```

---

## Saving Output to a File

```bash
# JSON report
safety check --json 2>/dev/null | tee safety-report.json

# Human-readable report
safety check --full-report > safety-report.txt
```
