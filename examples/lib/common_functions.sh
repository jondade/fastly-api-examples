#! /bin/bash
#
# This file contains some code common to all the example scripts. This is kept
# here to keep the example files as clean / clear as possible.

# Common variables
API_URL="https://api.fastly.com"
CREDENTIALS_FILE="$HOME/.fastly/api_credentials.sh"
CURL="$(which curl) -H Accept:application/json"

function startup() {
  parse_args $@
  check_credentials
  source $CREDENTIALS_FILE
  TOKEN_HEADER="-H Fastly-key:$TOKEN"
}

function parse_args(){
  while getopts "dh" opt; do
    case $opt in
      d )
        echo "Debug mode: ON"
        set_debug
        ;;
      h)
        echo "help stuffs"
        exit 0
        ;;
      default )
        ;;
    esac
  done
}

function set_debug() {
  set -e
  set -x
  CURL=$CURL" -sv"
}

function check_credentials() {
  if [[ ! -f $CREDENTIALS_FILE ]]; then
    echo "No token found at $CREDENTIALS_FILE. \
          Please run generate_api_credentials.sh to create them."
    exit 1
  fi
}
