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

run_test "Analyzer processes sample log" \
    ./src/analyzer.sh -f data/sample.log

run_test "Analyzer help option" \
    ./src/analyzer.sh -h

if ./src/analyzer.sh -f data/notfound.log > /dev/null 2>&1; then
    echo "FAIL: Missing file should return an error"
    ((FAIL++))
else
    echo "PASS: Missing file handling"
    ((PASS++))
fi

if ./src/parser.sh -f data/sample.log > /dev/null 2>&1; then
    echo "PASS: Parser processes sample log"
    ((PASS++))
else
    echo "FAIL: Parser processes sample log"
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