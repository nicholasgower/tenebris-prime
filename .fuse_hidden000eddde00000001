#!/bin/bash

# Get the current directory name
SCRIPT_DIR=$(basename "$(pwd)")

# Navigate to the parent directory
cd ..

# Create a compressed archive of the directory (including the folder itself)
tar --exclude="${SCRIPT_DIR}/.vscode" --exclude="${SCRIPT_DIR}/.git" -czf "${SCRIPT_DIR}.tar.gz" "${SCRIPT_DIR}"

echo "Packaged parent folder (${SCRIPT_DIR}) into ${SCRIPT_DIR}.tar.gz"
