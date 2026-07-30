#!/bin/bash

# Card-Scout Setup — macOS
# Double-click this file in Finder to run setup.
# If macOS asks "Are you sure you want to open it?" — click Open.

# Change to the folder containing this script so relative paths work
cd "$(dirname "$0")"

echo ""
echo "============================================================"
echo "  Umesh's Card-Scout — Setup"
echo "============================================================"
echo ""

# ── Step 1: Check Python 3 ────────────────────────────────────
echo "[1/3] Checking for Python 3..."

if command -v python3 &>/dev/null; then
    PYVER=$(python3 --version 2>&1)
    echo "      Found: $PYVER"
else
    echo ""
    echo "  ERROR: Python 3 was not found."
    echo ""
    echo "  On modern Macs, Python 3 should already be available."
    echo "  If not, install it from:"
    echo "    https://www.python.org/downloads/"
    echo ""
    echo "  After installing, close this window and double-click setup.command again."
    echo ""
    read -n 1 -s -r -p "  Press any key to close..."
    echo ""
    exit 1
fi

# ── Step 2: Install Python libraries ─────────────────────────
echo ""
echo "[2/3] Installing required Python libraries..."
echo "      (openpyxl and Pillow — this may take a minute)"
echo ""

python3 -m pip install -r requirements.txt
PIP_EXIT=$?

if [ $PIP_EXIT -ne 0 ]; then
    # Try pip3 directly as fallback
    pip3 install -r requirements.txt
    PIP_EXIT=$?
fi

if [ $PIP_EXIT -ne 0 ]; then
    echo ""
    echo "  ERROR: Library installation failed."
    echo "  Check your internet connection and try again."
    echo "  If the problem persists, run this in Terminal:"
    echo "    pip3 install openpyxl Pillow"
    echo ""
    read -n 1 -s -r -p "  Press any key to close..."
    echo ""
    exit 1
fi

echo ""
echo "      Libraries installed successfully."

# ── Step 3: Check Claude Code ────────────────────────────────
echo ""
echo "[3/3] Checking for Claude Code..."

if command -v claude &>/dev/null; then
    CLAUDEVER=$(claude --version 2>&1 | head -1)
    echo "      Found: $CLAUDEVER"
else
    echo ""
    echo "  ERROR: The 'claude' command was not found."
    echo ""
    echo "  Please install Claude Code from:"
    echo "    https://claude.ai/code"
    echo ""
    echo "  After installing, close this window and double-click setup.command again."
    echo ""
    read -n 1 -s -r -p "  Press any key to close..."
    echo ""
    exit 1
fi

# ── All done ─────────────────────────────────────────────────
echo ""
echo "============================================================"
echo "  Setup complete!"
echo "============================================================"
echo ""
echo "  Next steps:"
echo "    1. Open Terminal in this folder"
echo "    2. Type:  claude"
echo "    3. Then type:  /scan-card inbox/yourfile.jpg"
echo ""
echo "  The full usage guide is in README.md"
echo ""
read -n 1 -s -r -p "  Press any key to close..."
echo ""
