# Content Security Policy (CSP) Bypass

### Bypass Content Security Policy (CSP) and execute JavaScript in the page.

> The Content-Security-Policy header allows you to restrict how resources such as JavaScript, CSS, or pretty much anything that the browser loads.
>

> Although it is primarily used as a HTTP response header, you can also apply it via a [meta tag](https://content-security-policy.com/examples/meta/).
>

### 觀察 CSP 設定

### script-src

可以看出這些來源的 script 是可以被接受的，所以任何從以下來載入的 script 都可以被執行

```html
Content-Security-Policy: script-src 'self' https://pastebin.com  example.com code.jquery.com https://ssl.google-analytics.com ;
```

### 試著載入來自 pastebin 的 js file

```html
https://pastebin.com/assets/9ce1885/jquery.min.js
```

在 console 可驗證是否載入成功

```
$.ajax
```

也可試著載入其他 embed 內容
```html
https://pastebin.com/embed/sa4JzpAP
```
### 心得

直得留意的是，本機的 DVWA 是沒有 HTTPS 的，而載入的來源都已經強制使用或自動跳轉成 HTTPS
