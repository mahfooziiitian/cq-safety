# Output Formats

Safety CLI 3 supports five output formats, specified with `--output`:

---

## Formats

| Format | Flag | Use Case |
|--------|------|----------|
| `screen` | `--output screen` | Human-readable terminal output (default) |
| `json` | `--output json` | Machine-readable, CI pipelines, scripting |
| `html` | `--output html` | Reports for stakeholders and archiving |
| `text` | `--output text` | Plain text logs and email reports |
| `spdx` | `--output spdx` | Software Bill of Materials (SBOM) |

---

## Screen Format

The default output format. Renders a structured, coloured report in the terminal:

```bash
safety scan --output screen
# or simply:
safety scan
```

---

## JSON Format

Outputs a JSON object to stdout:

```bash
safety scan --output json
safety scan --output json > reports/safety.json
```

### v3 JSON structure

```json
{
  "vulnerabilities": [
    {
      "package_name": "requests",
      "installed_version": "2.28.0",
      "vulnerability_id": "CVE-2023-32681",
      "severity": {
        "cvss_v3": 6.1
      },
      "fixed_versions": ["2.31.0"],
      "advisory": "Requests has a vulnerability..."
    }
  ],
  "scan_metadata": {
    "scan_id": "abc123",
    "timestamp": "2024-01-15T10:00:00Z",
    "packages_scanned": 42,
    "vulnerabilities_found": 1
  }
}
```

### Python parsing example

```python
import json
import subprocess

result = subprocess.run(
    ["safety", "scan", "--output", "json"],
    capture_output=True,
    text=True,
)
data = json.loads(result.stdout)

for vuln in data.get("vulnerabilities", []):
    print(f"{vuln['package_name']} {vuln['installed_version']}")
    print(f"  CVE: {vuln['vulnerability_id']}")
    print(f"  CVSS: {vuln['severity']['cvss_v3']}")
    print(f"  Fix: upgrade to {vuln['fixed_versions']}")
```

---

## HTML Format

Generates a self-contained HTML report:

```bash
safety scan --output html --save-as html reports/safety.html
```

Open `reports/safety.html` in a browser to view the interactive report.

---

## Text Format

Plain text output suitable for logs:

```bash
safety scan --output text
safety scan --output text >> security.log
```

---

## SPDX Format (SBOM)

Generates an [SPDX](https://spdx.dev/) Software Bill of Materials:

```bash
safety scan --output spdx
safety scan --output spdx --save-as spdx reports/sbom.spdx
```

---

## Saving Multiple Formats

Use `--save-as` (repeatable) to save multiple formats simultaneously while still controlling what is displayed to stdout with `--output`:

```bash
safety scan \
  --save-as json reports/safety.json \
  --save-as html reports/safety.html \
  --output screen
```

This saves a JSON report and HTML report to files, while printing the screen format to stdout.
