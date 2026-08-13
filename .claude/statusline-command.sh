#!/usr/bin/env bash

input=$(cat)

# claude-swap points CLAUDE_CONFIG_DIR at a per-account directory, and Claude Code
# keeps .claude.json inside it rather than in $HOME.
if [[ -n "$CLAUDE_CONFIG_DIR" ]]; then
  config_dir="$CLAUDE_CONFIG_DIR"
  config_json="$CLAUDE_CONFIG_DIR/.claude.json"
else
  config_dir="$HOME/.claude"
  config_json="$HOME/.claude.json"
fi

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

function format_duration_until {
  local resets_at="$1" now seconds days hours minutes

  [[ -z "$resets_at" ]] && return

  now=$(date +%s)
  if [[ "$resets_at" =~ ^[0-9]+$ ]]; then
    seconds=$((resets_at - now))
  else
    seconds=$(($(date -d "$resets_at" +%s 2>/dev/null || echo "$now") - now))
  fi

  if [[ $seconds -le 0 ]]; then
    echo "now"
    return
  fi

  days=$((seconds / 86400))
  hours=$((seconds % 86400 / 3600))
  minutes=$((seconds % 3600 / 60))

  if [[ $days -gt 0 ]]; then
    echo "${days}d${hours}h"
  elif [[ $hours -gt 0 ]]; then
    echo "${hours}h${minutes}m"
  else
    echo "${minutes}m"
  fi
}

function format_quota {
  local percent="$1" resets_at="$2" countdown

  [[ -z "$percent" ]] && return

  countdown=$(format_duration_until "$resets_at")
  if [[ -n "$countdown" ]]; then
    echo "${percent}% (${countdown})"
  else
    echo "${percent}%"
  fi
}

function refresh_usage_cache {
  local cache="$1" credentials="$config_dir/.credentials.json" token

  [[ -f "$credentials" ]] || return
  if [[ -f "$cache" && $(($(date +%s) - $(stat -c %Y "$cache"))) -lt 300 ]]; then
    return
  fi

  token=$(jq -r '.claudeAiOauth.accessToken // empty' "$credentials" 2>/dev/null)
  [[ -z "$token" ]] && return

  if curl -sSf -m 2 -o "$cache.tmp" \
      -H "Authorization: Bearer $token" \
      -H "anthropic-beta: oauth-2025-04-20" \
      https://api.anthropic.com/api/oauth/usage 2>/dev/null; then
    mv "$cache.tmp" "$cache"
  else
    rm -f "$cache.tmp"
  fi
}

function fable_quota_from_usage_cache {
  local cache="$config_dir/statusline-usage-cache.json"

  refresh_usage_cache "$cache"
  [[ -f "$cache" ]] || return

  jq -r '
    (.limits // [])
    | map(select(.kind == "weekly_scoped"
                 and ((.scope.model.display_name // "") | ascii_downcase) == "fable"))
    | first // empty
    | ((.percent | round | tostring), (.resets_at // ""))
  ' "$cache" 2>/dev/null
}

function join_with {
  local separator="$1" joined
  shift
  [[ $# -eq 0 ]] && return
  joined=$(printf "${separator}%s" "$@")
  echo "${joined:${#separator}}"
}

mapfile -t status < <(jq -r '
    def percent: if type == "number" then (round | tostring) else "" end;
    def moment: if type == "number" or type == "string" then tostring else "" end;
    def quota: (. // {}) | [((.used_percentage // .utilization) | percent), (.resets_at | moment)];

    (.rate_limits // {}) as $limits
    | (.context_window.current_usage // {}) as $usage
    | (($limits.model_scoped // [])
       | map(select((.display_name // "" | ascii_downcase) == "fable"))
       | first) as $fable
    | [
        (.workspace.current_dir // .cwd // ""),
        (($usage.input_tokens // 0) + ($usage.cache_creation_input_tokens // 0) + ($usage.cache_read_input_tokens // 0)),
        (.context_window.context_window_size // 200000),
        (.model.display_name // ""),
        (.effort.level // "")
      ]
      + ($limits.five_hour | quota)
      + ($limits.seven_day | quota)
      + (($fable // $limits.seven_day_fable // $limits.seven_day_opus) | quota)
    | .[]
  ' <<< "$input")

cwd=${status[0]}
used=${status[1]}
context_size=${status[2]}
model=${status[3]}
effort=${status[4]}
five_hour_pct=${status[5]}
five_hour_reset=${status[6]}
seven_day_pct=${status[7]}
seven_day_reset=${status[8]}
fable_pct=${status[9]}
fable_reset=${status[10]}

if [[ -z "$fable_pct" ]]; then
  mapfile -t fable_quota < <(fable_quota_from_usage_cache)
  fable_pct=${fable_quota[0]}
  fable_reset=${fable_quota[1]}
fi

dir=$(basename "$cwd")
branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)

used=${used:-0}
context_pct=0
if [[ ${context_size:-0} -gt 0 ]]; then
  context_pct=$((used * 100 / context_size))
fi

if [[ $used -ge 1000 ]]; then
  used_fmt="$((used / 1000))k"
else
  used_fmt="$used"
fi

segments=()

if [[ -n "$branch" ]]; then
  segments+=("$dir ($branch)")
else
  segments+=("$dir")
fi

segments+=("${used_fmt} (${context_pct}%)")

quotas=()
for window in "$five_hour_pct|$five_hour_reset" "$seven_day_pct|$seven_day_reset" "$fable_pct|$fable_reset"; do
  quota=$(format_quota "${window%%|*}" "${window#*|}")
  [[ -n "$quota" ]] && quotas+=("$quota")
done
[[ ${#quotas[@]} -gt 0 ]] && segments+=("$(join_with ", " "${quotas[@]}")")

[[ -n "$effort" ]] && model="$model $effort"
[[ -n "$model" ]] && segments+=("$model")

email=$(jq -r '.oauthAccount.emailAddress // empty' "$config_json" 2>/dev/null)
[[ -n "$email" ]] && segments+=("$email")

highest_pct=$context_pct
for percent in "$five_hour_pct" "$seven_day_pct" "$fable_pct"; do
  [[ -n "$percent" && $percent -gt $highest_pct ]] && highest_pct=$percent
done

if [[ $highest_pct -ge 80 ]]; then
  color="\033[91m"  # bright red
  prefix="⚠ "
else
  color="\033[90m"  # grey
  prefix=""
fi

set_claude_code_window_title
echo -ne "${color}${prefix}$(join_with " | " "${segments[@]}")\033[0m"
