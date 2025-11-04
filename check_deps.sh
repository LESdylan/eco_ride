#!/bin/bash

VENV_DIR="${1:-.venv}"
REQ_FILE="requirements.txt"

if [ ! -d "$VENV_DIR" ]; then
    echo "[ERROR] Virtual environment not found. Run 'make venv' first."
    exit 1
fi

PIP="$VENV_DIR/bin/pip"
PYTHON="$VENV_DIR/bin/python"

if ! command -v $PIP &> /dev/null; then
    echo "[ERROR] pip not found in virtual environment."
    exit 1
fi

echo "[INFO] Installing dependencies from $REQ_FILE into $VENV_DIR..."
$PIP install -r $REQ_FILE
