#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

usage() {
    echo "Usage: $0 -f <log_file>"
    echo
    echo "Options:"
    echo "  -f FILE    Analyze the specified RISC-V test log"
    echo "  -h         Display this help message"
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

    total=$(grep -c "TEST \(PASS\|FAIL\|SKIP\):" "$logfile")
    passed=$(grep -c "TEST PASS:" "$logfile")
    failed=$(grep -c "TEST FAIL:" "$logfile")
    skipped=$(grep -c "TEST SKIP:" "$logfile")
    errors=$(grep -c " ERROR:" "$logfile")

    if [[ "$total" -gt 0 ]]; then
        pass_rate=$((passed * 100 / total))
    else
        pass_rate=0
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
    echo
    echo "======================================"
}

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