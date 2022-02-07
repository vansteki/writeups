# JavaScript Attacks

### Objective

Simply submit the phrase "success" to win the level. Obviously, it isn't quite that easy, each level implements different protection mechanisms, the JavaScript included in the pages has to be analysed and then manipulated to bypass the protections.

### 1.查看表單細節
### 2.檢查送出前 javascript 有做哪些處理
```jsx
/*
MD5 code from here
https://github.com/blueimp/JavaScript-MD5
*/

...

function rot13 (inp) {
  return inp.replace(/[a-zA-Z]/g, function (c) {return String.fromCharCode((c <= "Z" ? 90 : 122) >= (c = c.charCodeAt(0) + 13) ? c : c - 26);});
}

function generate_token () {
  var phrase = document.getElementById("phrase").value;
  document.getElementById("token").value = md5(rot13(phrase));
}

generate_token();
```

可以發現在頁面載入時． `generate_token()` 這個 function 會被執行一次，它將 `#phrase` 的 value 餵給 md5 和 rot13，產生一組 token，此時 `phrase` 是預設的 `ChangeMe` ，因此不論你送出什麼，都會得到 invalid token 這樣的回傳訊息，因為 token 是由 `ChangeMe` 這個字串的值運算而來 也就是`8b479aefbd90795395b3e7089ae0dc09`

因此簡單的解法就是在 input 填入 `success` 後，於 console 再執行一次，這樣 token 的值就會改變成**`38581812b435834ebf84ebcc2c6424d6`**

手動在 console 執行 `generate_token()` 一次，再送出表單就完成了

## memo

可以手動在 console 測試頁面的 function

### 測試 `generate_token()`
```jsx
md5(rot13('ChangeMe')) // "8b479aefbd90795395b3e7089ae0dc09"
```
```jsx
md5(rot13('success')) // "**38581812b435834ebf84ebcc2c6424d6"**
```
