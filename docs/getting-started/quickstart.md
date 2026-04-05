# Quick Start

## 1. Install Safety

```bash
pip install safety
# or with uv:
uv add --dev safety
```

---

## 2. Run `safety check`

```bash
# Scan currently installed packages
safety check

# Scan a requirements file
safety check -r requirements.txt

# Scan from pip freeze output
pip freeze | safety check --stdin
```

Safety checks your packages against a curated database of known CVEs.

---

## 3. Check a Requirements File

```bash
safety check -r requirements.txt
```

You can pass multiple files:

```bash
safety check -r requirements.txt -r requirements-dev.txt
```

---

## 4. Read the Output

**No vulnerabilities found:**

```
No known security vulnerabilities found.
```

**Vulnerability detected:**

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

See [Output Formats](../usage/output-formats.md) for JSON and bare options.

---

## 5. Fix Vulnerabilities

Upgrade the vulnerable package:

```bash
pip install --upgrade requests
# or with uv:
uv add "requests>=2.20.0"
```

Then re-run the scan to confirm the issue is resolved:

```bash
safety check -r requirements.txt
```
