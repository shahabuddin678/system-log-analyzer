#!/bin/bash

set -o pipefail

usage() {
    echo "Usage: $0 -f <log_file>"
    echo
    echo "Options:"
    echo "  -f FILE    Analyze the specified log file"
    echo "  -h         Display this help message"
}

error_exit() {
    echo "Error: $1" >&2
    exit 1
}

analyze_log() {
    local logfile="$1"

    local total_lines
    local info_count
    local warning_count
    local error_count

    total_lines=$(wc -l < "$logfile")
    info_count=$(grep -c " INFO " "$logfile")
    warning_count=$(grep -c " WARNING " "$logfile")
    error_count=$(grep -c " ERROR " "$logfile")

    echo "======================================"
    echo "       SYSTEM LOG ANALYZER"
    echo "======================================"
    echo
    echo "Log File         : $logfile"
    echo "Total Lines      : $total_lines"
    echo "INFO Messages    : $info_count"
    echo "WARNING Messages : $warning_count"
    echo "ERROR Messages   : $error_count"
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