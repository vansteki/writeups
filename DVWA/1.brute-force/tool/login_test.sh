# create cookie and save csrf token
CSRF=`curl -s -L -c cookies.txt -b cookies.txt "http://localhost:8086/login.php" | grep user_token  | grep -oE \[a-z0-9\]+ | awk 'length >= 10'`
# save session id
SESSIONID=$(grep PHPSESSID cookies.txt | cut -d $'\t' -f7)

# user & password for login to start tasks
USER=admin
LOGIN_PASSWORD=password

# login at login page
curl -v -L -c cookies.txt -b cookies.txt \
-X POST "http://localhost:8086/login.php" \
--data-raw \
"username=${USER}&password=${LOGIN_PASSWORD}&Login=Login&user_token=${CSRF}"

# enter username and password in brute force page: /vulnerabilities/brute/
RES=`curl -L -v -c cookies.txt -b cookies.txt "http://localhost:8086/vulnerabilities/brute/?username=${USER}&password=${LOGIN_PASSWORD}&Login=Login#"`

#echo $RES | grep admin

if [[ $RES == *"Welcome to the password protected area admin"* ]]; then
  echo "\n PASS!✅ \n"
fi
