#!/usr/bin/env bash
# Fetches CI failure logs from a GitHub Actions workflow run.
# Writes the logs to a file (default: .claude/failure-logs.txt).
#
# Required env vars:
#   GH_TOKEN      — GitHub token with actions:read
#   GH_REPO       — owner/repo
#
# Optional env vars (provide one):
#   RUN_ID    — fetch logs from this specific run
#   PR_BRANCH — discover the latest failed run for this branch
#
# Optional:
#   LOG_OUTPUT_FILE — file path to write logs to (default: .claude/failure-logs.txt)
#
# Usage (in a workflow step):
#   env:
#     GH_TOKEN: ${{ github.token }}
#     GH_REPO: ${{ github.repository }}
#     RUN_ID: ${{ inputs.run_id }}
#   run: .ci-prompts/scripts/fetch-failure-logs.sh

set -euo pipefail

OUTPUT_FILE="${LOG_OUTPUT_FILE:-/tmp/failure-logs.txt}"
mkdir -p "$(dirname "$OUTPUT_FILE")"

RESOLVED_RUN_ID="${RUN_ID:-}"

# If no run ID provided, discover the latest failed run for the branch
if [ -z "$RESOLVED_RUN_ID" ] && [ -n "${PR_BRANCH:-}" ]; then
  RESOLVED_RUN_ID=$(gh run list \
    --branch "$PR_BRANCH" \
    --repo "$GH_REPO" \
    --status failure \
    --limit 1 \
    --json databaseId \
    --jq '.[0].databaseId // empty' 2>/dev/null || true)
fi

if [ -z "$RESOLVED_RUN_ID" ]; then
  echo "No recent CI failures found." > "$OUTPUT_FILE"
  exit 0
fi

# Try failed-only logs first, fall back to full logs
LOGS=$(gh run view "$RESOLVED_RUN_ID" \
  --repo "$GH_REPO" \
  --log-failed 2>&1) || true

if [ -z "$LOGS" ]; then
  LOGS=$(gh run view "$RESOLVED_RUN_ID" \
    --repo "$GH_REPO" \
    --log 2>&1) || true
fi

if [ -z "$LOGS" ]; then
  LOGS="No recent CI failures found."
fi

# Sanitize GitHub Actions log markers that could interfere with workflow commands
LOGS="${LOGS//##\[/\[}"

echo "$LOGS" > "$OUTPUT_FILE"
