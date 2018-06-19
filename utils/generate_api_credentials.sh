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

# Set a couple of useful variables
curlopts="-s $curlopts"
directory="$HOME/.fastly"
filename="${directory}/api_credentials.sh"

# Set up the directory and file for a known good baseline
if [[ ! -d $directory ]]; then
  mkdir $directory
fi

if [[ -f $filename ]]; then
  mv $filename $filename$(date +-%s)
fi

# Fetch user credentials
echo "Please enter your username:"
read username

echo "Please enter your password:"
read -s password

echo "EMAIL='$username'" >> $filename
echo "PASSWORD='$password'" >> $filename

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
 echo
fi

# Debug output
if [[ "$FASTLY_API_DEBUG" == "TRUE" ]]; then
  echo "out: ${out}"
fi

if [[ $out == *'access_token'* ]]; then
  token=$(echo $out | sed -e 's/.*access_token":"\([^"]*\)","name.*/\1/')
  echo "TOKEN='$token'" >> $filename
  cid=$(echo $out | sed -e 's/.*customer_id":"\([^"]*\)","name.*/\1/')
  echo "CUSTOMER='$cid'" >> $filename
fi

#TODO: add option to create a new service for testing with
echo -n "Select a service? y/N > "
read choice
choice=$(echo $choice | tr '[:upper:]' '[:lower:]')
if [[ $choice == "y"* ]]; then
  source $filename
  out=$(curl $curlopts -H "Fastly-Key: $TOKEN" https://api.fastly.com/service)
  newout=$(echo $out \
    | tr -s '}}}}' '[\n*1]' \
    | sed -e '$d' | sed -e '$d' \
    | sed -e 's#.*\("id".*\)#\1#' \
    | sed -e '/"customer"/d' \
    | sed -e 's#.*"id":"\([^"]*\)".*"name":"\([^"]*\).*#\1, \2#')
  echo "$newout" | nl
  read -p "Which service do you want to use? " service
  sid=$(echo "$newout" | sed -n "$service"p | sed -e 's#\([^,]*\),.*#\1#')
  echo "SERVICE='$sid'" >> $filename
  echo "Contents written to $filename"
else
  echo -n "Do you want to create a new service? Y/n > "
  read choice
  choice=$(echo $choice | tr '[:upper:]' '[:lower:]')
  if [[ $choice == "y"* ]]; then
    source $filename
    out=$(curl $curlopts -H "Fastly-Key: $TOKEN" -X POST -H 'Accept:application/json' https://api.fastly.com/service -d "name=API-testing")
    echo $out
  fi
fi
