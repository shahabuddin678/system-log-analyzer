SHELL := /bin/bash

SRC_DIR := src
TEST_DIR := tests
DATA_DIR := data

ANALYZER := $(SRC_DIR)/analyzer.sh
PARSER := $(SRC_DIR)/parser.sh
TEST_SCRIPT := $(TEST_DIR)/test_analyzer.sh

.PHONY: all test clean help

all:
	@echo "RISC-V Test Log Analyzer"
	@echo "Use 'make test' to run the test suite."

test:
	@echo "Running test suite..."
	@$(TEST_SCRIPT)

clean:
	@echo "Cleaning generated reports..."
	@rm -f reports/*.html

help:
	@echo "Available targets:"
	@echo "  make all    - Display project information"
	@echo "  make test   - Run the test suite"
	@echo "  make clean  - Remove generated reports"
	@echo "  make help   - Display this help message"

%.sh:
	@chmod +x $@