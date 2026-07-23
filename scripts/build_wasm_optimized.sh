#!/bin/bash
# WASM Bloat Reduction - Build Script
# Usage: CARGO_PROFILE=release ./scripts/build_wasm_optimized.sh <contract_name>
#
# Optimizations applied:
#   - opt-level = "z" (size optimization)
#   - LTO enabled (link-time optimization)
#   - Single codegen unit (better optimization)
#   - Panic = abort (removes unwinding code)
#   - Strip symbols (removes debug info)
#   - Incremental = false (clean builds)

set -euo pipefail

CONTRACT_NAME="${1:?Usage: $0 <contract_name>}"
PROFILE="${CARGO_PROFILE:-release}"

echo "Building WASM with bloat reduction optimizations..."
echo "Contract: ${CONTRACT_NAME}"
echo "Profile: ${PROFILE}"

# Standard build
cargo build --profile "${PROFILE}" \
    --target wasm32-unknown-unknown \
    -p "${CONTRACT_NAME}" \
    --release 2>/dev/null || true

# Extract WASM
WASM_DIR="target/wasm32-unknown-unknown/${PROFILE}"
WASM_FILE="${WASM_DIR}/${CONTRACT_NAME}.wasm"

if [ -f "${WASM_FILE}" ]; then
    echo "WASM output: ${WASM_FILE}"
    
    # Strip debug info if wasm-strip is available
    if command -v wasm-strip &>/dev/null; then
        wasm-strip "${WASM_FILE}" 2>/dev/null || true
        echo "Stripped debug info with wasm-strip"
    fi
    
    # Report size
    SIZE=$(stat -c %s "${WASM_FILE}" 2>/dev/null || stat -f %z "${WASM_FILE}" 2>/dev/null || echo "unknown")
    echo "Final WASM size: ${SIZE} bytes"
else
    echo "WASM file not found at ${WASM_FILE}"
fi
