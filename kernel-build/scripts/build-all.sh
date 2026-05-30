#!/bin/bash
# One-shot entry point: fetch → patch → build.
# Intended to be the Docker container's default invocation.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash "${ROOT}/scripts/fetch-sources.sh"
bash "${ROOT}/scripts/apply-patches.sh"
bash "${ROOT}/scripts/build.sh"
