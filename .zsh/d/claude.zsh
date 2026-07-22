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
# Ranks all sessions by keyword overlap (rg), extracts metadata for the top
# matches, and asks haiku to pick the best one.
# The haiku search runs under a throwaway session id that is deleted afterward,
# so this tool never records - or returns - a session of its own.
cr() {
  emulate -L zsh
  setopt local_options extended_glob

  if (( $# == 0 )); then
    echo "usage: cr <description of the session to resume>" >&2
    return 1
  fi

  local query="$*"
  local root=~/.claude/projects
  local top=${CR_TOP:-120}    # how many keyword-ranked candidates haiku ranks

  # Keywords: lowercase, split on non-alphanumerics, drop short words + stopwords.
  local -a stop=(the and are was for you your our that this with from into not
                 can will would has have had its about session sessions
                 where when what which who why how)
  local -a words=(${(s: :)${(L)query//[^[:alnum:]]/ }})
  local -a kw=() w
  for w in $words; do
    (( ${#w} < 3 )) && continue
    (( ${stop[(Ie)$w]} )) && continue
    kw+=$w
  done
  (( ${#kw} == 0 )) && kw=($words)
  kw=(${(u)kw})
  if (( ${#kw} == 0 )); then
    echo "cr: need a searchable description" >&2
    return 1
  fi

  # Rank session files by how many distinct keywords they contain (not raw
  # count - that buries short, precise sessions under long verbose ones).
  # One rg pass per keyword, run in parallel, then tally distinct hits per file.
  local -a rgopts=(-uu --text -l -i
        -g '*.jsonl' -g '!**/tool-results/**' -g '!**/subagents/**' -g '!agent-*.jsonl')
  local tmpd k
  tmpd=$(mktemp -d "${TMPDIR:-/tmp}/cr.XXXXXX") || return 1
  for k in $kw; do
    rg $rgopts -e "$k" "$root" 2>/dev/null > "$tmpd/$k" &
  done
  wait
  local -a cand
  cand=( ${(f)"$(cat "$tmpd"/*(#qN) | sort | uniq -c | sort -rn | head -n $top | sed 's#^ *[0-9]* *##')"} )
  rm -rf "$tmpd"
  if (( ${#cand} == 0 )); then
    echo "cr: no sessions mention: ${(j:, :)kw}" >&2
    return 1
  fi

  # Extract session id, project dir, and first user prompt for each candidate.
  # perl reads only the head of each file, so large sessions stay cheap.
  local perl='
use strict; use warnings; use JSON::PP;
my $jp = JSON::PP->new; my $MAXLINES = 80; my $MAXLEN = 65536;
while (my $f = <STDIN>) {
  chomp $f; (my $base = $f) =~ s{.*/}{}; next if $base =~ /^agent-/;
  open(my $fh, "<", $f) or next;
  my ($cwd, $desc); my $n = 0;
  while (my $line = <$fh>) {
    last if ++$n > $MAXLINES; last if defined $cwd && defined $desc;
    next if length $line > $MAXLEN;
    my $wc = !defined $cwd  && index($line, q{"cwd"}) >= 0;
    my $wd = !defined $desc && index($line, q{"type":"user"}) >= 0;
    next unless $wc || $wd;
    my $o = eval { $jp->decode($line) }; next unless $o && ref $o eq q{HASH};
    $cwd = $o->{cwd} if $wc && defined $o->{cwd} && length $o->{cwd};
    if ($wd && !($o->{isMeta}//0)) {
      my $c = eval { $o->{message}{content} };
      # Skip slash commands, command/system wrappers, and caveats - keep the
      # first substantive prompt, which describes what the session was about.
      if (defined $c && !ref $c
          && $c !~ m{^/} && $c !~ /^<(command|local-command|system-reminder)/
          && $c !~ /^Caveat/) {
        (my $d = $c) =~ s/<[^>]*>/ /g; $d =~ s/\s+/ /g; $d =~ s/^ //; $d =~ s/ $//;
        $desc = substr($d, 0, 150) if length $d >= 12;
      }
    }
  }
  close $fh; next unless defined $cwd && length $cwd;
  (my $sid = $base) =~ s/\.jsonl$//; $desc //= "";
  for ($sid, $cwd, $desc) { tr/\t\n/  /; }
  print "$sid\t$cwd\t$desc\n";
}'
  local index
  index=$(print -rl -- $cand | perl -e "$perl")
  if [[ -z $index ]]; then
    echo "cr: could not read metadata for any candidate session" >&2
    return 1
  fi

  local -A dir_of      # session id -> project dir
  local line
  for line in ${(f)index}; do
    local id=${line%%$'\t'*} rest=${line#*$'\t'}
    dir_of[$id]=${rest%%$'\t'*}
  done

  # Throwaway session id for the haiku search, deleted afterward so it isn't recorded.
  local search_sid=$(uuidgen | tr 'A-Z' 'a-z')
  local prompt="Each line below describes one Claude Code session: SESSION_ID<tab>PROJECT_DIR<tab>DESCRIPTION.
Pick the ONE session that best matches this request: \"$query\".
Respond with ONLY that session's SESSION_ID (the first field) and nothing else.
If nothing matches, respond with exactly: NONE

$index"

  # --bare skips MCP servers, hooks, and CLAUDE.md discovery (all pure overhead
  # here) and uses ANTHROPIC_API_KEY directly, which cuts the call from ~35s to ~9s.
  local result
  result=$(print -r -- "$prompt" | claude -p --bare --model haiku --session-id "$search_sid" 2>/dev/null)
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
