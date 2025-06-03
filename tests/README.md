<!--
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 The Linux Foundation
-->

# Tests for Python Supported Versions Action

This directory contains the comprehensive test suite for the
`python-supported-versions-action` with EOL-aware dynamic version fetching.

## Test Structure

### Test Fixtures (`fixtures/`)

The `fixtures/` directory contains self-describing test cases with embedded
metadata:

- `pyproject_requires_python_basic.toml` - Basic `>=3.10` constraint
- `pyproject_requires_python_strict.toml` - Strict `>=3.12` constraint
- `pyproject_requires_python_exact.toml` - Exact `==3.11` constraint
- `pyproject_requires_python_greater.toml` - Greater than `>3.10` constraint
- `pyproject_complex_constraint.toml` - Complex constraint `>=3.10,<3.14`
- `pyproject_mixed_versions.toml` - Mixed scenarios with conflicting version
  info
- `pyproject_classifiers_only.toml` - Uses Python classifiers (no
  requires-python)
- `pyproject_classifiers_fallback.toml` - Fallback to classifiers method
- `pyproject_no_python_info.toml` - No Python version information (error case)
- `pyproject_unsupported_constraint.toml` - Unsupported constraint format

### Test Metadata Format

Each fixture file contains embedded test metadata in comments:

```toml
# TEST_METADATA:
# TEST_NAME: Basic requires-python constraint (>=3.10)
# TEST_TYPE: requires-python
# SHOULD_FAIL: false
# EXPECTED_MIN_VERSION: 3.10
# EXPECTED_VERSIONS_COUNT: 4
# DESCRIPTION: Tests basic >=3.10 constraint with dynamic EOL-aware filtering
```

### Consolidated Test Script

- `test_all.sh` - **Single comprehensive test runner** that:
  - Auto-discovers all fixtures in `fixtures/` directory
  - Reads embedded test metadata from fixture files
  - Tests EOL-aware version filtering
  - Tests network fallback mechanisms
  - Validates all scenarios with detailed reporting

## Running Tests

### Local Testing

```bash
# Run the complete test suite
./tests/test_all.sh
```

### GitHub Actions Testing

Tests are automatically run via `.github/workflows/testing.yaml` which includes:

1. **External Repository Test** - Tests against a real external Python project
2. **Comprehensive Test Suite** - Runs `test_all.sh` for complete coverage
3. **Missing pyproject.toml Test** - Tests error handling for missing files

## Key Features Tested

### Core Functionality

- ✅ Basic requires-python constraints (`>=`, `>`, `==`)
- ✅ Complex requires-python constraints with different conditions
- ✅ Exact version constraints
- ✅ Classifiers scenarios (fallback method)
- ✅ Mixed version scenarios (conflicts between requires-python and classifiers)
- ✅ Error handling and edge cases

### EOL-Aware Features

- ✅ **EOL version filtering** - Automatically excludes Python 3.8 and earlier
- ✅ **Dynamic version fetching** - Uses live data from official sources
- ✅ **Network fallback mechanisms** - Works in air-gapped environments
- ✅ **Static EOL data fallback** - Embedded EOL dates through 2029

### Security & Compliance

- ✅ Prevents use of unsupported Python versions
- ✅ Maintains security compliance through automatic EOL exclusion
- ✅ Comprehensive error handling prevents workflow failures

## Expected Behavior (Current as of 2025)

### EOL-Aware Version Support

- **Excluded**: Python 3.8 and earlier (End-of-Life)
- **Included**: Python 3.9, 3.10, 3.11, 3.12, 3.13 (supported)

### Sample Outputs

#### Basic requires-python (>=3.10)

- BUILD_PYTHON: `3.13` (latest supported)
- MATRIX_JSON: `{"python-version": ["3.10","3.11","3.12","3.13"]}`

#### Exact constraint (==3.11)

- BUILD_PYTHON: `3.11`
- MATRIX_JSON: `{"python-version": ["3.11"]}`

#### Classifiers fallback

- BUILD_PYTHON: `3.12` (based on fixture classifiers)
- MATRIX_JSON: `{"python-version": ["3.10","3.11","3.12"]}`

## Adding New Test Cases

To add a new test case:

1. **Create fixture file** in `fixtures/` directory:

   ```bash
   cp fixtures/pyproject_requires_python_basic.toml \
     fixtures/pyproject_new_test.toml
   ```

2. **Update metadata** in the new fixture file:

   ```toml
   # TEST_METADATA:
   # TEST_NAME: Your test description
   # TEST_TYPE: requires-python|classifiers|error-case
   # SHOULD_FAIL: true|false
   # EXPECTED_MIN_VERSION: 3.10 (optional)
   # EXPECTED_EXACT_VERSION: 3.11 (optional)
   # EXPECTED_VERSIONS_COUNT: 4 (optional)
   # DESCRIPTION: Detailed description of what this tests
   ```

3. **Update project content** as needed for your test scenario

4. **Run tests** - The fixture will be automatically discovered:

   ```bash
   ./tests/test_all.sh
   ```

No changes to test scripts needed! The test runner automatically discovers
and processes all fixtures.

## Test Coverage Summary

The test suite provides comprehensive coverage of:

- **12 fixture-based tests** covering all major scenarios
- **EOL awareness validation** ensuring security compliance
- **Network resilience testing** for air-gapped environments
- **Data-driven approach** making it easy to add new test cases
- **Self-documenting fixtures** with embedded metadata
- **Automated discovery** requiring no manual test registration

## Architecture Benefits

- 🔄 **Auto-discovery**: New tests need fixture files
- 📝 **Self-documenting**: Test metadata embedded in fixtures
- 🧹 **Clean**: Single test script, organized fixtures
- 🚀 **Scalable**: Easy to add new test scenarios
- 🔒 **Secure**: Validates EOL-aware security features
- 🌐 **Resilient**: Tests both online and offline scenarios
