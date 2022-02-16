# Weak Session IDs
> Objective: This module uses four different ways to set the dvwaSession cookie value, the objective of each level is to work out how the ID is
generated and then infer the IDs of other system users.

## 觀察

這數字有點眼熟

```sql
dvwaSession:"1645009861"
```

```jsx
+new Date()
```

在 console 比對一下，竟然是個很微妙的數字

很明顯是 timestamp，不過 PHP 和 JS 產生的有差異

### 試著使用 php function - time()

```jsx
root@91ab8a5e75e3:/# php -a
Interactive mode enabled

php > echo time();
1645010216
php >
```

### Done

比對一下跟 `dvwaSession` 得長度一樣，所以就是 PHP 的 `time()` function

```
"1645009861"
"1645010216"
```
