# Output Formats

Safety v3 supports five output formats via the `--output` flag.

---

## Screen (Default)

```bash
safety scan
safety scan --detailed-output   # verbose
```

Best for local development and manual review. `--detailed-output` adds full CVE advisory text.

---

## JSON

```bash
safety scan --output json
# or save to a file
safety scan --save-as json safety-report.json
```

Best for CI/CD pipelines, SIEM tools, and dashboards.

Example output structure:
```json
{
  "metadata": {
    "safety_command": "scan",
    "stage": "development",
    "scan_type": "project"
  },
  "vulnerabilities": [
    {
      "package_name": "requests",
      "installed_version": "2.19.1",
      "affected_versions": "<2.20.0",
      "vulnerability_id": "CVE-2018-18074",
      "severity": {
        "cvss_v3": { "base_score": 9.8, "base_severity": "CRITICAL" }
      },
      "advisory": "Requests before 2.20.0 sends Authorization headers on redirect...",
      "fixed_versions": ["2.20.0"]
    }
  ]
}
```

### Parsing in Python

```python
import json
import subprocess

result = subprocess.run(
    ["safety", "scan", "--output", "json"],
    capture_output=True,
    text=True,
    check=False,   # exit code 1 on vulnerabilities — handle manually
)
report = json.loads(result.stdout)
for vuln in report.get("vulnerabilities", []):
    print(
        f"{vuln['package_name']} {vuln['installed_version']} "
        f"— {vuln['vulnerability_id']} "
        f"({vuln['severity']['cvss_v3']['base_severity']})"
    )
```

---

## HTML

```bash
safety scan --save-as html safety-report.html
```

Generates a human-readable HTML report. Useful for sharing with non-technical stakeholders.

---

## Text

```bash
safety scan --output text
safety scan --save-as text safety-report.txt
```

Plain-text format suitable for log files and audit trails.

---

## SPDX

```bash
safety scan --save-as spdx safety-report.spdx
```

[Software Package Data Exchange](https://spdx.dev/) format for software bill of materials (SBOM) workflows.

---

## Saving and Displaying Simultaneously

Use `--save-as` to write a file **and** display screen output at the same time:

```bash
# Display on screen AND save JSON
safety scan --save-as json safety-report.json --output screen
```
