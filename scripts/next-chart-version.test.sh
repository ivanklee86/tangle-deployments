#!/usr/bin/env bash
# Truth table for next-chart-version.sh.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${SCRIPT_DIR}/next-chart-version.sh"

FAILURES=0

expect_ok() {
  local prev_app="$1" new_app="$2" chart="$3" want_type="$4" want_chart="$5"
  local got
  if ! got="$("$TARGET" "$prev_app" "$new_app" "$chart")"; then
    echo "FAIL ${prev_app} -> ${new_app} (chart ${chart}): expected success, got error"
    FAILURES=$((FAILURES + 1))
    return
  fi
  if [ "$got" != "${want_type} ${want_chart}" ]; then
    echo "FAIL ${prev_app} -> ${new_app} (chart ${chart}): got '${got}', want '${want_type} ${want_chart}'"
    FAILURES=$((FAILURES + 1))
    return
  fi
  echo "ok   ${prev_app} -> ${new_app} (chart ${chart}): ${got}"
}

expect_fail() {
  local prev_app="$1" new_app="$2" chart="$3"
  if "$TARGET" "$prev_app" "$new_app" "$chart" >/dev/null 2>&1; then
    echo "FAIL ${prev_app} -> ${new_app} (chart ${chart}): expected failure, got success"
    FAILURES=$((FAILURES + 1))
    return
  fi
  echo "ok   ${prev_app} -> ${new_app} (chart ${chart}): rejected as expected"
}

expect_ok   0.3.2 0.3.3 0.2.0 patch 0.2.1   # app patch -> chart patch
expect_ok   0.3.2 0.4.0 0.2.0 minor 0.3.0   # app minor -> chart minor
expect_ok   0.3.2 1.0.0 0.2.0 major 1.0.0   # app major -> chart major
expect_ok   1.2.3 1.3.0 2.2.0 minor 2.3.0   # the example from the request
expect_ok   1.2.3 2.0.0 1.4.7 major 2.0.0   # major resets minor and patch
expect_fail 0.3.2 0.3.2 0.2.0               # replayed dispatch
expect_fail 0.4.0 0.3.9 0.2.0               # downgrade
expect_fail 0.3.2 not-a-version 0.2.0       # malformed payload

if [ "$FAILURES" -ne 0 ]; then
  echo "${FAILURES} test(s) failed"
  exit 1
fi

echo "all tests passed"
