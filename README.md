<!--
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 The Linux Foundation
-->

# 🐍 Extract Python Versions Supported by Project

Parses pyproject.toml and extracts the Python versions supported by the
project. Determines the most recent version supported and provides JSON
representing all supported versions, for use in GitHub matrix jobs.

**Primary Method**: Extracts from `requires-python` constraint
(e.g. `requires-python = ">=3.10"`)
**Fallback Method**: Parses `Programming Language :: Python ::` classifiers

This brings alignment with actions/setup-python behavior while maintaining
compatibility with projects that use explicit version classifiers.

## python-supported-versions-action

## Usage Example

<!-- markdownlint-disable MD046 -->

```yaml
  - name: "Get project supported Python versions"
    uses: lfreleng-actions/python-supported-versions-action@main
```

<!-- markdownlint-enable MD046 -->

## Outputs

<!-- markdownlint-disable MD013 -->

| Variable Name | Description                                             |
| ------------- | ------------------------------------------------------- |
| BUILD_PYTHON  | Most recent Python version supported by project         |
| MATRIX_JSON   | All Python versions supported by project as JSON string |

<!-- markdownlint-enable MD013 -->

## Workflow Output Example

For a Python project with the content below in its pyproject.toml file:

```toml
requires-python = ">=3.10"
readme = "README.md"
license = { text = "Apache-2.0" }
keywords = ["Python", "Tool"]
classifiers = [
  "License :: OSI Approved :: Apache Software License",
  "Operating System :: Unix",
  "Programming Language :: Python",
  "Programming Language :: Python :: 3",
  "Programming Language :: Python :: 3.12",
  "Programming Language :: Python :: 3.11",
  "Programming Language :: Python :: 3.10",
]
```

A workflow calling this action will produce the output below:

```console
Found requires-python constraint: >=3.10 💬
Version constraint: >=3.10
Extracted versions from requires-python: 3.10 3.11 3.12 3.13 3.14 💬
Build Python: 3.14 💬
Matrix JSON: {"python-version": ["3.10","3.11","3.12","3.13","3.14"]}
```

## Implementation Details

### Primary Method: requires-python Constraint

The action first attempts to extract the `requires-python` constraint from pyproject.toml:

```toml
requires-python = ">=3.10"    # Supports 3.10, 3.11, 3.12, 3.13, 3.14
requires-python = ">3.9"      # Supports 3.10, 3.11, 3.12, 3.13, 3.14
requires-python = "==3.11"    # Supports 3.11 specifically
```

The action evaluates the constraint against supported Python versions
(non-EOL) and returns all matching versions.

**Supported constraint formats:**

- `>=X.Y` - Version X.Y and above (most common)
- `>X.Y` - Greater than version X.Y
- `==X.Y` - Exact version X.Y

### Fallback Method: Programming Language Classifiers

If no `requires-python` constraint exists, the action falls back to
parsing explicit version classifiers:

```toml
classifiers = [
  "Programming Language :: Python :: 3.12",
  "Programming Language :: Python :: 3.11",
  "Programming Language :: Python :: 3.10",
]
```

### Supported Python Versions

The action includes all supported (non-EOL) Python versions
as of June 2025:

- Python 3.10
- Python 3.11
- Python 3.12
- Python 3.13
- Python 3.14

This list requires updates as new Python versions become available
and older versions reach end-of-life.
