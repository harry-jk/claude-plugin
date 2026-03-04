#!/bin/bash
# detect-git.sh - Detect git commands and prevent bash usage, redirect to MCP

set -euo pipefail

# Read hook input from stdin
input=$(cat)

# Extract command
command=$(echo "$input" | jq -r '.tool_input.command // empty')

# If no command, allow
if [ -z "$command" ]; then
  exit 0
fi

# Remove leading environment variables (VAR=value format)
# This handles: GIT_WORK_TREE=/path git add .
command_trimmed=$(echo "$command" | sed 's/^[A-Za-z_][A-Za-z_0-9]*=[^ ]* *//')

# Check if git appears as a command in any context
# Multiple patterns to catch all git execution scenarios:
#
# 1. Direct/piped/chained: git at start, after |, ;, &&, ||
pattern1='(^|[|;]|&&|\|\|)[[:space:]]*(sudo[[:space:]]+)?(/[^[:space:]]*/)?git[[:space:]]'
#
# 2. Command substitution: $(git ...) or `git ...`
pattern2='\$\([^)]*git[[:space:]]|\`[^`]*git[[:space:]]'
#
# 3. Parentheses/braces: (git) or { git or [git
pattern3='[(){}[][[:space:]]*(sudo[[:space:]]+)?(/[^[:space:]]*/)?git[[:space:]]'

if [[ "$command_trimmed" =~ $pattern1 ]] || \
   [[ "$command_trimmed" =~ $pattern2 ]] || \
   [[ "$command_trimmed" =~ $pattern3 ]]; then
  # Git command detected - deny and redirect to MCP
  echo "Git command detected and blocked. Use git MCP tools instead. Run /git-bash-prevention skill to see available git commands and MCP tool usage." >&2
  exit 2
fi

# Non-git bash commands are allowed
exit 0
