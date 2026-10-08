# RISC-V Test Log Analyzer

A Bash-based RISC-V test log analyzer with HTML reporting.

## Features

- Parses RISC-V test logs
- Counts passed, failed, skipped, and error entries
- Calculates pass rate
- Calculates total and average execution time
- Compares two log files
- Generates HTML reports
- Handles command-line arguments and errors
- Includes automated tests
- Provides Makefile commands
- Supports Git-based development workflow

## Project Structure

```text
system-log-analyzer/
├── src/
│   ├── analyzer.sh
│   ├── parser.sh
│   └── report.sh
├── tests/
│   └── test_analyzer.sh
├── data/
│   ├── sample.log
│   └── sample2.log
├── reports/
├── Makefile
├── README.md
├── USAGE.md
└── .gitignore