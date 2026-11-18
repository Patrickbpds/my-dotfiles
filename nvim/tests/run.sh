#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
nvim --headless -u NONE -l tests/java_utils_spec.lua
