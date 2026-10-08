#!/bin/bash

usage() {
    echo "Usage: $0 -f <log_file>"
    echo
    echo "Options:"
    echo "  -f FILE    Parse the specified RISC-V test log"
    echo "  -h         Display this help message"
}

error_exit() {
    echo "Error: $1" >&2
    exit 1
}

parse_log() {
    local logfile="$1"

    local starts
    local passed
    local failed
    local skipped
    local errors

    starts=$(grep -c "TEST START:" "$logfile")
    passed=$(grep -c "TEST PASS:" "$logfile")
    failed=$(grep -c "TEST FAIL:" "$logfile")
    skipped=$(grep -c "TEST SKIP:" "$logfile")
    errors=$(grep -c " ERROR:" "$logfile")

    echo "RISC-V Test Log Analysis"
    echo "========================"
    echo
    echo "Tests Started : $starts"
    echo "Tests Passed  : $passed"
    echo "Tests Failed  : $failed"
    echo "Tests Skipped : $skipped"
    echo "Errors        : $errors"
    echo

    echo "Test Results"
    echo "------------"
    grep -E "TEST (PASS|FAIL|SKIP):" "$logfile" |
        sed -E 's/.*TEST (PASS|FAIL|SKIP): ([^ ]+) \(([^)]*)\)/\1 | \2 | \3/'

    echo
    echo "Failed Tests"
    echo "------------"
    grep "TEST FAIL:" "$logfile" |
        sed -E 's/.*TEST FAIL: ([^ ]+) \(([^)]*)\)/- \1 (\2)/'

    echo
    echo "Errors"
    echo "------"
    grep " ERROR:" "$logfile" |
        sed 's/.*ERROR: /- /'
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

parse_log "$LOG_FILE"

exit 0