#!/bin/bash
set -euo pipefail

echo "Step 1: Starting script"

if ! ping -c 1 8.8.8.8 &>/dev/null; then
    echo "ERROR: No network connectivity"
    exit 1
fi

echo "Step 2: Network is up"
echo "Step 3: Script completed successfully"
