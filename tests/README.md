<!--
# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 The Linux Foundation
-->

# Tests for Python Supported Versions Action

This directory contains all the test files and test logic for the `python-supported-versions-action`.

## Test Files Structure

### Test Data Files (TOML)

- `pyproject_requires_python_basic.toml` - Basic `>=3.10` constraint
- `pyproject_requires_python_strict.toml` - Strict `>=3.12` constraint
- `pyproject_requires_python_exact.toml` - Exact `==3.11` constraint
- `pyproject_requires_python_greater.toml` - Greater than `>3.10` constraint
- `pyproject_classifiers_only.toml` - Uses Python classifiers (no requires-python)
- `pyproject_classifiers_fallback.toml` - Fallback to classifiers method
- `pyproject_no_python_info.toml` - No Python version information (error case)
- `pyproject_unsupported_constraint.toml` - Unsupported constraint format
- `test_pyproject_fallback.toml` - Fallback test case

### Test Scripts

- `quick_test.sh` - Quick validation script for basic functionality
- `run_all_tests.sh` - Comprehensive test runner that validates all test cases

## Running Tests

### Local Testing

```bash
# Run quick test
cd tests/
./quick_test.sh

# Run all tests
./run_all_tests.sh
```

### GitHub Actions Testing

The tests are automatically run via the GitHub Actions workflow in
`.github/workflows/testing.yaml` which:

1. **External Repository Test** - Tests against a real external Python project
2. **Requires-Python Method Tests** - Tests different `requires-python`
   constraint formats
3. **Fallback Method Tests** - Tests classifier-based fallback detection
4. **Failure Condition Tests** - Tests error handling for edge cases
5. **Missing pyproject.toml Test** - Tests behavior when no pyproject.toml exists

### Test Strategy

The tests use a matrix strategy to verify:

- Different `requires-python` constraint formats (`>=`, `>`, `==`, etc.)
- Fallback to Python version classifiers when `requires-python` is missing
- Error handling for files with no Python version information
- Proper JSON output format for GitHub Actions matrix jobs

Each test case verifies:

- **BUILD_PYTHON** output (highest supported Python version)
- **MATRIX_JSON** output (JSON array of all supported versions)

## Expected Outputs

### Basic requires-python (>=3.10)

- BUILD_PYTHON: `3.14`
- MATRIX_JSON: `{"python-version": ["3.10","3.11","3.12","3.13","3.14"]}`

### Strict requires-python (>=3.12)

- BUILD_PYTHON: `3.14`
- MATRIX_JSON: `{"python-version": ["3.12","3.13","3.14"]}`

### Classifiers fallback method

- BUILD_PYTHON: `3.12`
- MATRIX_JSON: `{"python-version": ["3.10","3.11","3.12"]}`

## Adding New Tests

To add a new test case:

1. Create a new `pyproject_*.toml` file with your test scenario
2. Add the test case to the GitHub Actions workflow matrix in `testing.yaml`
3. Update `run_all_tests.sh` to include the new test
4. Document the expected outputs in this README

## Notes

- All test scripts are now consolidated under the `tests/` directory
The GitHub Actions workflow automatically handles file setup/cleanup
- Tests verify both the happy path and error conditions
- The action supports Python versions 3.10 through 3.14 (current supported versions)
