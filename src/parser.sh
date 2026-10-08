#!/bin/bash

usage() {
    echo "Usage: $0 -f <log_file>"
    echo
    echo "Options:"
    echo "  -f FILE    Parse the specified log file"
    echo "  -h         Display this help message"
}

error_exit() {
    echo "Error: $1" >&2
    exit 1
}

parse_log() {
    local logfile="$1"

    echo "Log Analysis"
    echo "------------"

    echo "INFO: $(grep -c " INFO " "$logfile")"
    echo "WARNING: $(grep -c " WARNING " "$logfile")"
    echo "ERROR: $(grep -c " ERROR " "$logfile")"
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