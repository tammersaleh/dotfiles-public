export CLOUDSDK_PYTHON=$(which python3)
export BOTO_CONFIG=/dev/null

__source_if_exists "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
