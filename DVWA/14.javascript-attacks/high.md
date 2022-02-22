# JavaScript Attacks

> Objective:
>
>
> Simply submit the phrase "success" to win the level. Obviously, it
> isn't quite that easy, each level implements different protection
> mechanisms, the JavaScript included in the pages has to be analysed and
> then manipulated to bypass the protections.

high.js 被混淆過，應該就是這關的主要障礙了吧 🤔

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/39da7c41-b03a-4521-9bf3-126c5c2dad05/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220222%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220222T073409Z&X-Amz-Expires=86400&X-Amz-Signature=07a7da9af88d8937fbd97283bc233da75ecdcd98d9a7c49b88c1ef29065aa98a&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/8da0278c-d778-4568-aece-7a764f193a26/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220222%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220222T073423Z&X-Amz-Expires=86400&X-Amz-Signature=20368db7ab9184d90596535b4205d9b3f82bd2202579a63e8af20ae7284e6f4a&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

### use  de4js to decode

先 google 看看有沒有反混淆的工具可以用，找到 de4js 就先試試看了

de4js | JavaScript Deobfuscator and Unpacker
[https://lelinhtinh.github.io/de4js/](https://lelinhtinh.github.io/de4js/)

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/ecdc9eba-cb13-43f7-96aa-8b58c3a740d2/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220222%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220222T073528Z&X-Amz-Expires=86400&X-Amz-Signature=bcb9e89c066c00353b1b25ae03c8da3999d98ce40959df4b4689d5e0b4aa3fc2&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

恩 有比較像是給人看的 code 了

```jsx
function do_something (e) {
  for (var t = '', n = e.length - 1; n >= 0; n--) t += e[n]
  return t
}

function token_part_3 (t, y = 'ZZ') {
  document.getElementById('token').value = sha256(document.getElementById('token').value + y)
}

function token_part_2 (e = 'YY') {
  document.getElementById('token').value = sha256(e + document.getElementById('token').value)
}

function token_part_1 (a, b) {
  document.getElementById('token').value = do_something(document.getElementById('phrase').value)
}

document.getElementById('phrase').value = ''
setTimeout(function () {
  token_part_2('XX')
}, 300)

document.getElementById('send').addEventListener('click', token_part_3)

token_part_1('ABCD', 44)
```

直接拉到最下面可以看到 3 個可能的進入點， `token_part_3` 要等到送出 button 後才會被執行， `token_part_1` 會先被執行， `token_part_2` 因為有被延遲的關係，會在 `token_part_1` 後面執行，所以執行順序應該就是跟名稱一樣:

```jsx
token_part_1 → token_part_2 → token_part3 
```

```jsx
document.getElementById('phrase').value = ''
setTimeout(function () {
  token_part_2('XX')
}, 300)

document.getElementById('send').addEventListener('click', token_part_3)

token_part_1('ABCD', 44)
```

### token_part_1

call `do_something` to reverse token
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/56e9d7c7-ed00-4a17-9095-433bdafc21c9/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220222%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220222T073604Z&X-Amz-Expires=86400&X-Amz-Signature=b2e5a46cae62de579e315331f76fea18c282d9f90831b6f516b50e247362028f&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)
```jsx
function token_part_1 (a, b) {
  document.getElementById('token').value = do_something(document.getElementById('phrase').value)
}
```

### reverse `phrase`

token_part_1 的參數只是障眼法，並沒有任何作用

```jsx
function do_something (e) {
  // e is phrase value
  for (var t = '', n = e.length - 1; n >= 0; n--) t += e[n] // reverse the token
  return t
}
```
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/884a53b7-ee56-46c5-bdf1-b59a05491965/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220222%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220222T073623Z&X-Amz-Expires=86400&X-Amz-Signature=156e9ade7a614af455b8772736cf6cb73ca9c20cd3b531df267ec8a0dd40cd49&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

此時 `document.getElementById('token').value` 的值會是 `phrase` 倒過來的值

接著換 token_part_2

### token_part_2

`e = 'YY'` 是 default value，`token_part_2('XX')` 被呼叫時有傳 `XX` 了所以實際上這裡的 `e` 是 `XX`

```jsx
function token_part_2 (e = 'YY') {
  document.getElementById('token').value = sha256(e + document.getElementById('token').value)
}
```

將 reverse 後的 phrase 前面加上 `XX` 後再用 sha256 hash 一次

```jsx
sha256('XX' + token)
```

最後是 token_part_3

### token_part_3

`token_part_3` 並沒有傳入任何參數，因此這裡的 `y` 會是 `ZZ` ，最後將上一步的結果加上 `ZZ` 後再次用 sha256 hash 一次

```jsx
function token_part_3 (t, y = 'ZZ') {
  document.getElementById('token').value = sha256(document.getElementById('token').value + y)
}
```

```jsx
sha256( token + 'ZZ')
```

因為是將固定的 phrase hash 兩次，所以答案應該是固定的

### 總結流程

```jsx
reverse the phrase value to token value -> sha256('XX' + token) -> sha256(token + 'ZZ')
```

```jsx
token = do_something('success') // "sseccus"
```

```jsx
token = sha256('XX' + token) // "7f1bfaaf829f785ba5801d5bf68c1ecaf95ce04545462c8b8f311dfc9014068a"
```

```jsx
token = sha256(token + 'ZZ') // "ec7ef8687050b6fe803867ea696734c67b541dfafb286a0b1239f42ac5b0aa84"
```

final token:

```jsx
ec7ef8687050b6fe803867ea696734c67b541dfafb286a0b1239f42ac5b0aa84
```

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/b444fa5e-fee8-4ce4-9ff1-51317eeca5a9/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220222%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220222T073706Z&X-Amz-Expires=86400&X-Amz-Signature=5a228e1ee39476f53d305a4191294d02c1a7da93671137bacda85c2ab066456d&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

```json
{
	"token": "ec7ef8687050b6fe803867ea696734c67b541dfafb286a0b1239f42ac5b0aa84",
	"phrase": "success",
	"send": "Submit"
}
```
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/5e2bf3fd-9421-480d-a99e-cb74b554f5f6/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220222%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220222T073719Z&X-Amz-Expires=86400&X-Amz-Signature=0e999994b2fd28e3ff230dae7e82a5565961cb057dcf9592ea381b7410998e97&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

---
# Ref

- de4js | JavaScript Deobfuscator and Unpacker
  [https://lelinhtinh.github.io/de4js/](https://lelinhtinh.github.io/de4js/)
