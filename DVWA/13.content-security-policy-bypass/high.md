# Content Security Policy (CSP) Bypass

> The page makes a JSONP call to source/jsonp.php passing the name of the function to callback to, you need to modify the jsonp.php script to change the callback function.
>

剛開始還不太知道這題的用意是什麼，參考提示和爬文後大概知道了

這題跟 CSP 的關係是? → JSONP 是被拿來突破 CSP 的

它要你試著攻擊 jsonp endpoint，那邊有明顯的注入點

```html
http://dvwa.localtest/vulnerabilities/csp/source/jsonp.php?callback=solveSum
```

```html
callback=solveSum
```

後端會把針對 solveSum 的答案回傳給前端並執行該 function

而這次多了一隻 high.js，觀察它可以知道 jsonp 是怎麼被呼叫的

`high.js`

```jsx
function clickButton() {
    var s = document.createElement("script");
    s.src = "source/jsonp.php?callback=solveSum";
    document.body.appendChild(s);
}

function solveSum(obj) {
	if ("answer" in obj) {
		document.getElementById("answer").innerHTML = obj['answer'];
	}
}

var solve_button = document.getElementById ("solve");

if (solve_button) {
	solve_button.addEventListener("click", function() {
		clickButton();
	});
} 
```

```markdown
1. clickButton(); 

2. inject jsonp.php script into HTML DOM

3. script tag execute jsonp call 

4. jsonp call returned and execute solveSum
```

重點在於 `source/jsonp.php?callback=solveSum` 這段可以被隨意插入任何內容

如果在 `solveSum` 前面加上 `alert(document.cookie)` ，就會在你按下 button 等 jsonp callback funciton 回傳後一起被執行，至於要在哪邊竄改則是可以自由發揮，你可以攔截 request，也可以透過其他方式 (e.g XSS) 在前端覆寫原來的 jsonp request

```jsx
function clickButton() {
    var s = document.createElement("script");
    s.src = "source/jsonp.php?callback=alert(document.cookie);solveSum";
    document.body.appendChild(s);
}
```

因此從這邊可以看出至少有兩個方向可以攻擊，一個是針對 jsonp request 的 endpoint

另一個則是順著 jsonp request，不去修改它，但我可以修改前端被呼叫的 function，例如:

```jsx
solveSum = ()=> alert(document.cookie)
```

### 心得

有幾個攻擊方向

1. 攔截並修改呼叫 jsonp 的 request
2. 搭配 XSS 插入或覆寫前端即將被 jsonp callback 使用的 function
3. 雖然沒有驗證，但我認為有機會搭配 CSRF + XSS + include file or command injection

### impossible

在 impossible 難度 `source/jsonp.php` 不理會後面加上的參數，所以沒辦法直接修改這邊

所以只好用其他地方下手
