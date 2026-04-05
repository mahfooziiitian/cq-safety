# Quick Start

## 1. Scan Your Active Environment

```bash
safety check
```

Safety reads all packages installed in the current Python environment and checks them against the vulnerability database.

---

## 2. Scan a Requirements File

```bash
safety check -r requirements.txt
```

!!! tip "Multiple files"
    ```bash
    safety check -r requirements.txt -r requirements-dev.txt
    ```

---

## 3. Pipe from `pip freeze`

```bash
pip freeze | safety check --stdin
```

Useful in Docker builds or ephemeral environments where you don't have a `requirements.txt`.

---

## 4. Read the Output

**No vulnerabilities found:**

```
+===========================================================================+
| REPORT                                                                    |
| checked 42 packages, using free DB (updated once a month)                 |
+===========================================================================+
| No known security vulnerabilities found.                                  |
+===========================================================================+
```

**Vulnerability detected:**

```
+============================+===========+==========================+=======+
| package                    | installed | affected                | ID    |
+============================+===========+==========================+=======+
| requests                   | 2.19.1    | <2.20.0                 | 36546 |
+============================+===========+==========================+=======+
```

See [Output Formats](../usage/output-formats.md) for JSON and bare output options.

---

## 5. Fix Vulnerabilities

Update the offending package to a safe version:

```bash
pip install --upgrade requests
# or with uv:
uv add "requests>=2.20.0"
```

Then re-run the scan to confirm the issue is resolved.
