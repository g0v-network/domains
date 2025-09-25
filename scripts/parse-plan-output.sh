#!/bin/bash
set -euo pipefail

# Parse octoDNS plan output for GitHub Actions
# Usage: parse-plan-output.sh <plan_file>

PLAN_FILE="$1"

# Parse plan output into $_plan
_plan="$(cat "${PLAN_FILE}")"
_plan="${_plan//'%'/'%25'}"
_plan="${_plan//$'\n'/'%0A'}"
_plan="${_plan//$'\r'/'%0D'}"

# Set output 'plan' to $_plan
echo "::set-output name=plan::${_plan}"