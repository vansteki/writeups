# JavaScript Attacks

> Objective:
>
>
> Simply submit the phrase "success" to win the level. Obviously, it
> isn't quite that easy, each level implements different protection
> mechanisms, the JavaScript included in the pages has to be analysed and
> then manipulated to bypass the protections.
>

### 觀察

- 多出了一個新的 js file
- 有兩種方式送出答案，一種是覆寫前端 js code 後送出，另一種是直接改 request 的 value，只要 value 正確就會過關

```jsx
function do_something(e) {
  for (var t = '', n = e.length - 1; n >= 0; n--) t += e[n];
  return t
}
setTimeout(function () {
  do_elsesomething('XX')
}, 300);
function do_elsesomething(e) {
  document.getElementById('token').value = do_something(e + document.getElementById('phrase').value + 'XX')
}
```

```jsx
do_something("abc")
"cba"
```

看上面那段 code 大概可以推敲出結果

```jsx
'XXabcXX' -> 'XXcbaXX'
```

更近一步用 debugger 觀察

```jsx
e + document.getElementById('phrase').value + 'XX'
// "XXChangeMeXX"
```
觀察正常流程

Request Body:

```jsx
token=XXeMegnahCXX&phrase=ChangeMe&send=Submit
```

可以發現只要將 success 倒過來再將前後加上 XX變成 `XXsseccusXX` 就是 token 答案了，phrase 則是 `success`，接下來只要想辦法送出它就行了
```jsx
do_something('success')
// "sseccus"
```

```jsx
token=XXsuccessXX&phrase=ChangeMe&send=Submit
```

### Done

```jsx
token=XXsseccusXX&phrase=success&send=Submit
```
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/09f543ed-ba9f-43e7-a52e-e74db11fbedb/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220216%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220216T125638Z&X-Amz-Expires=86400&X-Amz-Signature=d8720bfadcdfc82cc221c6aedba08321c4a945e55345d576d79c06fdca7add4e&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/c15be5b1-3c6e-477c-9c1d-a53a989352d0/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220216%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220216T125653Z&X-Amz-Expires=86400&X-Amz-Signature=29dda37f5a82f31a41a7656502255ed1c1f4bf21af6b7037724b5e54339faeea&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)
