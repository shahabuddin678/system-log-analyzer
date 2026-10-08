#!/bin/bash

PASS=0
FAIL=0

run_test() {
    local name="$1"
    shift

    if "$@" > /dev/null 2>&1; then
        echo "PASS: $name"
        ((PASS++))
    else
        echo "FAIL: $name"
        ((FAIL++))
    fi
}

# Basic analyzer test
run_test "Analyzer processes sample log" \
    ./src/analyzer.sh -f data/sample.log

# Help option
run_test "Analyzer help option" \
    ./src/analyzer.sh -h

# Parser test
run_test "Parser processes sample log" \
    ./src/parser.sh -f data/sample.log

# Parser help option
run_test "Parser help option" \
    ./src/parser.sh -h

# Missing file handling
if ./src/analyzer.sh -f data/notfound.log > /dev/null 2>&1; then
    echo "FAIL: Missing file handling"
    ((FAIL++))
else
    echo "PASS: Missing file handling"
    ((PASS++))
fi

# Invalid option handling
if ./src/analyzer.sh -x > /dev/null 2>&1; then
    echo "FAIL: Invalid option handling"
    ((FAIL++))
else
    echo "PASS: Invalid option handling"
    ((PASS++))
fi

# Compare feature
run_test "Compare two RISC-V logs" \
    ./src/analyzer.sh --compare data/sample.log data/sample2.log

# Verify expected sample counts
output=$(./src/analyzer.sh -f data/sample.log)

if echo "$output" | grep -q "Total Tests    : 25"; then
    echo "PASS: Correct total test count"
    ((PASS++))
else
    echo "FAIL: Correct total test count"
    ((FAIL++))
fi

if echo "$output" | grep -q "Passed Tests   : 22"; then
    echo "PASS: Correct passed test count"
    ((PASS++))
else
    echo "FAIL: Correct passed test count"
    ((FAIL++))
fi

if echo "$output" | grep -q "Failed Tests   : 2"; then
    echo "PASS: Correct failed test count"
    ((PASS++))
else
    echo "FAIL: Correct failed test count"
    ((FAIL++))
fi

if echo "$output" | grep -q "Skipped Tests  : 1"; then
    echo "PASS: Correct skipped test count"
    ((PASS++))
else
    echo "FAIL: Correct skipped test count"
    ((FAIL++))
fi

echo
echo "Test Results"
echo "------------"
echo "Passed: $PASS"
echo "Failed: $FAIL"

if [[ "$FAIL" -eq 0 ]]; then
    exit 0
else
    exit 1
fi