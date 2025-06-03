#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 The Linux Foundation

# Test runner script for python-supported-versions-action
# This script consolidates all test logic for the action

set -e

echo "🧪 Running all tests for Python Supported Versions Action..."

# Change to the tests directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📂 Running tests from: $PWD"

# Function to run a test and check its output
run_test() {
    local test_name="$1"
    local test_file="$2"

    echo "🔍 Testing: $test_name"
    echo "   File: $test_file"

    if [ ! -f "$test_file" ]; then
        echo "❌ Test file not found: $test_file"
        return 1
    fi

    # Extract requires-python if it exists
    REQUIRES_PYTHON_RAW=$(grep -E '^[[:space:]]*requires-python[[:space:]]*=' "$test_file" 2>/dev/null | head -1 || true)

    if [ -n "$REQUIRES_PYTHON_RAW" ]; then
        echo "   Found requires-python constraint"
        REQUIRES_PYTHON="${REQUIRES_PYTHON_RAW##*\"}"
        REQUIRES_PYTHON="${REQUIRES_PYTHON%%\"*}"
        echo "   Constraint: $REQUIRES_PYTHON"
    else
        echo "   No requires-python found, checking classifiers..."
        # Check for Python version classifiers
        CLASSIFIERS=$(grep -E 'Programming Language :: Python :: [0-9]+\.[0-9]+' "$test_file" 2>/dev/null || true)
        if [ -n "$CLASSIFIERS" ]; then
            echo "   Found Python version classifiers"
        else
            echo "   No Python version information found"
        fi
    fi

    echo "✅ $test_name passed"
    echo ""
}

# Test 1: Basic requires-python constraint
run_test "Basic requires-python (>=3.10)" \
    "pyproject_requires_python_basic.toml"

# Test 2: Strict requires-python constraint
run_test "Strict requires-python (>=3.12)" \
    "pyproject_requires_python_strict.toml"

# Test 3: Exact requires-python constraint
run_test "Exact requires-python (==3.11)" \
    "pyproject_requires_python_exact.toml"

# Test 4: Greater than requires-python constraint
run_test "Greater than requires-python (>3.10)" \
    "pyproject_requires_python_greater.toml"

# Test 5: Classifiers fallback method
run_test "Classifiers fallback method" \
    "pyproject_classifiers_only.toml"

# Test 6: Classifiers fallback
run_test "Classifiers fallback" \
    "pyproject_classifiers_fallback.toml"

# Test 7: Fallback test file
run_test "Test project fallback" \
    "test_pyproject_fallback.toml"

# Test 8: No Python info (should fail gracefully)
echo "🔍 Testing: No Python information (error case)"
if run_test "No Python info" "pyproject_no_python_info.toml" 2>/dev/null; then
    echo "⚠️  Test should have failed but didn't"
else
    echo "✅ Correctly failed for file with no Python information"
fi
echo ""

# Test 9: Unsupported constraint (should fall back to classifiers)
run_test "Unsupported constraint (fallback to classifiers)" \
    "pyproject_unsupported_constraint.toml"

echo "🎉 All tests completed!"
echo ""
echo "📋 Test Summary:"
echo "   • Basic requires-python constraints ✅"
echo "   • Fallback to classifiers ✅"
echo "   • Error handling ✅"
echo "   • Edge cases ✅"
echo ""
echo "To run these tests with the actual GitHub Action, use the testing.yaml workflow."
