# braid: Fault-Tolerant Quantum Compilation and Topological Error Correction
# Top-level Makefile for compilation, testing, and benchmarking

CC ?= clang
CFLAGS ?= -O3 -Wall -Wextra -pedantic -fPIC -std=c11
PYTHON ?= python3
GAP ?= gap

LIB_DIR = lib
SRC_DIR = src
BIN_DIR = bin
TST_DIR = tst
TOOLS_DIR = tools

FAST_TARGET = $(BIN_DIR)/libbraid_fast.dylib

all: check-style $(FAST_TARGET)

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

$(FAST_TARGET): $(SRC_DIR)/fast_tableau.c $(SRC_DIR)/fast_matching.c | $(BIN_DIR)
	$(CC) $(CFLAGS) -dynamiclib -o $@ $^

test: check-style
	@echo "Running GAP test suite..."
	$(PYTHON) $(TOOLS_DIR)/run_tests.py
	@echo "Running Python integration tests..."
	$(PYTHON) -m unittest discover -s $(TST_DIR) -p "test_*.py"

check-style:
	$(PYTHON) $(TOOLS_DIR)/check_em_dashes.py

clean:
	rm -rf $(BIN_DIR) *.o *.so *.dylib $(TST_DIR)/*.log build/ dist/ __pycache__ */__pycache__

bench: all
	$(PYTHON) $(TOOLS_DIR)/qasm_benchmark.py

.PHONY: all test check-style clean bench
