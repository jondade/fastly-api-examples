#! /bin/bash

# This script will generate an api_credentials.sh file and put it in a
# '.fastly' directory under your home directory. For examples of basic token
# generation see tokens.sh.

# Check if we need to show debug output
if [[ "$FASTLY_API_DEBUG" == "TRUE" ]]; then
  set -e
  set -x
  curlopts="-v"
fi

# Fetch user credentials
echo "Please enter your username:"
read username

echo "Please enter your password:"
read -s password

# Fetch a nice new token
out=$(curl $curlopts -X POST \
     -H 'Accept: application/json' \
     -d "username=${username}" \
     -d "password=${password}" \
     -d "scope=global" \
     https://api.fastly.com/tokens)

# Debug output
if [[ "$FASTLY_API_DEBUG" == "TRUE" ]]; then
  echo "out: ${out}"
fi

# Check if the previous fetch failed for 2 factor authentication. If so grab a
# code from the user and try again.
if [[ $out == *'Invalid one-time password'* ]]; then
  echo "Enter a 2 factor authentication code from your device:"
  read otp
  out=$(curl $curlopts -X POST \
       -H 'Accept: application/json' \
       -d "username=${username}" \
       -d "password=${password}" \
       -H "Fastly-OTP: ${otp}" \
       -d "scope=global" \
       https://api.fastly.com/tokens)
 echo "test"
fi

# Debug output
if [[ "$FASTLY_API_DEBUG" == "TRUE" ]]; then
  echo "out: ${out}"
fi

if [[ $out == *'access_token'* ]]; then

  # Set a couple of useful variables
  directory="$HOME/.fastly"
  filename="${directory}/api_credentials.sh"

  # Set up the directory and file for a known good baseline
  if [[ ! -d $directory ]]; then
    mkdir $directory
  fi

  if [[ ! -f $filename ]]; then
    echo "TOKEN=''" > $filename
    echo "SERVICE_ID''" >> $filename
  fi

  token=$(echo $out | sed -e 's/.*access_token":"\([^"]*\)","name.*/\1/')
  sed -i -e "s/TOKEN=''/TOKEN='${token}'/" $filename
fi
