# Weak Session IDs

丟給 Burp suite 的 Sequencer 分析也看不太出來有什麼特徵

分析的結果是 excellent，代表隨機性是不錯的

也許是類似重新產生次數 + time stamp 的組合 🤔

可能是某種 encode 後長度為 32 的演算法

PHPSESSION 和 dvwaSession 長度一樣是 32

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/51783f21-28c3-4df4-acc9-e0b22803ea37/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220218%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220218T085722Z&X-Amz-Expires=86400&X-Amz-Signature=67cff65c4025a1a1a1a1af82b7401fe07cbc6747ecbb1e3af9b987e6697f9089&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/4527cc60-d69d-4786-8b5e-cb27ad7d6160/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220218%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220218T085710Z&X-Amz-Expires=86400&X-Amz-Signature=a2e18a00e1881941072d11839a45ea0b09a2c6f772d8e427c076f33358698a37&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

剛好跟 md5 長度一樣，有機會是 md5
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/8a8d7a6a-cea4-46fd-bc5d-7b7296658349/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220218%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220218T085744Z&X-Amz-Expires=86400&X-Amz-Signature=60fe16c6124c1266dccdfb0abe9f6ae2dde272789b99db9f79b638b796ddfe90&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

有試著分析 cookie 的日期和 `dvwaSession` 之間的關聯，但很不好測，因為時間會變動，又需要轉換，看不出什麼關聯

```jsx
...
php > echo date('Y-m-d H:i:s', '1645171297');
2022-02-18 09:01:37
php > echo gmdate('Y-m-d H:i:s', '1645171297');
2022-02-18 08:01:37
php > echo gmdate('Y-m-d H:i:s', '1645168491');
2022-02-18 07:14:51
php >
...
```

哭啊 先躺平了 🙈

### Done

沒招了，絕望之下只好把 `dvwaSession` 丟給 google 大神

```jsx
6512bd43d9caa6e02c990b0a82652dca
```
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/1ccc2066-3694-4d93-bfba-c5652cbef327/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220218%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220218T085839Z&X-Amz-Expires=86400&X-Amz-Signature=fd30b89290026f49ba18224c5b1e41f0513da9d2a9dae4725a6002a1808bb8ea&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

結果令人意外的單純 🤯
![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/6daa697a-5f0f-43df-a410-d2b5356f4718/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220218%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220218T085903Z&X-Amz-Expires=86400&X-Amz-Signature=fd2dc4c827d180656ce36a2f6e15b9c167cf054b0f26844407f9cfe11e024776&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)
```
11 -> 6512bd43d9caa6e02c990b0a82652dca
12 -> c20ad4d76fe97759aa27a0c99bff6710
```

```
php > echo md5(11);
6512bd43d9caa6e02c990b0a82652dca
php > echo md5(12);
c20ad4d76fe97759aa27a0c99bff6710
php >
```

目前的值是 11，應該是 Generate 的次數，下一次是 12，session id 應該是 `c20ad4d76fe97759aa27a0c99bff6710`

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/0f23bb90-c1a1-4e2a-bb2c-41da0358d377/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220218%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220218T090027Z&X-Amz-Expires=86400&X-Amz-Signature=b3169ed92d152c6fa72d531e91cf680e03be29a930209242ba5a3fe2335fe6ac&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/911430b8-6715-4b34-a1cd-3ef613d9ef85/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220218%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220218T090039Z&X-Amz-Expires=86400&X-Amz-Signature=eff2f7708bddcd68868b9d1d9d275c4a2336ffd64e1ececef3815206b5970fe3&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

```
dvwaSession: "c20ad4d76fe97759aa27a0c99bff6710"
```

這關也是靠運氣 🙈，果然運氣點滿也很重要
