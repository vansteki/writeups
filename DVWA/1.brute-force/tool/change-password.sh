#!/usr/bin/env bash
# new password where

if [ -z "$1" ]
  then
    echo "No argument supplied, usage: change-password.sh <new password>"
    exit 1
fi

NEW_PASSWORD=$1

# DVWA host
HOST=http://localhost:8086
# create cookie and save csrf token
CSRF=`curl -s -L -c cookies.txt -b cookies.txt "${HOST}/login.php" | grep user_token  | grep -oE \[a-z0-9\]+ | awk 'length >= 10'`
# save session id
SESSIONID=$(grep PHPSESSID cookies.txt | cut -d $'\t' -f7)

# user & password for login to start tasks
USER=admin
LOGIN_PASSWORD=password

# login at login page
curl -v -L -c cookies.txt -b cookies.txt \
-X POST "${HOST}/login.php" \
--data-raw \
"username=${USER}&password=${LOGIN_PASSWORD}&Login=Login&user_token=${CSRF}"

# update password
RES=`curl -v -c cookies.txt -b cookies.txt \
"http://localhost:8086/vulnerabilities/csrf/?password_new=${NEW_PASSWORD}&password_conf=${NEW_PASSWORD}&Change=Change#"`

if [[ $RES == *"Password Changed."* ]]; then
  printf "\n ✅ password changed to ${NEW_PASSWORD}  \n"
fi
