# For the Dockers!
export UID
export GID=$(id -g)
export DOCKER_BUILDKIT=1
export DOCKER_HOST="unix:///$HOME/.orbstack/run/docker.sock"  # Tilt gets confused without this.

DOCKER_ETC=/Applications/Docker.app/Contents/Resources/etc
__source_if_exists "$DOCKER_ETC/docker.zsh-completion"
__source_if_exists "$DOCKER_ETC/docker-machine.zsh-completion"
__source_if_exists "$DOCKER_ETC/docker-compose.zsh-completion"
