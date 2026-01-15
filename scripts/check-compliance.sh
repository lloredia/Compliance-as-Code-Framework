#!/bin/bash
# Quick compliance check script

set -e

echo "🔍 Running Compliance Check..."
echo ""

# Check if prowler is installed
if ! command -v prowler &> /dev/null; then
    echo "❌ Prowler not found. Installing..."
    pip install prowler
fi

# Run Prowler scan
echo "📊 Running Prowler CIS scan..."
prowler aws --compliance cis_1.5_aws \
    --output-formats json csv \
    --output-directory ./prowler-results

echo ""
echo "✅ Scan complete! Results saved to ./prowler-results/"
echo ""

# Analyze results
if [ -f "./scripts/analyze-prowler.py" ]; then
    echo "📈 Analyzing results..."
    python3 ./scripts/analyze-prowler.py ./prowler-results/prowler-output-*.json
else
    echo "⚠️  Analysis script not found. Check prowler-results/ directory for reports."
fi
