#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

usage() {
    echo "Usage:"
    echo "  $0 -f <log_file>"
    echo "  $0 --compare <log_file1> <log_file2>"
    echo
    echo "Options:"
    echo "  -f FILE                  Analyze a RISC-V test log"
    echo "  -h                       Display this help message"
    echo "  --compare FILE1 FILE2    Compare two RISC-V test logs"
}

error_exit() {
    echo "Error: $1" >&2
    exit 1
}

analyze_log() {
    local logfile="$1"

    local total
    local passed
    local failed
    local skipped
    local errors
    local pass_rate
    local total_time
    local average_time

    total=$(grep -cE "TEST (PASS|FAIL|SKIP):" "$logfile")
    passed=$(grep -c "TEST PASS:" "$logfile")
    failed=$(grep -c "TEST FAIL:" "$logfile")
    skipped=$(grep -c "TEST SKIP:" "$logfile")
    errors=$(grep -c " ERROR:" "$logfile")

    total_time=$(grep -oE '\([0-9]+(\.[0-9]+)?s\)' "$logfile" |
        tr -d '()s' |
        awk '{sum += $1} END {printf "%.2f", sum}')

    if [[ "$total" -gt 0 ]]; then
        pass_rate=$((passed * 100 / total))
        average_time=$(awk -v total="$total_time" -v count="$total" \
            'BEGIN {printf "%.2f", total / count}')
    else
        pass_rate=0
        average_time="0.00"
    fi

    echo "======================================"
    echo "       RISC-V TEST LOG ANALYZER"
    echo "======================================"
    echo
    echo "Log File       : $logfile"
    echo "Total Tests    : $total"
    echo -e "${GREEN}Passed Tests   : $passed${NC}"
    echo -e "${RED}Failed Tests   : $failed${NC}"
    echo -e "${YELLOW}Skipped Tests  : $skipped${NC}"
    echo -e "${RED}Errors         : $errors${NC}"
    echo "Pass Rate      : ${pass_rate}%"
    echo "Total Time     : ${total_time}s"
    echo "Average Time   : ${average_time}s"
    echo
    echo "======================================"
}

compare_logs() {
    local file1="$1"
    local file2="$2"

    local passed1
    local passed2
    local failed1
    local failed2
    local skipped1
    local skipped2

    passed1=$(grep -c "TEST PASS:" "$file1")
    passed2=$(grep -c "TEST PASS:" "$file2")
    failed1=$(grep -c "TEST FAIL:" "$file1")
    failed2=$(grep -c "TEST FAIL:" "$file2")
    skipped1=$(grep -c "TEST SKIP:" "$file1")
    skipped2=$(grep -c "TEST SKIP:" "$file2")

    echo "======================================"
    echo "          RISC-V LOG COMPARISON"
    echo "======================================"
    echo
    echo "File 1: $file1"
    echo "Passed : $passed1"
    echo "Failed : $failed1"
    echo "Skipped: $skipped1"
    echo
    echo "File 2: $file2"
    echo "Passed : $passed2"
    echo "Failed : $failed2"
    echo "Skipped: $skipped2"
    echo
    echo "Changes:"
    echo "Passed : $((passed2 - passed1))"
    echo "Failed : $((failed2 - failed1))"
    echo "Skipped: $((skipped2 - skipped1))"
    echo
    echo "======================================"
}

if [[ "$1" == "--compare" ]]; then
    if [[ $# -ne 3 ]]; then
        echo "Error: --compare requires two log files." >&2
        usage
        exit 2
    fi

    if [[ ! -f "$2" ]]; then
        error_exit "File '$2' does not exist."
    fi

    if [[ ! -f "$3" ]]; then
        error_exit "File '$3' does not exist."
    fi

    if [[ ! -r "$2" || ! -r "$3" ]]; then
        error_exit "One or both files are not readable."
    fi

    compare_logs "$2" "$3"
    exit 0
fi

while getopts ":f:h" option; do
    case "$option" in
        f)
            LOG_FILE="$OPTARG"
            ;;
        h)
            usage
            exit 0
            ;;
        :)
            echo "Error: Option -$OPTARG requires an argument." >&2
            usage
            exit 2
            ;;
        \?)
            echo "Error: Invalid option -$OPTARG" >&2
            usage
            exit 2
            ;;
    esac
done

if [[ -z "$LOG_FILE" ]]; then
    usage
    exit 2
fi

if [[ ! -f "$LOG_FILE" ]]; then
    error_exit "File '$LOG_FILE' does not exist."
fi

if [[ ! -r "$LOG_FILE" ]]; then
    error_exit "File '$LOG_FILE' is not readable."
fi

analyze_log "$LOG_FILE"

exit 0