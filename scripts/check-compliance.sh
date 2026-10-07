#!/usr/bin/env bash
# Run a local Prowler scan and print a redacted summary.
# Raw reports stay in ./prowler-results, which is gitignored.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${ROOT}/prowler-results"

if ! command -v prowler >/dev/null 2>&1; then
  echo "Prowler is not installed. Install it with: pip install prowler" >&2
  exit 1
fi

mkdir -p "${OUT}"

prowler aws --compliance cis_1.5_aws \
  --output-formats json \
  --output-directory "${OUT}"

mapfile -t reports < <(find "${OUT}" -type f -name 'prowler-output-*.json' ! -name '*.ocsf.json' | sort)
if [[ ${#reports[@]} -eq 0 ]]; then
  echo "No Prowler JSON report was written to ${OUT}" >&2
  exit 1
fi

python3 "${ROOT}/scripts/analyze-prowler.py" "${reports[-1]}"
echo
echo "Raw reports remain in ${OUT}. Do not commit them."
