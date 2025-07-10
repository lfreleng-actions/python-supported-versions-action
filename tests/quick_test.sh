#!/bin/bash

# SPDX-License-Identifier: Apache-2.0
# SPDX-FileCopyrightText: 2025 The Linux Foundation

# Quick test script to validate the action logic
echo "Testing Python supported versions action..."

# Test requires-python extraction
TEST_FILE="pyproject_requires_python_basic.toml"
echo "Testing with file: $TEST_FILE"

# Extract requires-python
REQUIRES_PYTHON_RAW=$(grep -E '^[[:space:]]*requires-python[[:space:]]*=' "$TEST_FILE" | head -1)
echo "Raw requires-python line: $REQUIRES_PYTHON_RAW"

if [ -n "$REQUIRES_PYTHON_RAW" ]; then
  # Extract the value from requires-python = "value" format
  REQUIRES_PYTHON="${REQUIRES_PYTHON_RAW##*\"}"
  REQUIRES_PYTHON="${REQUIRES_PYTHON%%\"*}"
  echo "Found requires-python constraint: $REQUIRES_PYTHON"

  # Test version parsing
  ALL_SUPPORTED_VERSIONS="3.10 3.11 3.12 3.13 3.14"
  PYTHON_VERSIONS=""

  # Simple pattern matching for >=X.Y format
  if echo "$REQUIRES_PYTHON" | grep -q "^>="; then
    MIN_VERSION="${REQUIRES_PYTHON#>=}"
    MIN_VERSION="${MIN_VERSION%%.*}.${MIN_VERSION#*.}"
    echo "Minimum version: $MIN_VERSION"

    for version in $ALL_SUPPORTED_VERSIONS; do
      if [[ "$(printf '%s\n' "$MIN_VERSION" "$version" | sort -V | head -n1)" == "$MIN_VERSION" ]]; then
        PYTHON_VERSIONS="$PYTHON_VERSIONS $version"
      fi
    done
  fi

  echo "Extracted versions: $PYTHON_VERSIONS"

  # Test matrix JSON generation
  if [ -n "$PYTHON_VERSIONS" ]; then
    MATRIX_JSON='{"python-version": ['
    first=true
    for version in $PYTHON_VERSIONS; do
      if [ "$first" = true ]; then
        first=false
      else
        MATRIX_JSON+=","
      fi
      MATRIX_JSON+="\"$version\""
    done
    MATRIX_JSON+=']}'
    echo "Matrix JSON: $MATRIX_JSON"
  fi
else
  echo "No requires-python found!"
fi

echo "Test completed!"
