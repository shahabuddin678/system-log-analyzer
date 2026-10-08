#!/bin/bash

usage() {
    echo "Usage: $0 -f <log_file> -o <output_file>"
    echo
    echo "Options:"
    echo "  -f FILE    Input RISC-V test log"
    echo "  -o FILE    Output HTML report"
    echo "  -h         Display this help message"
}

error_exit() {
    echo "Error: $1" >&2
    exit 1
}

while getopts ":f:o:h" option; do
    case "$option" in
        f)
            LOG_FILE="$OPTARG"
            ;;
        o)
            OUTPUT_FILE="$OPTARG"
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

if [[ -z "$LOG_FILE" || -z "$OUTPUT_FILE" ]]; then
    usage
    exit 2
fi

if [[ ! -f "$LOG_FILE" ]]; then
    error_exit "File '$LOG_FILE' does not exist."
fi

if [[ ! -r "$LOG_FILE" ]]; then
    error_exit "File '$LOG_FILE' is not readable."
fi

total=$(grep -cE "TEST (PASS|FAIL|SKIP):" "$LOG_FILE")
passed=$(grep -c "TEST PASS:" "$LOG_FILE")
failed=$(grep -c "TEST FAIL:" "$LOG_FILE")
skipped=$(grep -c "TEST SKIP:" "$LOG_FILE")
errors=$(grep -c " ERROR:" "$LOG_FILE")

total_time=$(grep -oE '\([0-9]+(\.[0-9]+)?s\)' "$LOG_FILE" |
    tr -d '()s' |
    awk '{sum += $1} END {printf "%.2f", sum}')

if [[ "$total" -gt 0 ]]; then
    pass_rate=$(awk -v passed="$passed" -v total="$total" 'BEGIN {printf "%.1f", (passed / total) * 100}')
    average_time=$(awk -v total_time="$total_time" -v total="$total" 'BEGIN {printf "%.2f", total_time / total}')
else
    pass_rate="0.0"
    average_time="0.00"
fi

mkdir -p "$(dirname "$OUTPUT_FILE")"

cat > "$OUTPUT_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>RISC-V Test Log Report</title>
</head>
<body>

<h1>RISC-V Test Log Report</h1>

<h2>Summary</h2>

<table border="1" cellpadding="8">
<tr>
    <th>Metric</th>
    <th>Value</th>
</tr>
<tr>
    <td>Total Tests</td>
    <td>$total</td>
</tr>
<tr>
    <td>Passed</td>
    <td>$passed</td>
</tr>
<tr>
    <td>Failed</td>
    <td>$failed</td>
</tr>
<tr>
    <td>Skipped</td>
    <td>$skipped</td>
</tr>
<tr>
    <td>Errors</td>
    <td>$errors</td>
</tr>
<tr>
    <td>Pass Rate</td>
    <td>$pass_rate%</td>
</tr>
<tr>
    <td>Total Execution Time</td>
    <td>${total_time}s</td>
</tr>
<tr>
    <td>Average Test Time</td>
    <td>${average_time}s</td>
</tr>
</table>

<h2>Test Results</h2>

<table border="1" cellpadding="8">
<tr>
    <th>Status</th>
    <th>Test</th>
    <th>Duration</th>
</tr>
EOF

grep -E "TEST (PASS|FAIL|SKIP):" "$LOG_FILE" |
while IFS= read -r line; do
    if [[ "$line" =~ TEST[[:space:]](PASS|FAIL|SKIP):[[:space:]]([^[:space:]]+)[[:space:]]\(([0-9.]+s)\) ]]; then
        status="${BASH_REMATCH[1]}"
        test_name="${BASH_REMATCH[2]}"
        duration="${BASH_REMATCH[3]}"

        echo "<tr>" >> "$OUTPUT_FILE"
        echo "    <td>$status</td>" >> "$OUTPUT_FILE"
        echo "    <td>$test_name</td>" >> "$OUTPUT_FILE"
        echo "    <td>$duration</td>" >> "$OUTPUT_FILE"
        echo "</tr>" >> "$OUTPUT_FILE"
    fi
done

cat >> "$OUTPUT_FILE" <<EOF
</table>

<h2>Errors</h2>

<ul>
EOF

grep " ERROR:" "$LOG_FILE" |
while IFS= read -r line; do
    message="${line#*ERROR: }"
    echo "    <li>$message</li>" >> "$OUTPUT_FILE"
done

cat >> "$OUTPUT_FILE" <<EOF
</ul>

</body>
</html>
EOF

echo "HTML report generated: $OUTPUT_FILE"