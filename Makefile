SHELL := /bin/bash

SRC_DIR := src
TEST_DIR := tests
DATA_DIR := data

ANALYZER := $(SRC_DIR)/analyzer.sh
PARSER := $(SRC_DIR)/parser.sh
REPORTER := $(SRC_DIR)/report.sh
TEST_SCRIPT := $(TEST_DIR)/test_analyzer.sh

.PHONY: all test report clean help

all:
	@echo "RISC-V Test Log Analyzer"
	@echo "Use 'make test' to run the test suite."
	@echo "Use 'make report' to generate an HTML report."

test:
	@echo "Running test suite..."
	@$(TEST_SCRIPT)

report:
	@echo "Generating HTML report..."
	@$(REPORTER) -f $(DATA_DIR)/sample.log -o reports/sample.html

clean:
	@echo "Cleaning generated reports..."
	@rm -f reports/*.html

help:
	@echo "Available targets:"
	@echo "  make all    - Display project information"
	@echo "  make test   - Run the test suite"
	@echo "  make report - Generate an HTML report"
	@echo "  make clean  - Remove generated reports"
	@echo "  make help   - Display this help message"

%.sh:
	@chmod +x $@