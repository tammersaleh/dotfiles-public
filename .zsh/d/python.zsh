export PIP_CONFIG_FILE=$HOME/.config/pip/pip.conf
export PYTEST_ADDOPTS="--color=yes"
export PYTHONDONTWRITEBYTECODE=1

alias pyconsole="pipenv run ptpython"
alias pip=pip3

gpip(){
  # https://hackercodex.com/guide/python-development-environment-on-mac-osx/
  PIP_REQUIRE_VIRTUALENV="" pip3 "$@"
}
