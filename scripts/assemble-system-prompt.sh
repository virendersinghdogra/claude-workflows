#!/usr/bin/env bash
# Assembles the CI system prompt from a preamble, ci-common.md, and optional extra instructions.
# Sets APPEND_SYSTEM_PROMPT in $GITHUB_ENV for claude-code-action.
#
# Required env vars:
#   SYSTEM_PROMPT_PREAMBLE — workflow-specific opening line
#   GITHUB_ENV             — GitHub Actions env file (set automatically)
#
# Optional env vars:
#   EXTRA_SYSTEM_PROMPT — extra instructions appended after ci-common.md
#
# Usage (in a workflow step):
#   env:
#     SYSTEM_PROMPT_PREAMBLE: "You are fixing a CI failure. Be precise and methodical."
#     EXTRA_SYSTEM_PROMPT: ${{ inputs.extra_system_prompt }}
#   run: .ci-prompts/scripts/assemble-system-prompt.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CI_COMMON="${SCRIPT_DIR}/../prompts/ci-common.md"

if [ -z "${SYSTEM_PROMPT_PREAMBLE:-}" ]; then
  echo "::error::SYSTEM_PROMPT_PREAMBLE is required"
  exit 1
fi

if [ ! -f "$CI_COMMON" ]; then
  echo "::error::ci-common.md not found at ${CI_COMMON}"
  exit 1
fi

{
  echo "$SYSTEM_PROMPT_PREAMBLE"
  echo ""
  cat "$CI_COMMON"
  if [ -n "${EXTRA_SYSTEM_PROMPT:-}" ]; then
    printf '\n%s\n' "$EXTRA_SYSTEM_PROMPT"
  fi
} > /tmp/ci-system-prompt.md

{
  echo "APPEND_SYSTEM_PROMPT<<__CI_PROMPT_EOF__"
  cat /tmp/ci-system-prompt.md
  echo "__CI_PROMPT_EOF__"
} >> "$GITHUB_ENV"
