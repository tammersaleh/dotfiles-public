# Load secrets from the macOS login keychain into the environment.
#
# The manifest (~/.config/secrets-sync/manifest, private dotfiles) lists
# `ENV_VAR op://...` pairs. `secrets-sync` (bin/) writes each value to the
# login keychain as service `secrets-sync.coreweave.<ENV_VAR>`; this file
# reads them back at shell start. Inert when the manifest is absent.
#
# Reads go through one `security -i` process (about 40ms for nine items,
# versus ~25ms per item spawned separately). Only fixed service names go
# into that command stream, never values. If the batch returns fewer lines
# than expected, fall back to one read per variable so the missing ones
# can be named.

__load_secrets() {
  local manifest="${SECRETS_MANIFEST:-$HOME/.config/secrets-sync/manifest}"
  [[ -r "$manifest" ]] || return 0

  local account=coreweave.1password.com
  local namespace=secrets-sync.coreweave
  local keychain="$HOME/Library/Keychains/login.keychain-db"

  local -a vars=()
  local var ref
  while read -r var ref; do
    [[ -z "$var" || "$var" == \#* ]] && continue
    [[ "$var" =~ '^[A-Z_][A-Z0-9_]*$' ]] || continue
    # Keep a value already in the environment (e.g. inherited from a parent shell).
    [[ -n "${(P)var-}" ]] && continue
    vars+=("$var")
  done < "$manifest"
  (( ${#vars} )) || return 0

  local -a values=()
  local v
  values=("${(@f)$(for v in "${vars[@]}"; do
    print -r -- "find-generic-password -a $account -s $namespace.$v -w $keychain"
  done | security -i 2> /dev/null)}")

  local -a missing=()
  if (( ${#values} == ${#vars} )); then
    local i
    for (( i = 1; i <= ${#vars}; i++ )); do
      if [[ -n "${values[i]}" ]]; then
        export "${vars[i]}=${values[i]}"
      else
        missing+=("${vars[i]}")
      fi
    done
  else
    # Slow path: identify which items are missing.
    # `local` stays outside the loop: re-declaring an existing zsh parameter prints its value.
    local value
    for v in "${vars[@]}"; do
      if value=$(security find-generic-password -a "$account" -s "$namespace.$v" -w "$keychain" 2> /dev/null) && [[ -n "$value" ]]; then
        export "$v=$value"
      else
        missing+=("$v")
      fi
    done
  fi

  if (( ${#missing} )); then
    print -u2 "secrets: ${#missing} missing from keychain (${(j:, :)missing}). Run secrets-sync."
  fi
}

__load_secrets
unfunction __load_secrets
