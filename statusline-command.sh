#!/bin/bash

# Read JSON input
input=$(cat)

# Extract values from JSON (without jq)
cwd=$(echo "$input" | sed -n 's/.*"current_dir":"\([^"]*\)".*/\1/p')

# Claude.ai subscription usage (rate limits), when present
five_hour_pct=$(echo "$input" | sed -n 's/.*"five_hour":{"used_percentage":\([0-9.]*\).*/\1/p')
seven_day_pct=$(echo "$input" | sed -n 's/.*"seven_day":{"used_percentage":\([0-9.]*\).*/\1/p')

rate_info=""
if [ -n "$five_hour_pct" ]; then
  rate_info="5h:$(printf '%.0f' "$five_hour_pct")%"
fi
if [ -n "$seven_day_pct" ]; then
  [ -n "$rate_info" ] && rate_info="$rate_info "
  rate_info="${rate_info}7d:$(printf '%.0f' "$seven_day_pct")%"
fi

# Git information (skip optional locks for performance)
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  # Get repo name relative to ~/Documents/
  repo_name=$(echo "$cwd" | sed "s|^$HOME/Documents/||")

  # Get branch
  branch=$(git -C "$cwd" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)

  printf '\033[01;36m%s\033[00m | \033[01;32m%s\033[00m' \
    "$repo_name" "$branch"
else
  # Not a git repo
  printf '\033[01;36m%s\033[00m' "$cwd"
fi

if [ -n "$rate_info" ]; then
  printf ' | \033[01;33m%s\033[00m' "$rate_info"
fi
