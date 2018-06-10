#!/bin/bash

# Tokens
#
# These are the recommended way of authenticating with the Fastly API. They are
# documented here: https://docs.fastly.com/api/auth#tokens




# Pull in some common functions to keep this file cleaner and run a baseline
# setup of the environment ready.
source lib/common_functions.sh
startup $@

# Show the currently used token details.
echo "$CURL $TOKEN_HEADER $API_URL/tokens/self"
$CURL $TOKEN_HEADER $API_URL/tokens/self



# Final echo because the Fastly API has no carriage return on the response body.
echo
