# Output Formats

Safety v2 supports four output formats.

---

## Default (Human-readable Table)

```bash
safety check -r requirements.txt
```

Output:

```
+==============================================================================+
| REPORT                                                                       |
| checked 42 packages, using free DB (updated once a month)                   |
+============================+===========+==========================+==========+
| package                    | installed | affected                 | ID       |
+============================+===========+==========================+==========+
| requests                   | 2.19.1    | <2.20.0                  | 36546    |
+============================+===========+==========================+==========+
```

---

## Full Report

```bash
safety check --full-report -r requirements.txt
```

Includes the full advisory text for each vulnerability.

---

## Short Report

```bash
safety check --short-report -r requirements.txt
```

Shows a condensed one-line summary per vulnerability.

---

## JSON

```bash
safety check --json -r requirements.txt
# or save to a file
safety check --json -r requirements.txt > safety-report.json
```

Best for CI/CD pipelines and programmatic processing.

v2 JSON output is a **list of lists**. Each inner list has the structure:

```
[package_name, affected_range, installed_version, advisory_text, vuln_id]
```

Example:
```json
[
  [
    "requests",
    "<2.20.0",
    "2.19.1",
    "Requests before 2.20.0 sends an HTTP Authorization header to an http URI upon receiving a same-hostname https-to-http redirect...",
    "36546"
  ]
]
```

### Parsing in Python

```python
import json
import subprocess

result = subprocess.run(
    ["safety", "check", "--json", "-r", "requirements.txt"],
    capture_output=True,
    text=True,
    check=False,   # exit code 1 on vulnerabilities — handle manually
)
vulnerabilities = json.loads(result.stdout)
for vuln in vulnerabilities:
    package_name, affected_range, installed_version, advisory, vuln_id = vuln
    print(f"{package_name} {installed_version} — {vuln_id} (affected: {affected_range})")
```

---

## Bare

```bash
safety check --bare -r requirements.txt
```

Outputs only the names of vulnerable packages, one per line. Useful for piping into other tools:

```bash
safety check --bare -r requirements.txt | xargs echo "Vulnerable:"
```
