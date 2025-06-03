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

**Dynamic Version Detection with EOL Awareness**: The action automatically
fetches the latest supported Python versions from official sources, filtering
out end-of-life (EOL) versions to ensure supported Python
versions get used. This provides up-to-date, secure version information
without manual updates. Falls back to static definitions when network access
is unavailable.

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

The action first attempts to extract the `requires-python` constraint from
pyproject.toml:

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

The action dynamically fetches supported Python versions from the official
CPython repository on GitHub. This ensures the action always has the most
current information about available Python releases without requiring
manual updates.

**Dynamic Fetching Process:**

1. Attempts to fetch release data from GitHub API
   (`https://api.github.com/repos/python/cpython/releases`)
2. Extracts version numbers from official releases (e.g., "v3.12.1" → "3.12")
3. Filters for Python 3.10+ versions (excluding pre-releases)
4. Uses this live data to determine supported versions

**Fallback Mechanism:**
If network access is unavailable or the API request fails, the action falls
back to a static definition of supported Python versions:

- Python 3.10
- Python 3.11
- Python 3.12
- Python 3.13
- Python 3.14

This ensures the action remains functional even in environments without
internet access, while providing the most current version information
when possible.

## Dynamic Version Fetching with EOL Awareness

The action automatically fetches the latest supported Python versions from
official sources while filtering out end-of-life (EOL) versions. This
ensures
that projects use supported Python versions, improving security
and maintainability.

### How It Works

1. **EOL Data Retrieval**: First fetches Python EOL information from
   `https://endoflife.date/api/python.json` to determine which versions
   are still supported

2. **GitHub API Request**: Makes a request to the GitHub API endpoint:
   `https://api.github.com/repos/python/cpython/tags?per_page=100`

3. **Version Extraction**: Parses the JSON response to extract version
   tags (e.g., "v3.12.1", "v3.13.0")

4. **Multi-layer Filtering**:
   - Filters out pre-release versions (alpha, beta, release candidates)
   - Filters out EOL versions using current date comparison
   - Extracts stable, supported release versions

5. **Version Mapping**: Maps patch versions to minor versions
   (e.g., "v3.12.1" → "3.12")

6. **Version Filter**: Includes Python 3.9 and above (EOL permitting)

### Network Resilience

The action includes robust error handling for network-related issues:

- **Timeout Protection**: Network requests have a 10-second timeout with
  2 retries
- **Dual API Fallback**: If endoflife.date API fails, uses static EOL data
- **Graceful Degradation**: Falls back to static versions if all network
  calls fail
- **No Workflow Failure**: Network issues don't cause the action to fail

### Benefits

- **Always Current**: Automatically discovers new Python versions as
  they're released
- **Security-Focused**: Automatically excludes EOL versions that no longer
  receive security updates
- **No Maintenance**: Eliminates the need for manual version list updates
- **Reliable**: Maintains compatibility with air-gapped environments
- **Performance**: Minimal impact on workflow execution time
- **Compliance**: Helps maintain security compliance by preventing use of
  unsupported Python versions

### Example Output

When dynamic fetching with EOL filtering is successful:

```console
Attempting to fetch Python versions dynamically with EOL awareness...
Fetched EOL data from endoflife.date API
Current date: 2025-07-10
Non-EOL versions from API: 3.9 3.10 3.11 3.12 3.13
Fetched tag data from GitHub API
EOL-filtered dynamic versions found: 3.10 3.11 3.12 3.13
Using dynamic-eol-aware Python versions: 3.10 3.11 3.12 3.13
```

When EOL API fails but GitHub API succeeds:

```console
Attempting to fetch Python versions dynamically with EOL awareness...
Warning: Failed to fetch EOL data from endoflife.date API
Using static EOL data for filtering...
Non-EOL versions from static data: 3.9 3.10 3.11 3.12 3.13
Fetched tag data from GitHub API
EOL-filtered dynamic versions found: 3.10 3.11 3.12 3.13
Using dynamic-eol-aware Python versions: 3.10 3.11 3.12 3.13
```

When network is unavailable:

```console
Attempting to fetch Python versions dynamically with EOL awareness...
Warning: Failed to fetch EOL data from endoflife.date API
Warning: Failed to fetch from GitHub API (network unavailable or timeout)
Falling back to static definition...
Using static Python versions: 3.9 3.10 3.11 3.12 3.13
```

## Testing

The action includes comprehensive tests to verify dynamic fetching, EOL
filtering,
and fallback behavior:

### Running Tests

```bash
# Test EOL-aware version filtering
./tests/test_eol_filtering.sh

# Test dynamic version fetching with EOL awareness
./tests/test_dynamic_versions.sh

# Test network fallback behavior
./tests/test_fallback.sh

# Simple end-to-end test
./tests/simple_test.sh

# Run all tests (comprehensive suite)
./tests/run_all_tests.sh
```

### Test Coverage

- **EOL-Aware Filtering**: Verifies correct exclusion of end-of-life Python
  versions
- **Dynamic Version Fetching**: Verifies API calls and version parsing with
  EOL filtering
- **Network Fallback**: Tests behavior when network is unavailable
- **Static EOL Data**: Tests fallback EOL filtering when API is unavailable
- **Version Parsing**: Validates extraction of stable, supported releases
- **JSON Generation**: Ensures output format is correct
- **Error Handling**: Confirms graceful degradation
- **Edge Cases**: Tests date comparison, empty data, and mixed scenarios

### Manual Testing

To manually test the EOL-aware dynamic fetching:

```bash
# Test EOL API endpoint
curl -s "https://endoflife.date/api/python.json" | \
  jq -r '.[] | select(.eol > now) | .cycle'

# Test GitHub tags endpoint with filtering
curl -s \
  "https://api.github.com/repos/python/cpython/tags?per_page=100" | \
grep '"name": "v[0-9]' | \
grep -v -E '(a[0-9]|b[0-9]|rc[0-9])' | \
sed 's/.*"v\([0-9]\+\.[0-9]\+\)\.[0-9]\+".*/\1/' | \
sort -V | uniq | \
awk '$1 >= 3.9'

# Combined test (EOL filtering + GitHub tags)
echo "Testing complete EOL-aware filtering pipeline..."
```

Expected output should include current non-EOL stable Python versions.
As of 2025, this typically includes 3.9, 3.10, 3.11, 3.12, 3.13 (3.8 and
earlier are EOL).

### EOL Status Reference

Current Python EOL schedule (as of 2025):

- **Python 3.8**: EOL October 7, 2024 (excluded)
- **Python 3.9**: EOL October 31, 2025 (included)
- **Python 3.10**: EOL October 31, 2026 (included)
- **Python 3.11**: EOL October 31, 2027 (included)
- **Python 3.12**: EOL October 31, 2028 (included)
- **Python 3.13**: EOL October 31, 2029 (included)

The action automatically updates this information by fetching current EOL data
from endoflife.date, ensuring accuracy without manual intervention.
