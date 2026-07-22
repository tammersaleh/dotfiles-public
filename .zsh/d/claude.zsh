# https://code.claude.com/docs/en/agent-teams
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
export CLAUDE_CODE_HIDE_ACCOUNT_INFO=1
alias cw="cd ~/brain/cw && cl"
cl() {
  if [[ -v NVIM ]]; then
    # Already in a neovim terminal, just run claude directly
    [ -v DEBUG ] && echo "In nvim already, running claude"
    claude "$@"
  else
    # Not in nvim, launch nvim with terminal and run claude
    [ -v DEBUG ] && echo "Launching nvim with claude"
    nvim -c "terminal claude $*"
  fi
}

# cr <description> - find a past claude session by description, cd there, resume it.
# Builds a compact index of recent sessions and asks haiku to pick the best match.
# The haiku search run uses a throwaway session id that is deleted so it isn't recorded.
cr() {
  emulate -L zsh
  setopt local_options extended_glob

  if (( $# == 0 )); then
    echo "usage: cr <description of the session to resume>" >&2
    return 1
  fi

  local query="$*"
  local limit=${CR_LIMIT:-300}
  local root=~/.claude/projects

  local files=( $root/**/*.jsonl(#qom[1,$limit]) )
  if (( ${#files} == 0 )); then
    echo "cr: no sessions found under $root" >&2
    return 1
  fi

  local -A dir_of      # session id -> project dir
  local index="" f base sid line
  for f in $files; do
    base=${f:t}
    [[ $base == agent-* ]] && continue   # skip subagent sidechains
    sid=${base:r}
    line=$(head -n 120 -- "$f" | jq -rs --arg sid "$sid" '
      def fp:
        map(select(.type=="user" and (.isMeta!=true) and (.message.content|type=="string")))
        | map(.message.content)
        | map(select(test("^<local-command|^Caveat")|not)) | (.[0]//"");
      (map(.cwd)|map(select(.!=null))|(.[0]//"")) as $c
      | select($c!="")
      | [$sid,$c,(fp|gsub("<[^>]*>";" ")|gsub("[[:space:]]+";" ")|.[0:150])]|@tsv' 2>/dev/null)
    [[ -z $line ]] && continue
    dir_of[$sid]=${line#*$'\t'}; dir_of[$sid]=${dir_of[$sid]%%$'\t'*}
    index+="$line"$'\n'
  done

  if [[ -z $index ]]; then
    echo "cr: could not read any session metadata" >&2
    return 1
  fi

  # Throwaway session id for the haiku search, deleted afterward so it isn't recorded.
  local search_sid=$(uuidgen | tr 'A-Z' 'a-z')
  local prompt="Each line below describes one Claude Code session: SESSION_ID<tab>PROJECT_DIR<tab>DESCRIPTION.
Pick the ONE session that best matches this request: \"$query\".
Respond with ONLY that session's SESSION_ID (the first field) and nothing else.
If nothing matches, respond with exactly: NONE

$index"

  local result
  result=$(print -r -- "$prompt" | claude -p --model haiku --session-id "$search_sid" 2>/dev/null)
  rm -f $root/*/"$search_sid".jsonl(#qN)

  # Pull a uuid out of the reply, wherever it lands.
  local sess=""
  if [[ $result =~ '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' ]]; then
    sess=$MATCH
  fi
  if [[ -z $sess ]]; then
    echo "cr: no matching session for: $query" >&2
    return 1
  fi

  local dir=${dir_of[$sess]}
  if [[ -z $dir ]]; then
    echo "cr: haiku returned an unknown session id: $sess" >&2
    return 1
  fi
  if [[ ! -d $dir ]]; then
    echo "cr: resolved directory does not exist: $dir" >&2
    return 1
  fi

  echo "cr: resuming $sess in $dir"
  cd "$dir" && claude --resume "$sess"
}
