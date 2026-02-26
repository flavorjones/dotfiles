#!/usr/bin/env bash

input=$(cat)

# copied from .bashrc_generic
function ps1_working_directory {
  if [[ -n "${GOPATH}" && $PWD =~ "${GOPATH}/src" ]] ; then
    echo "(${gvm_go_name}) $(realpath --relative-to "${GOPATH}/src" "${PWD}")"
  elif [[ $PWD == $HOME ]] ; then
    echo "~"
  elif GITDIR=$(git rev-parse --show-toplevel 2> /dev/null) ; then
    if [[ ${PWD} == ${GITDIR} ]] ; then
      basename "${GITDIR}"
    else
      echo "$(basename "${GITDIR}")/$(realpath --relative-to "${GITDIR}" "${PWD}")"
    fi
  elif [[ $PWD =~ "${HOME}/" ]] ; then
    echo "~/$(realpath --relative-to "${HOME}" "${PWD}")"
  else
    echo $PWD
  fi
}

function set_claude_code_window_title {
  echo -ne "\033]0;🤖 $(ps1_working_directory)\007" > /dev/tty
}

# Short directory name (just the last component)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
dir=$(basename "$cwd")

# Git branch (if in a git repo)
branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)

# Context window info (current usage vs context window size)
# Use current_usage which reflects actual context and resets on /clear
current_input=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
cache_creation=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cache_read=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
total_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')

used=$((current_input + cache_creation + cache_read))

# Calculate percentage
if [[ $total_size -gt 0 ]]; then
  pct=$((used * 100 / total_size))
else
  pct=0
fi

# Format tokens (e.g., 45000 -> 45k)
if [[ $used -ge 1000 ]]; then
  used_fmt="$((used / 1000))k"
else
  used_fmt="$used"
fi

if [[ $pct -ge 80 ]]; then
  color="\033[91m"  # bright red
  prefix="⚠ "
else
  color="\033[90m"  # grey
  prefix=""
fi

# Build output
set_claude_code_window_title
if [[ -n "$branch" ]]; then
  echo -ne "${color}${prefix}$dir ($branch) | ${used_fmt} tokens (${pct}%)\033[0m"
else
  echo -ne "${color}${prefix}$dir | ${used_fmt} tokens (${pct}%)\033[0m\033[0m"
fi
