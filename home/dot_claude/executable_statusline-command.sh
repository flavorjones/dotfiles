#!/usr/bin/env bash

input=$(cat)

GREY='\033[90m'
RED='\033[91m'
UNCOLORED='\033[0m'

# claude-swap points CLAUDE_CONFIG_DIR at a per-account directory, and Claude Code
# keeps .claude.json inside it rather than in $HOME.
if [[ -n "$CLAUDE_CONFIG_DIR" ]]; then
  config_dir="$CLAUDE_CONFIG_DIR"
  config_json="$CLAUDE_CONFIG_DIR/.claude.json"
else
  config_dir="$HOME/.claude"
  config_json="$HOME/.claude.json"
fi

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

function warn_if_hot {
  local percent="$1" text="$2" color="${3:-$RED}"

  if [[ -n "$percent" && $percent -ge 80 ]]; then
    echo "${color}⚠ ${text}${GREY}"
  else
    echo "$text"
  fi
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
        (.model.id // ""),
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
model_id=${status[4]}
effort=${status[5]}
five_hour_pct=${status[6]}
five_hour_reset=${status[7]}
seven_day_pct=${status[8]}
seven_day_reset=${status[9]}
fable_pct=${status[10]}
fable_reset=${status[11]}

# The Fable quota belongs to a model you may not be running, so warn about it
# quietly unless it is the model spending the quota.
fable_color=$GREY
if [[ "${model_id,,}" == *fable* || "${model,,}" == *fable* ]]; then
  fable_color=$RED
fi

if [[ -z "$fable_pct" ]]; then
  mapfile -t cached_fable < <(fable_quota_from_usage_cache)
  fable_pct=${cached_fable[0]}
  fable_reset=${cached_fable[1]}
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

identity=()

if [[ -n "$branch" ]]; then
  identity+=("$dir ($branch)")
else
  identity+=("$dir")
fi

[[ -n "$effort" ]] && model="$model $effort"
[[ -n "$model" ]] && identity+=("$model")

email=$(jq -r '.oauthAccount.emailAddress // empty' "$config_json" 2>/dev/null)
[[ -n "$email" ]] && identity+=("$email")

usage=("$(warn_if_hot "$context_pct" "${used_fmt} (${context_pct}%)")")

quotas=()

five_hour_quota=$(format_quota "$five_hour_pct" "$five_hour_reset")
[[ -n "$five_hour_quota" ]] && quotas+=("$(warn_if_hot "$five_hour_pct" "$five_hour_quota")")

seven_day_quota=$(format_quota "$seven_day_pct" "$seven_day_reset")
[[ -n "$seven_day_quota" ]] && quotas+=("$(warn_if_hot "$seven_day_pct" "$seven_day_quota")")

fable_quota=$(format_quota "$fable_pct" "$fable_reset")
[[ -n "$fable_quota" ]] && quotas+=("$(warn_if_hot "$fable_pct" "$fable_quota" "$fable_color")")
[[ ${#quotas[@]} -gt 0 ]] && usage+=("$(join_with ", " "${quotas[@]}")")

echo -e "${GREY}$(join_with " | " "${identity[@]}")${UNCOLORED}"
echo -ne "${GREY}$(join_with " | " "${usage[@]}")${UNCOLORED}"
